//
//  UIViewController+LeomaTransition.h
//  LeomaFramework
//
//  Created by CorpDev on 2018/1/31.
//
#import "LeomaTransitionFeature.h"

@interface UIViewController (LeomaTransition)

///this represents a typical animation the transition will take, this only determine the animation performance
@property (assign, nonatomic) LeomaTransitionPerformace animatedStyle;

@end
