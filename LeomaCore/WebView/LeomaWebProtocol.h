//
//  LeomaWebProtocol.h
//  Leoma
//
//  Created by CorpDev on 5/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LeomaWebNavigationType) {
    LeomaWebNavigationLinkClicked,
    LeomaWebNavigationFormSubmitted,
    LeomaWebNavigationBackForward,
    LeomaWebNavigationReload,
    LeomaWebNavigationResubmitted,
    LeomaWebNavigationOther
};

typedef NS_ENUM(NSUInteger, LeomaCoreEffect){
    /**
     *  ios 8+  : WebKit
     *  ios 8-  : UIKit
     */
    LeomaCoreEffectVisual,
    /**
     *  UIKit
     */
    LeomaCoreEffectNormal
};

typedef NS_ENUM(NSUInteger, LeomaCoreSync){
    /**
     *  WebKit          : Prompt
     *  UIKit(iOS7+)    : JSContext
     *  UIKit(iOS7-)    : Prompt
     **/
    LeomaCoreSyncVisual,
    /**
     * Prompt
     */
    LeomaCoreSyncNormal
};

typedef NS_ENUM(NSUInteger, LeomaCoreAsync){
    /**
     *  WebKit  : ScriptController
     *  UIKit   : Ajax
     */
    LeomaCoreAsyncVisual,
    /**
     *  WebKit          : Prompt
     *  UIKit(iOS7+)    : JSContext
     *  UIKit(iOS7-)    : Ajax
     */
    LeomaCoreAsyncNormal,
    /**
     *  WebKit  : ScriptController
     *  UIKit   : Prompt
     */
    LeomaCoreAsyncExtern
};

@protocol LeomaUIDelegate;
@protocol LeomaWebDelegate;
@protocol LeomaWebViewProtocol;
typedef UIView<LeomaWebViewProtocol> LeomaWebCore;

@protocol LeomaWebViewProtocol

@property (weak, nonatomic, readonly) UIViewController * controller;

@property (assign, nonatomic, readonly) NSUInteger index;

-(void)executeJS:(NSString*)script;

-(BOOL)canGoBack;
-(void)goBack;

-(void)loadRemoteRequest:(NSURLRequest*)request withExternalEnvironment:(NSDictionary*)environment;
-(void)loadBundleRequest:(NSString*)name OfExtension:(NSString*)extension OfBundle:(NSBundle*)bundle withExternalEnvironment:(NSDictionary*)environment;
-(void)loadLocalRequest:(NSString*)BaseDir ofEntrance:(NSString*)entrance withExternalEnvironment:(NSDictionary*)environment;

-(void)loadRemoteRequest:(NSURLRequest*)request;
-(void)loadBundleRequest:(NSString*)name OfExtension:(NSString*)extension OfBundle:(NSBundle*)bundle;
-(void)loadLocalRequest:(NSString*)BaseDir ofEntrance:(NSString*)entrance;

-(void)stopLoading;

-(void)setLeomaUIDelegate:(id<LeomaUIDelegate>)delegate;
-(void)setLeomaWebDelegate:(id<LeomaWebDelegate>)delegate;

-(void)predealloc;

@end

@protocol LeomaWebDelegate <NSObject>

@optional
- (NSUInteger)leomaWebIndex;
- (BOOL)leomaWeb:(LeomaWebCore*)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(LeomaWebNavigationType)navigationType;//decide whether to block request or to keep on loading.
- (void)leomaWebDidStartLoad:(LeomaWebCore*)webView;//request started
- (void)leomaWebDidCommitLoad:(LeomaWebCore*)webView;//dom start render
- (void)leomaWebDidFinishLoad:(LeomaWebCore*)webView;//dom rendered
- (void)leomaWeb:(LeomaWebCore*)webView didFailLoadWithError:(NSError *)error isProvisional:(BOOL)isProvisional;

@end

@protocol LeomaUIDelegate <NSObject>

@optional
- (void)leomaWeb:(LeomaWebCore *)webView alertWithMessage:(NSString *)message completion:(void (^)(void))handler;
- (void)leomaWeb:(LeomaWebCore *)webView confirmWithMessage:(NSString *)message completion:(void (^)(BOOL))handler;
- (void)leomaWeb:(LeomaWebCore *)webView promptWithMessage:(NSString *)message defaultText:(NSString *)defaultText completion:(void (^)(NSString *))handler;

@end
