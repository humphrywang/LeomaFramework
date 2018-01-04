//
//  LeomaUIWebView.h
//  Leoma
//
//  Created by CorpDev on 5/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIWebView.h>
#import "LeomaWebProtocol.h"

@class LeomaWebViewPreference;
@interface LeomaUIWebView : UIWebView<UIWebViewDelegate, LeomaWebViewProtocol>

-(instancetype)initWithFrame:(CGRect)frame withPreference:(LeomaWebViewPreference*)preference withController:(UIViewController*)controller;
@end
