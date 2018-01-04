//
//  LeomaWebView.h
//  Leoma
//
//  Created by CorpDev on 5/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeomaWebProtocol.h"

@class LeomaCoreConfig;
@interface LeomaWebView : LeomaWebCore
+(instancetype)webViewWithFrame:(CGRect)frame withConfig:(LeomaCoreConfig*)config withController:(UIViewController*)controller;
+(instancetype)webViewWithFrame:(CGRect)frame withController:(UIViewController*)controller;

@end
