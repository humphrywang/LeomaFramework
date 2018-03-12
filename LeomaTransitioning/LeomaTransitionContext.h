//
//  LeomaTransitionContext.h
//  LeomaFramework
//
//  Created by CorpDev on 2018/1/8.
//

#import <Foundation/Foundation.h>
#import "LeomaTransitionFeature.h"

@interface LeomaTransitionContext : NSObject <UIViewControllerContextTransitioning>
///this indicates whether the animator will animate the transition or not, this prop is immodifiable.
@property(nonatomic, readonly) BOOL animated;
///this represents a typical action the transition will take, this dosnt determine the animation will take
@property(nonatomic, readonly) LeomaTransitionAction action;
///this indicates whether the transition will do presenting or dismissing.
@property(nonatomic, readonly) BOOL present;
///this indicates whether the transition will perform immediately or should perform after notified;
@property(nonatomic) BOOL immediately;
///this indicates whether the animation will perform a reverse animation.
@property(nonatomic) BOOL reverse;

-(instancetype)init NS_UNAVAILABLE;

-(instancetype)initWithFromViewController:(UIViewController*)fromViewController
                         toViewController:(UIViewController*)toViewController
                            transitAction:(LeomaTransitionAction)action
                           transitPresent:(BOOL)present NS_DESIGNATED_INITIALIZER;

@end
