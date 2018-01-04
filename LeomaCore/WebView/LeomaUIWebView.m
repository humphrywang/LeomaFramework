//
//  LeomaUIWebView.m
//  Leoma
//
//  Created by CorpDev on 5/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import "LeomaUIWebView.h"
#import "LeomaWebProtocol.h"
#import "Leoma.h"
#import "LeomaWebViewPreference.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define LeomaCore @"LeomaCore"
@protocol LeomaJSCoreProtocol <JSExport>
JSExportAs(Invoke, -(id)Invoke:(NSDictionary*)params);

@end

@interface LeomaJSCore :NSObject<LeomaJSCoreProtocol>
@property (weak, nonatomic) LeomaWebCore * webView;
@property (weak, nonatomic) UIViewController * controller;
- (instancetype)initWithWebView:(LeomaWebCore*)webView WithController:(UIViewController *)controller;
@end

@implementation LeomaJSCore

- (instancetype)initWithWebView:(LeomaWebCore*)webView WithController:(UIViewController *)controller{
    self = [super init];
    if (self) {
        self.webView = webView;
        self.controller = controller;
    }
    return self;
}

-(NSDictionary*)Invoke:(NSDictionary *)params{
    LeomaInteractionModel * interAction = [LeomaInteractionModel objectFromDictionary:params];
    interAction.WebView = self.webView;
    interAction.Controller = self.controller;
    if(interAction.legal) return [dispatchLeomaInteractionRequest(interAction) asNSDictionary];
    return nil;
}

@end

@interface LeomaUIWebView()

@property (nonatomic, weak) id<LeomaWebDelegate> leomaWebDelegate;
@property (nonatomic, weak) id<LeomaUIDelegate> leomaUIDelegate;
@property (nonatomic, strong) JSContext * jsCore;
@property (nonatomic, strong) NSString * UID;
@property (nonatomic, weak) UIViewController * controller;

@property (nonatomic, strong) LeomaWebViewPreference* preference;

//UIDelegate Alert
@property (atomic, assign) BOOL alertLocked;
- (void)webView:(UIWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
- (BOOL)webView:(UIWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
- (NSString*)webView:(UIWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString*)defaultText initiatedByFrame:(id)frame;

@end
#define UIKitIdentifier @"uikit_uid"

@implementation LeomaUIWebView
-(void)indicateWebView{
    self.UID = [[NSUUID UUID] UUIDString];
    NSString * UA = [[NSUserDefaults standardUserDefaults] objectForKey:@"User-Agent"];
    NSRange range = [UA rangeOfString:UIKitIdentifier];
    if(range.length > 0 && range.location > 0) UA = [UA substringToIndex:range.location - 1];
    UA = [NSString stringWithFormat:@"%@,%@=%@", UA, UIKitIdentifier, self.UID];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": UA, @"User-Agent": UA}];
}

-(instancetype)initWithFrame:(CGRect)frame withPreference:(LeomaWebViewPreference *)preference withController:(UIViewController *)controller{
    self = [super initWithFrame:frame];
    if(self){
        self.controller = controller;
        self.delegate = self;
        self.preference = preference;
        [self commonInit];
        [self indicateWebView];
    }
    return self;
}

-(void)commonInit{
    //Notification
    [self registerNotifications];
    //scroll config
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    if(IOS_11_OR_LATER){
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    self.scrollView.bounces = NO;
    //JS Sync Core
    self.jsCore = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsCore[LeomaCore] = [[LeomaJSCore alloc] initWithWebView:self WithController:self.controller];
    self.jsCore.exceptionHandler = ^(JSContext *context, JSValue *exception){
    
    };
}

-(void)registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInteraction:) name:LeomaInterActionURLProtocol object:nil];
}

-(void)onInteraction:(NSNotification*)notification{
    if(![notification.object isKindOfClass:[LeomaInteractionModel class]]) return;
    LeomaInteractionModel * model = (LeomaInteractionModel*)notification.object;
    if(!model.Protocol) return;
    if([model.UA rangeOfString:self.UID].length <= 0) return;
    
    model.WebView = self;
    model.Controller = self.controller;
    NSDictionary *headers = @{@"Access-Control-Allow-Origin" : @"*", @"Access-Control-Allow-Headers" : @"Content-Type"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:model.Protocol.request.URL statusCode:200 HTTPVersion:@"1.1" headerFields:headers];
    [model.Protocol.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    dispatchLeomaInteractionRequest(model);
}

-(void)predealloc{
    
}

#pragma mark Private APIs

-(void)injectLeomaScript{
    [self executeJS:self.preference.InjectScript];
}

#pragma LeomaWebViewProtocol
-(void)executeJS:(NSString *)script{
    if([NSString isBlank:script]) return;
    leoma_dispatch_main(^{
        [self stringByEvaluatingJavaScriptFromString:script];
    });
}

-(void)loadRemoteRequest:(NSURLRequest*)request withExternalEnvironment:(NSDictionary *)environment{
    [self.preference registerLeomaEnvironment:environment];
    if([request.URL isFileURL]) NSLog(@"Must not be FileURL");
    else [self loadRequest:request];
}
-(void)loadBundleRequest:(NSString*)name OfExtension:(NSString*)extension OfBundle:(NSBundle*)bundle withExternalEnvironment:(NSDictionary *)environment{
    [self.preference registerLeomaEnvironment:environment];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", LocalHost , [bundle pathForResource:name ofType:extension].slashTrim]];
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)loadLocalRequest:(NSString*)baseDir ofEntrance:(NSString*)entrance withExternalEnvironment:(NSDictionary *)environment{
    [self.preference registerLeomaEnvironment:environment];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@/%@", LocalHost , [baseDir slashTrim], [entrance slashTrim]]];
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}
-(void)loadRemoteRequest:(NSURLRequest *)request{
    [self loadRemoteRequest:request withExternalEnvironment:nil];
}
-(void)loadBundleRequest:(NSString *)name OfExtension:(NSString *)extension OfBundle:(NSBundle *)bundle{
    [self loadBundleRequest:name OfExtension:extension OfBundle:bundle withExternalEnvironment:nil];
}
-(void)loadLocalRequest:(NSString *)BaseDir ofEntrance:(NSString *)entrance{
    [self loadLocalRequest:BaseDir ofEntrance:entrance withExternalEnvironment:nil];
}

#pragma UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if([@"history" isEqualToString:request.URL.scheme]){
        [self webViewDidStartLoad:nil];
        [self webViewDidFinishLoad:nil];
        return NO;
    }else if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWeb:shouldStartLoadWithRequest:navigationType:)]){
        return [self.leomaWebDelegate leomaWeb:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    if(webView) [self injectLeomaScript];
    if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWebDidStartLoad:)])
        [self.leomaWebDelegate leomaWebDidStartLoad:self];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWebDidFinishLoad:)])
        [self.leomaWebDelegate leomaWebDidFinishLoad:self];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWeb:didFailLoadWithError:isProvisional:)])
        [self.leomaWebDelegate leomaWeb:self didFailLoadWithError:error isProvisional:NO];
}

-(NSUInteger)index{
    if(self.leomaWebDelegate && [self.leomaWebDelegate respondsToSelector:@selector(leomaWebIndex)]) return [self.leomaWebDelegate leomaWebIndex];
    return NSNotFound;
}

#pragma mark AlertView
-(void)blockedAlert{
    while(self.alertLocked){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    if(self.alertLocked) return;
    if(self.leomaUIDelegate && [self.leomaUIDelegate respondsToSelector:@selector(leomaWeb:alertWithMessage:completion:)]){
        self.alertLocked = YES;
        [self.leomaUIDelegate leomaWeb:self alertWithMessage:message completion:^{
            self.alertLocked = NO;
        }];
        [self blockedAlert];
    }
}

- (BOOL)webView:(UIWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    if(self.alertLocked) return NO;
    if(self.leomaUIDelegate && [self.leomaUIDelegate respondsToSelector:@selector(leomaWeb:confirmWithMessage:completion:)]){
        self.alertLocked = YES;
        __block BOOL result = NO;
        [self.leomaUIDelegate leomaWeb:self confirmWithMessage:message completion:^(BOOL output) {
            result = output;
            self.alertLocked = NO;
        }];
        [self blockedAlert];
        return result;
    }
    return NO;
}

- (NSString*)webView:(UIWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString*)defaultText initiatedByFrame:(id)frame{
    //Leoma Synchronized Bridge
    LeomaInteractionModel * interAction = [LeomaInteractionModel objectFromDictionary:[prompt JSONToDictionary]];
    interAction.WebView = self;
    interAction.Controller = self.controller;
    if(interAction.legal) return [dispatchLeomaInteractionRequest(interAction) JSONString];
    
    //Script Inject
    if([prompt isEqualToString:self.UID]){
        return self.preference.InjectScript;
    }
    
    //common Prompt
    if(self.alertLocked) return nil;
    if(self.alertLocked && [self.leomaUIDelegate respondsToSelector:@selector(leomaWeb:promptWithMessage:defaultText:completion:)]){
        self.alertLocked = YES;
        __block NSString * result = nil;
        [self.leomaUIDelegate leomaWeb:self promptWithMessage:prompt defaultText:defaultText completion:^(NSString * output) {
            result = output;
            self.alertLocked = NO;
        }];
        [self blockedAlert];
        return result;
    }
    return nil;
}
@end
