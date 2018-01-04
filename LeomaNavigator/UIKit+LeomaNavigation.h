//
//  UIKit+LeomaNavigation.h
//  Pods
//
//  Created by CorpDev on 21/8/17.
//
//

#import <Foundation/Foundation.h>
#import "LeomaNavigationProtocol.h"

@class LeomaNavigationViewController;
@interface LeomaNavigation : NSObject
+(LeomaNavigationViewController*)activeRoot;
+(UIViewController*)rootViewController;
+(UIViewController*)currentViewController;
+(void)makeCurrentViewControllerRoot;//如果当前vc是modal型的，会设置modal前的最后一个vc为root
+(CGFloat)navigationBarHeight;

+(void)saveImageToLeoma:(NSData*)data scale:(int)scale;
@end



@interface LeomaNavigationBarBridge : NSObject
@property (strong, nonatomic) id left;
@property (copy, nonatomic) NSArray<id> * right;
@property (assign, nonatomic) LeomaNavigationBarStyle style;
@property (copy, nonatomic) NSString * title;
@end

@interface UIViewController (LeomaNavigation)<LeomaNavigationSceneDelegate>
//Leoma 导航链中，此vc的下一元素
@property (readonly, nullable, nonatomic) UIViewController* prioViewController;
//Leoma 导航链中，此vc的上一元素
@property (readonly, nullable, nonatomic) UIViewController* postViewController;
@property (readonly, nonatomic) BOOL isActive;

@property (assign, nonatomic) LeomaNavigationAction action;
@property (assign, nonatomic) LeomaNavigationPolicy policy;
@property (assign, nonatomic) LeomaNavigationBarBridge* bridge;

-(void)updateLeftGuide:(NSString*)guide NS_REQUIRES_SUPER;

#pragma mark LeomaNavigation LifeCircle Delegates
-(void)viewMaybeAppear;
-(void)viewMaybeDisappear;
-(void)viewHasAppear:(BOOL)animated NS_REQUIRES_SUPER;
-(void)viewHasDisappear:(BOOL)animated NS_REQUIRES_SUPER;

#pragma mark 压入显示ViewController
-(void)presentViewController:(UIViewController *)viewControllerToPresent
                     options:(LeomaNavigationOption)flag
                  completion:(void(^)(BOOL))completion;
#pragma mark 弹出隐藏ViewController
-(void)dismissViewController:(UIViewController*)viewControllerDismissTo
                     options:(LeomaNavigationOption)flag
                  completion:(void (^)(BOOL))completion;
-(void)dismissViewController:(LeomaNavigationOption)flag
                  completion:(void (^)(BOOL))completion;

@end

@interface UIView (LeomaNavigation)
#pragma mark 蒙版操作
-(void)maskIn:(BOOL)silent;
-(void)maskOut:(BOOL)silent;

@property (assign, nonatomic) LeomaMaskStyle maskStyle;//弹出的view所指定的mask样式，默认参照<LeomaMaskStyle>的默认值
@property (assign, nonatomic) LeomaMaskAction maskAction;//弹出的view所指定的mask事件响应，默认参照<LeomaMaskAction>的默认值
@property (assign, nonatomic) LeomaTransformOption maskEffectP;//弹出的view在显示时的效果，默认参照<LeomaTransformOption>的默认值
@property (assign, nonatomic) LeomaTransformOption maskEffectD;//弹出的view在隐藏时的效果，默认参照<LeomaTransformOption>的默认值
@property (assign, nonatomic) LeomaMaskLayer maskLayer;//弹出的view所在的层级，默认参照<LeomaMaskLayer>的默认值，同层级值，后入的在上

@end
void EffectiveUI(void(^block)(), void(^completion)(BOOL), NSTimeInterval duration, NSTimeInterval delay);
