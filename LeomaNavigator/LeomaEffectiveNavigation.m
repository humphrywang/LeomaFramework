//
//  LeomaEffectiveTransform.m
//  Pods
//
//  Created by CorpDev on 16/8/17.
//
//

#import "LeomaEffectiveNavigation.h"
#import "UIKit+LeomaNavigation.h"

@implementation LeomaNavigationConfig
+(instancetype)configFromOptions:(LeomaNavigationOption)flag{
    LeomaNavigationConfig * config = [[LeomaNavigationConfig alloc] init];
    config.present = YES;
    config.accept = YES;
    config.reverse = (flag & LeomaNavigationOptionReverse) == LeomaNavigationOptionReverse;
    config.now = (flag & LeomaNavigationOptionNotify) == LeomaNavigationOptionNow;
    
    return config;
}

-(void)setPresent:(BOOL)present{
    _reverse = _present ^ present ? !_reverse : _reverse;
    _present = present;
}

-(BOOL)animated{
    return YES && self.action != LeomaNavigationActionTab;
}

@end

@implementation LeomaEffectiveNavigation

+(void)orgainzeViewLayer:(LeomaNavigationConfig *)config{
    UIView * presenting = config.presentingVC.view;
    UIView * dismissing = config.dismissingVC.view;
    UIView * container = presenting.superview ?: dismissing.superview;
    [container addSubview:dismissing];
    [presenting removeFromSuperview];
    if(!dismissing){
        [container addSubview:presenting];
    }else if(config.reverse){
        [container insertSubview:presenting belowSubview:dismissing];
    }else{
        [container insertSubview:presenting aboveSubview:dismissing];
    }
}

+(CGPoint)orgainzeReceivedPoint:(CGPoint)position{
    CGFloat x = position.x;
    CGFloat y = position.y;
    if(x > Screen_Width) x = Screen_Width;
    if(x < 0) x = 0;
    if(y< 0) y = 0;
    if(y > Screen_Height) y = Screen_Height;
    return CGPointMake(x, y);
}

+(void)prepareNavigation:(LeomaNavigationConfig *)config{
    if(!config) return;
    [self orgainzeViewLayer:config];

    CGRect prepareFrame; CGFloat x, y;
    CGFloat yOffset = [self contentYOffset:config.presentingVC];
    switch (config.action) {
        case LeomaNavigationActionPush:
            x = config.reverse ? - Screen_Width / 2 : Screen_Width;
            y = yOffset;
            break;
        case LeomaNavigationActionModal:
            x = 0;
            y = config.reverse ? yOffset : Screen_Height + yOffset;
            break;
        case LeomaNavigationActionTab:
            x = 0;
            y = yOffset;
            break;
    }
    config.presentingVC.view.frame = CGRectMake(x, y, [LeomaSystem screenBounds].size.width, [LeomaSystem screenBounds].size.height - yOffset);
    [config.presentingVC.view layoutIfNeeded];
    [config.presentingVC.view.layer removeAllAnimations];
}

+(void)performNavigation:(LeomaNavigationConfig *)config{
    CGPoint target;
    if(config.reverse){
        target = CGPointMake(Screen_Width, Screen_Height);
    }else{
        target = CGPointZero;
    }
    [self performNavigation:target OfConfig:config];
}

+(void)performNavigation:(CGPoint)position OfConfig:(LeomaNavigationConfig *)config{
    position = [self orgainzeReceivedPoint:position];
    switch (config.action) {
        case LeomaNavigationActionPush:
        {
            UIView * leftView = config.reverse ? config.presentingVC.view : config.dismissingVC.view;
            UIView * rightView = !config.reverse ? config.presentingVC.view : config.dismissingVC.view;
            [self performPushNavigation:position.x / Screen_Width leftView:leftView Rightview:rightView];
            break;
        }
        case LeomaNavigationActionModal:
        {
            UIView * overlay = config.reverse ? config.dismissingVC.view : config.presentingVC.view;
            [self performModalNavigation:position.y / Screen_Height overlay:overlay barOffset:[self contentYOffset:config.presentingVC]];
            break;
        }
        case LeomaNavigationActionTab:
        {
            [self performTabNavigation:position.x / Screen_Width overlay:config.presentingVC.view];
            break;
        }
    }
}

+(void)finishNavigation:(LeomaNavigationConfig *)config{
    
}

+(void)performPushNavigation:(CGFloat)rate leftView:(UIView*)left Rightview:(UIView*)right{
    left.x = (rate - 1 ) * Screen_Width / 2;
    right.x = rate * Screen_Width;
}

+(void)performModalNavigation:(CGFloat)rate overlay:(UIView*)overlay barOffset:(CGFloat)offset{
    overlay.y = rate * Screen_Height + offset;
}

+(void)performTabNavigation:(CGFloat)rate overlay:(UIView*)overlay{
    return;
}

+(CGFloat)contentYOffset:(UIViewController*)vc{
    return vc.bridge.style == LeomaNavigationBarLinear ? LeomaNavigation.navigationBarHeight : 0;
}
@end
