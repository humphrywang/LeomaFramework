//
//  UITouch+LeomaExtension.m
//  LeomaFramework
//
//  Created by CorpDev on 16/5/17.
//
//

#import "UITouch+LeomaExtension.h"

@implementation UITouch (Leoma)

-(CGSize)offsetInView:(UIView*)view{
    CGPoint curPoint = [self locationInView:view];
    CGPoint prePoint = [self previousLocationInView:view];
    return CGSizeMake(curPoint.x - prePoint.x, curPoint.y - prePoint.y);
}
@end
