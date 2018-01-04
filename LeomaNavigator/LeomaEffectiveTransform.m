//
//  LeomaEffectiveTransform.m
//  CorpTravel
//
//  Created by CorpDev on 31/8/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import "LeomaEffectiveTransform.h"

@interface LeomaEffectiveOption : NSObject
@property (assign, nonatomic) LeomaTransformOption direction;
@property (assign, nonatomic) CGFloat duration;
@property (assign, nonatomic) BOOL inBox;
@property (assign, nonatomic) BOOL fade;
@property (assign, nonatomic) BOOL spring;
@property (assign, nonatomic) BOOL scaleInOut;
+(instancetype)optionsOf:(LeomaTransformOption)flag;
@end

@implementation UIView (LeomaEffectiveTransform)

-(void)transInWithOption:(LeomaTransformOption)flag delay:(NSTimeInterval)delay completion:(void(^)(BOOL))completion{
    LeomaEffectiveOption * option = [LeomaEffectiveOption optionsOf:flag];
    if(option.scaleInOut){
        [self transInScaled:option delay:delay completion:completion];
    }else{
        [self transInDirected:option delay:delay completion:completion];
    }
    
}
-(void)transOutWithOption:(LeomaTransformOption)flag delay:(NSTimeInterval)delay completion:(void(^)(BOOL))completion{
    LeomaEffectiveOption * option = [LeomaEffectiveOption optionsOf:flag];
    if(option.scaleInOut){
        [self transOutScaled:option delay:delay completion:completion];
    }else{
        [self transOutDirected:option delay:delay completion:completion];
    }
}
-(void)transInWithOption:(LeomaTransformOption)flag delay:(NSTimeInterval)delay{
    [self transInWithOption:flag delay:delay completion:nil];
}
-(void)transOutWithOption:(LeomaTransformOption)flag delay:(NSTimeInterval)delay{
    [self transOutWithOption:flag delay:delay completion:nil];
}
-(void)transInWithOption:(LeomaTransformOption)flag{
    [self transInWithOption:flag delay:0 completion:nil];
}
-(void)transOutWithOption:(LeomaTransformOption)flag{
    [self transOutWithOption:flag delay:0 completion:nil];
}

-(void)transInDirected:(LeomaEffectiveOption *)option delay:(NSTimeInterval)delay completion:(void(^)(BOOL))completion{
    CGPoint position = self.layer.position;
    self.layer.position = [self positionOfTransfrom:option.direction isInBox:option.inBox];
    self.hidden = NO;
    CGFloat alpha = self.alpha;
    self.alpha = option.fade ? 0 : 1;
    [UIView animateWithDuration:option.duration
                          delay:delay
         usingSpringWithDamping:option.spring ? 0.8 : 1
          initialSpringVelocity:2
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.layer.position = position;
                         self.alpha = alpha;
                     } completion:completion];
}
-(void)transOutDirected:(LeomaEffectiveOption *)option delay:(NSTimeInterval)delay completion:(void(^)(BOOL))completion{
    self.hidden = NO;
    CGFloat alpha = self.alpha;
    [UIView animateWithDuration:option.duration
                          delay:delay
         usingSpringWithDamping:option.spring ? 0.8 : 1
          initialSpringVelocity:2
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.layer.position = [self positionOfTransfrom:option.direction isInBox:option.inBox];
                         if(option.fade) self.alpha = 0;
                     } completion:^(BOOL finished){
                         if(completion) completion(YES);
                         self.alpha = alpha;
                     }];
}

-(void)transInScaled:(LeomaEffectiveOption*)option delay:(NSTimeInterval)delay completion:(void(^)(BOOL))completion{
    [self performAnimation:^{
        CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        keyframeAnimation.duration = option.duration;
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        keyframeAnimation.values = values;
        [self.layer addAnimation:keyframeAnimation forKey:nil];
    } completion:completion duration:option.duration delay:delay];
}

-(void)transOutScaled:(LeomaEffectiveOption*)option delay:(NSTimeInterval)delay completion:(void(^)(BOOL))completion{
    [self performAnimation:^{
        CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        keyframeAnimation.duration = option.duration;
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
        keyframeAnimation.values = values;
        [self.layer addAnimation:keyframeAnimation forKey:nil];
    } completion:completion duration:option.duration delay:delay];
}

-(void)performAnimation:(void(^)(void))animation completion:(void(^)(BOOL))completion duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay{
    if(animation){
        leoma_dispatch_main_delay(animation, delay);
    }
    if(completion){
        leoma_dispatch_main_delay(^{
            completion(YES);
        }, delay + duration);
    }
}

-(CGPoint)positionOfTransfrom:(LeomaTransformOption)direction isInBox:(BOOL)inBox{
    CGPoint position = self.layer.position;
    CGPoint anchor = self.layer.anchorPoint;
    CGSize layerSize = self.layer.bounds.size;
    CGSize superSize = self.superSize;
    
    CGFloat x = direction == LeomaTransformOptionDirectionLeading ? layerSize.width * (anchor.x - (inBox ? 0 : 1)) :
                direction == LeomaTransformOptionDirectionTrailing ? layerSize.width * (anchor.x - (inBox ? 1 : 0) ) + superSize.width : position.x;
    CGFloat y = direction == LeomaTransformOptionDirectionTop ? layerSize.height * (anchor.y - (inBox ? 0 : 1)):
                direction == LeomaTransformOptionDirectionBottom ? layerSize.height * (anchor.y - (inBox ? 1 : 0)) + superSize.height : position.y;
    return CGPointMake(x , y);
}
-(CGSize)superSize{
    UIView * superView = self.superview;
    if(!superView) return CGSizeZero;
    CGSize size = superView.bounds.size;
    if(size.height + size.width > 0) return size;
    superView = superView.superview;
    if(!superView) return size;
    return superView.bounds.size;
}
@end


@implementation LeomaEffectiveOption

+(instancetype)optionsOf:(LeomaTransformOption)flag{
    LeomaEffectiveOption * option = [[LeomaEffectiveOption alloc] init];
    option.direction = flag % 0x10;
    option.duration = (flag >> 4) % 0x10;
    if(option.duration == 0) option.duration = 0.2;
    else if(option.duration == 1) option.duration = 0.3;
    else option.duration = (option.duration - 1) * 0.5;
    option.inBox = (flag >> 8) % 0x10;
    option.fade = !((flag >> 12) % 0x10);
    option.spring = ((flag >> 16) % 0x10);
    option.scaleInOut = option.direction == LeomaTransformOptionDirectionStay && option.spring;
    return option;
}

@end
