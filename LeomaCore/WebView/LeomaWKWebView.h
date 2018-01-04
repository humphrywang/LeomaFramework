//
//  LeomaWKWebView.h
//  Leoma
//
//  Created by CorpDev on 5/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@class LeomaWebViewPreference;
@protocol LeomaWebViewProtocol;

@interface LeomaWKWebView : WKWebView<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, LeomaWebViewProtocol>

-(instancetype)initWithFrame:(CGRect)frame withPreference:(LeomaWebViewPreference*)preference withController:(UIViewController*)controller;

@end
