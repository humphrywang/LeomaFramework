//
//  UIKit+LeomaNavigation.m
//  Pods
//
//  Created by CorpDev on 21/8/17.
//
//

#import "UIKit+LeomaNavigation.h"
#import "LeomaNavigationViewController.h"
#import "LeomaEffectiveTransform.h"
#import <objc/runtime.h>
#import "NSObject+LeomaExtension.h"

@implementation UIViewController(LeomaNavigation)
-(UIViewController*)prioViewController{
    return [LeomaNavigation.activeRoot prioViewControllerOf:self];
}

-(UIViewController*)postViewController{
    return [LeomaNavigation.activeRoot postViewControllerOf:self];
}

-(BOOL)isActive{
    return LeomaNavigation.currentViewController == self;
}

-(void)viewMaybeAppear{}
-(void)viewMaybeDisappear{}
-(void)viewHasAppear:(BOOL)animated{}
-(void)viewHasDisappear:(BOOL)animated{}
-(void)updateLeftGuide:(NSString *)guide{
    if(self.isActive){
        [LeomaNavigation.activeRoot updateLeftGuide:guide];
    }
}

AssociateCategoryNumber(action, Action, LeomaNavigationAction)
AssociateCategoryNumber(policy, Policy, LeomaNavigationPolicy)
AssociateCategoryObject(bridge, Bridge, LeomaNavigationBarBridge)
-(BOOL)onNavigationBarItemClicked:(NSInteger)index withStyle:(LeomaBarItemStyle)style withContent:(NSString *)content{
    return NO;
}

#pragma presenting
-(void)presentViewController:(UIViewController *)viewControllerToPresent options:(LeomaNavigationOption)flag completion:(void (^)(BOOL))completion{
    [LeomaNavigation.activeRoot presentViewController:viewControllerToPresent options:flag completion:completion];
}

#pragma dismissing
-(void)dismissViewController:(LeomaNavigationOption)flag completion:(void (^)(BOOL))completion{
    [LeomaNavigation.activeRoot dismissViewController:flag completion:completion];
}
-(void)dismissViewController:(UIViewController *)viewControllerDismissTo options:(LeomaNavigationOption)flag completion:(void (^)(BOOL))completion{
    [LeomaNavigation.activeRoot dismissViewController:viewControllerDismissTo options:flag completion:completion];
}

#pragma mark 蒙版操作
-(void)showMaskPage:(UIView *)maskView enableUserInteraction:(BOOL)enableUI clearPrevContent:(BOOL)clearPrev{
    [LeomaNavigation.activeRoot showMaskPage:maskView enableUserInteraction:enableUI clearPrevContent:clearPrev];
}
-(void)hideMaskPage:(NSTimeInterval)delay{
    [LeomaNavigation.activeRoot hideMaskPage:delay];
}
#pragma LeomaNaviBarDelegate
@end

@implementation UIView (LeomaNavigation)

-(void)maskIn:(BOOL)silent{
    [LeomaNavigation.activeRoot presentMask:self silent:silent];
}

-(void)maskOut:(BOOL)silent{
    [LeomaNavigation.activeRoot dismissMask:self silent:silent];
}
AssociateCategoryNumber(maskStyle, MaskStyle, LeomaMaskStyle)
AssociateCategoryNumber(maskAction, MaskAction, LeomaMaskAction)
AssociateCategoryNumber(maskEffectP, MaskEffectP, LeomaTransformOption)
AssociateCategoryNumber(maskEffectD, MaskEffectD, LeomaTransformOption)
AssociateCategoryNumber(maskLayer, MaskLayer, LeomaMaskLayer)
@end
@implementation LeomaNavigation
+(LeomaNavigationViewController*)activeRoot{
    UIViewController* naviRoot = [UIApplication sharedApplication].delegate.window.rootViewController;
    return [naviRoot isKindOfClass:[LeomaNavigationViewController class]] ? (LeomaNavigationViewController *)naviRoot : nil;
}
+(UIViewController *)rootViewController{
    return self.activeRoot.rootViewController;
}
+(UIViewController *)currentViewController{
    return self.activeRoot.currentViewController;
}
+(void)makeCurrentViewControllerRoot{
    [self.activeRoot makeCurrentViewControllerRoot];
}

+(CGFloat)navigationBarHeight{
    if(Is_iPhone_5_8inch) return 44 + 44;
    if(IOS_6_OR_EARLIER) return 44;
    return 64;
}

+(void)saveImageToLeoma:(NSData *)data name:(NSString*)name scale:(int)scale{

}
@end
@implementation LeomaNavigationBarBridge
-(void)setLeft:(id)left{
    _left = left;
    [[LeomaNavigation activeRoot] navigationBarAreaModified:LeomaNavigationBarAreaLeft WithBridge:self];
}
-(void)setRight:(NSArray<id> *)right{
    _right = right;
    [[LeomaNavigation activeRoot] navigationBarAreaModified:LeomaNavigationBarAreaRight WithBridge:self];
}
-(void)setTitle:(NSString *)title{
    _title = title;
    [[LeomaNavigation activeRoot] navigationBarAreaModified:LeomaNavigationBarAreaCenter WithBridge:self];
}
@end
void EffectiveUI(void(^block)(), void(^completion)(BOOL), NSTimeInterval duration, NSTimeInterval delay){
    if(!block) return;
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:block
                     completion:completion];
}
