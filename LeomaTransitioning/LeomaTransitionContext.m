//
//  LeomaTransitionContext.m
//  LeomaFramework
//
//  Created by CorpDev on 2018/1/8.
//

#import "LeomaTransitionContext.h"

@interface LeomaTransitionContext()

@property (nonatomic, strong) NSDictionary * transitionViewControllers;
@property (readonly) CGRect activeInitialFrame;
@property (readonly) CGRect activeFinalFrame;
@property (readonly) CGRect inactiveInitialFrame;
@property (readonly) CGRect inactiveFinalFrame;

@property (readonly) CGRect CGRectFullScreen;
// push
@property (readonly) CGRect CGRectFullScreenRight;
@property (readonly) CGRect CGRectFullScreenLeft;
// modal
@property (readonly) CGRect CGRectFullScreenBottom;



@end

@implementation LeomaTransitionContext

-(instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController transitAction:(LeomaTransitionAction)action transitPresent:(BOOL)present{
    self = [super init];
    if(self){
        self.transitionViewControllers = @{
                                           UITransitionContextFromViewControllerKey: fromViewController ?: [NSNull null],
                                           UITransitionContextToViewControllerKey: toViewController ?: [NSNull null]
                                           };
        _action = action;
        _present = present;
        _immediately = YES;
//        _performance = action;
        _reverse = NO;
    }
    return self;
}
#pragma mark UIViewControllerContextTransitioning

-(UIViewController *)viewControllerForKey:(UITransitionContextViewControllerKey)key{
    return [self.transitionViewControllers objectForKey:key];
}

-(UIView *)viewForKey:(UITransitionContextViewKey)key{
    if([key isEqualToString:UITransitionContextFromViewKey]){
        return [[self viewControllerForKey:UITransitionContextFromViewControllerKey] view];
    }
    if([key isEqualToString:UITransitionContextToViewKey]){
        return [[self viewControllerForKey:UITransitionContextToViewControllerKey] view];
    }
    return nil;
}

-(CGRect)initialFrameForViewController:(UIViewController *)vc{
    if(vc == [self viewControllerForKey:UITransitionContextFromViewControllerKey]){
        return self.activeInitialFrame;
    }else if(vc == [self viewControllerForKey:UITransitionContextToViewControllerKey]){
        return self.inactiveInitialFrame;
    }
    return CGRectNull;
}

-(CGRect)finalFrameForViewController:(UIViewController *)vc{
    if(vc == [self viewControllerForKey:UITransitionContextToViewControllerKey]){
        return self.activeFinalFrame;
    }else if(vc == [self viewControllerForKey:UITransitionContextToViewControllerKey]){
        return self.inactiveFinalFrame;
    }
    return CGRectNull;
}

-(UIView *)containerView{
    return nil;
}

#pragma mark end

#pragma mark APIs

#pragma mark end

-(CGRect)activeInitialFrame{
    return self.CGRectFullScreen;
}

-(CGRect)activeFinalFrame{
    return self.CGRectFullScreen;
}

-(CGRect)inactiveInitialFrame{
    BOOL presenting = self.present ^ self.reverse;
//    switch (self.performance) {
//        case LeomaTransitionPerformaceTabbedDefault:
//            return self.CGRectFullScreen;
//        case LeomaTransitionPerformanceHorizontalDefault:
//            return presenting ? self.CGRectFullScreenRight : self.CGRectFullScreenLeft;
//        case LeomaTransitionPerformaceVerticalDefault:
            return presenting ? self.CGRectFullScreenBottom : self.CGRectFullScreen;
//    }
}

-(CGRect)inactiveFinalFrame{
    BOOL presenting = self.present ^ self.reverse;
//    switch (self.performance) {
//        case LeomaTransitionPerformaceTabbedDefault:
//            return self.CGRectFullScreen;
//        case LeomaTransitionPerformanceHorizontalDefault:
//            return presenting ? self.CGRectFullScreenLeft : self.CGRectFullScreenRight;
//        case LeomaTransitionPerformaceVerticalDefault:
            return presenting ? self.CGRectFullScreen : self.CGRectFullScreenBottom;
//    }
}

-(CGRect)CGRectFullScreen{
    return CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
}

-(CGRect)CGRectFullScreenLeft{
    return CGRectMake(- 0.5 * self.containerView.frame.size.width, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
}

-(CGRect)CGRectFullScreenRight{
    return CGRectMake(self.containerView.frame.size.width, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
}

-(CGRect)CGRectFullScreenBottom{
    return CGRectMake(0, self.containerView.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height);
}

@end
