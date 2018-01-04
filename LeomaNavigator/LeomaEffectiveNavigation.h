//
//  LeomaEffectiveTransform.h
//  Pods
//
//  Created by CorpDev on 16/8/17.
//
//

#import <Foundation/Foundation.h>
#import "LeomaNavigationProtocol.h"

@interface LeomaNavigationConfig : NSObject

@property (assign, nonatomic) LeomaNavigationAction action;
@property (assign, nonatomic) BOOL now;//<YES>是否立即navi
@property (assign, nonatomic) BOOL reverse;//<NO>是否反转动画
@property (assign, nonatomic) BOOL present;
@property (assign, nonatomic) BOOL accept;
@property (readonly)          BOOL animated;
@property (copy, nonatomic) void(^completion)(BOOL success);
@property (strong, nonatomic) UIViewController * dismissingVC;
@property (strong, nonatomic) UIViewController * presentingVC;

+(instancetype)configFromOptions:(LeomaNavigationOption)flag;
@end

@interface LeomaEffectiveNavigation : NSObject

+(void)prepareNavigation:(LeomaNavigationConfig*)config;
+(void)performNavigation:(LeomaNavigationConfig*)config;
+(void)performNavigation:(CGPoint)position OfConfig:(LeomaNavigationConfig*)config;
+(void)finishNavigation:(LeomaNavigationConfig*)config;
@end

