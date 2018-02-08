//
//  LeomaWKWebView.m
//  Leoma
//
//  Created by CorpDev on 5/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import "LeomaWKWebView.h"
#import "JSONKit.h"
#import "LeomaModel.h"
#import "Leoma.h"
#import "LeomaWebProtocol.h"
#import "LeomaWebViewPreference.h"

@interface WKWebViewConfiguration (LeomaExtension)
-(instancetype)initWithProcessPool:(WKProcessPool*)pool;
@end
@interface LeomaWKWebView()
+(WKProcessPool *) sharedPool;

@property (weak, nonatomic) id<LeomaWebDelegate> leomaWebDelegate;
@property (weak, nonatomic) id<LeomaUIDelegate> leomaUIDelegate;

@property (assign, nonatomic) int alertType;

@property (strong, nonatomic) LeomaWebViewPreference * preference;
@property (strong, nonatomic) NSString * clonedDir;
@property (weak, nonatomic) UIViewController * controller;

@end

@implementation LeomaWKWebView
+(WKProcessPool *)sharedPool{
    static WKProcessPool * pool;
    leoma_dispatch_once(^{
        pool = [[WKProcessPool alloc] init];
    });
    return pool;
}
-(instancetype)initWithFrame:(CGRect)frame withPreference:(LeomaWebViewPreference *)preference withController:(UIViewController *)controller{
    self = [super initWithFrame:frame configuration:[[WKWebViewConfiguration alloc] initWithProcessPool:LeomaWKWebView.sharedPool]];
    if(self){
        self.controller = controller;
        self.preference = preference;
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    self.UIDelegate = self;
    self.navigationDelegate = self;
    //scroll config
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    if(IOS_11_OR_LATER){
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    //JS async controller
    self.configuration.userContentController = [[WKUserContentController alloc] init];
    [self.configuration.userContentController addScriptMessageHandler:self name:LeomaSpec];
}

- (void)dealloc{
    [self clearTemporaryDirectory];
    [self.configuration.userContentController removeAllUserScripts];
    self.configuration.userContentController = nil;
}

-(void)predealloc{
    [self.configuration.userContentController removeScriptMessageHandlerForName:LeomaSpec];
}

#pragma mark Private APIs

-(void)injectLeomaScript{
    [self.configuration.userContentController removeAllUserScripts];
    [self.configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:self.preference.InjectScript
                                                                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                                                forMainFrameOnly:NO]];
}

#pragma LeomaWebViewProtocol
-(void)executeJS:(NSString *)script{
    if([NSString isBlank:script]) return;
    leoma_dispatch_main(^{
        [self evaluateJavaScript:script completionHandler:nil];
    });
}

-(void)loadRemoteRequest:(NSURLRequest *)request{
    [self loadRemoteRequest:request withExternalEnvironment:nil];
}
-(void)loadRemoteRequest:(NSURLRequest*)request withExternalEnvironment:(NSDictionary *)environment{
    [self.preference registerLeomaEnvironment:environment];
    if([request.URL isFileURL]) NSLog(@"Must not be FileURL");
    else [self loadRequest:request];
}
//Fix ios fileLoad error.
-(void)loadBundleRequest:(NSString *)name OfExtension:(NSString *)extension OfBundle:(NSBundle *)bundle{
    [self loadBundleRequest:name OfExtension:extension OfBundle:bundle withExternalEnvironment:nil];
}
-(void)loadBundleRequest:(NSString*)name OfExtension:(NSString*)extension OfBundle:(NSBundle*)bundle withExternalEnvironment:(NSDictionary *)environment{
    [self.preference registerLeomaEnvironment:environment];
    NSBundle * mBundle = bundle ?: [NSBundle mainBundle];
    if(!IOS_FileRequest){//非ios9+的情况需要把bundle拷贝到temp目录方可访问
        mBundle = [NSBundle bundleWithPath:[self cloneInTemporaryDirectory:bundle.bundlePath withSpecifier:@".bundle"]];
    }
    [self loadFileRequest:[mBundle pathForResource:name ofType:extension] rootPath:mBundle.bundlePath];
}

-(void)loadLocalRequest:(NSString *)BaseDir ofEntrance:(NSString *)entrance{
    [self loadLocalRequest:BaseDir ofEntrance:entrance withExternalEnvironment:nil];
}
-(void)loadLocalRequest:(NSString*)baseDir ofEntrance:(NSString*)entrance withExternalEnvironment:(NSDictionary *)environment{
    [self.preference registerLeomaEnvironment:environment];
    if(!IOS_FileRequest){
        baseDir = [self cloneInTemporaryDirectory:baseDir withSpecifier:nil];
    }
    [self loadFileRequest:[NSString stringWithFormat:@"/%@/%@", [baseDir slashTrim], [entrance slashTrim]] rootPath:baseDir];
}

-(void)loadFileRequest:(NSString*)filePath rootPath:(NSString*)rootPath{
    NSURL * url = [NSURL fileURLWithPath:filePath];
    if(IOS_FileRequest) [self loadFileURL:url allowingReadAccessToURL:[NSURL fileURLWithPath:rootPath]];
    else [self loadRequest:[NSURLRequest requestWithURL:url]];
}

//ios 9- 需要将文件或bundle拷贝到temp目录下才可实现本地访问，并且，为了避免过多的拷贝占用存储空间：1、在本webview的生命周期内只存在一个对应的目录，2、在本webview被销毁时清楚对应目录下的文件。
-(NSString*)cloneInTemporaryDirectory:(NSString*)directory withSpecifier:(NSString*)specifier{
    [self clearTemporaryDirectory];
    NSFileManager * copier = [NSFileManager defaultManager];
    NSString* webkitTemp = [NSString stringWithFormat:@"/%@/%@/WebKitTemp", NSTemporaryDirectory().slashTrim, LeomaSpec];
    BOOL isDir;
    if(![copier fileExistsAtPath:webkitTemp isDirectory:&isDir] || !isDir){//文件夹不存在或存在同名文件但不是文件夹
        [copier removeItemAtPath:webkitTemp error:nil];
        [copier createDirectoryAtPath:webkitTemp withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* copyToPath = [NSString stringWithFormat:@"%@/%@%@", webkitTemp, [NSUUID UUID].UUIDString, specifier ?: @""];
    if([copier fileExistsAtPath:copyToPath]) [copier removeItemAtPath:copyToPath error:nil];
    [copier copyItemAtPath:directory toPath:copyToPath error:nil];
    self.clonedDir = copyToPath;
    return copyToPath;
}

-(void)clearTemporaryDirectory{
    [[NSFileManager defaultManager] removeItemAtPath:self.clonedDir error:nil];
}

#pragma WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    BOOL decide = YES;
    if([@"history" isEqualToString:navigationAction.request.URL.scheme]){
        [self webView:webView didStartProvisionalNavigation:nil];
        [self webView:webView didFinishNavigation:nil];
        decide = NO;
    }else if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWeb:shouldStartLoadWithRequest:navigationType:)]){
        decide = [self.leomaWebDelegate leomaWeb:self shouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    }
    if(decide){
        [self injectLeomaScript];
    }
    decisionHandler(decide ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWebDidStartLoad:)])
        [self.leomaWebDelegate leomaWebDidStartLoad:self];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWeb:didFailLoadWithError:isProvisional:)])
        [self.leomaWebDelegate leomaWeb:self didFailLoadWithError:error isProvisional:YES];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWeb:didFailLoadWithError:isProvisional:)])
        [self.leomaWebDelegate leomaWeb:self didFailLoadWithError:error isProvisional:NO];
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWebDidCommitLoad:)])
        [self.leomaWebDelegate leomaWebDidCommitLoad:self];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWebDidFinishLoad:)])
        [self.leomaWebDelegate leomaWebDidFinishLoad:self];
}

-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    NSError * error = [NSError errorWithDomain:NSCocoaErrorDomain
                                          code:0
                                      userInfo:@{NSLocalizedFailureReasonErrorKey : @"WKWebView Content Process Terminated"}];
    [self webView:webView didFailNavigation:nil withError:error];
}
-(NSUInteger)index{
    if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWebIndex)]) return [self.leomaWebDelegate leomaWebIndex];
    return NSNotFound;
}
#pragma WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    if(self.leomaUIDelegate && [self.leomaUIDelegate respondsToSelector:@selector(leomaWeb:alertWithMessage:completion:)]){
        [self.leomaUIDelegate leomaWeb:self alertWithMessage:message completion:completionHandler];
    }
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    if(self.leomaUIDelegate && [self.leomaUIDelegate respondsToSelector:@selector(leomaWeb:confirmWithMessage:completion:)]){
        [self.leomaUIDelegate leomaWeb:self confirmWithMessage:message completion:completionHandler];
    }
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    //Leoma Synchronized Bridge
    LeomaInteractionModel * interAction = [LeomaInteractionModel objectFromDictionary:[prompt JSONToDictionary]];
    if(interAction.legal){
        interAction.WebView = self;
        interAction.Controller = self.controller;
        completionHandler([dispatchLeomaInteractionRequest(interAction) JSONString]);
        return;
    }
    
    //common Prompt
    if(self.leomaUIDelegate && [self.leomaUIDelegate respondsToSelector:@selector(leomaWeb:promptWithMessage:defaultText:completion:)]){
        [self.leomaUIDelegate leomaWeb:self promptWithMessage:prompt defaultText:defaultText completion:completionHandler];
    }
}
#ifdef DEBUG
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
        
    }
}
#endif


#pragma WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //Leoma Synchronized Bridge
    LeomaInteractionModel * interAction = [LeomaInteractionModel objectFromDictionary:message.body];
    interAction.WebView = self;
    interAction.Controller = self.controller;
    if(interAction.legal){
        dispatchLeomaInteractionRequest(interAction);
        return;
    }
}

@end

@implementation WKWebViewConfiguration (LeomaExtension)
-(instancetype)initWithProcessPool:(WKProcessPool *)pool{
    self = [self init];
    if(self){
        self.processPool = pool ?: self.processPool;
    }
    return self;
}
@end
