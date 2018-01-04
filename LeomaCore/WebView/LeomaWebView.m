//
//  LeomaWebView.m
//  Leoma
//
//  Created by CorpDev on 5/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import "LeomaWebView.h"
#import "LeomaWKWebView.h"
#import "LeomaUIWebView.h"
#import "Leoma.h"
#import "LeomaWebViewPreference.h"

@interface LeomaWebView()

@end

@implementation LeomaWebView

+(instancetype)webViewWithFrame:(CGRect)frame withConfig:(LeomaCoreConfig*)config withController:(UIViewController*)controller{
    config = config ?: [LeomaCoreConfig defaultConfig];
    LeomaWebViewPreference * preference = [[LeomaWebViewPreference alloc] initWithConfig:config];
    if(preference.webKitInside){
        return [[LeomaWKWebView alloc] initWithFrame:frame withPreference:preference withController:controller];
    }else{
        return [[LeomaUIWebView alloc] initWithFrame:frame withPreference:preference withController:controller];
    }
}
+(instancetype)webViewWithFrame:(CGRect)frame withController:(UIViewController*)controller{
    return [self webViewWithFrame:frame withConfig:nil withController:controller];
}

@end
