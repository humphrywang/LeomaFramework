//
//  LeomaEffectiveTransform.h
//  CorpTravel
//
//  Created by CorpDev on 31/8/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeomaNavigationProtocol.h"

@interface UIView (LeomaEffectiveTransform)
-(void)transInWithOption:(LeomaTransformOption)flag;
-(void)transInWithOption:(LeomaTransformOption)flag delay:(NSTimeInterval)delay;
-(void)transInWithOption:(LeomaTransformOption)flag delay:(NSTimeInterval)delay completion:(void(^)(BOOL))completion;

-(void)transOutWithOption:(LeomaTransformOption)flag;
-(void)transOutWithOption:(LeomaTransformOption)flag delay:(NSTimeInterval)delay;
-(void)transOutWithOption:(LeomaTransformOption)flag delay:(NSTimeInterval)delay completion:(void(^)(BOOL))completion;

@end
