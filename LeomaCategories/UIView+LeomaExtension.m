//
//  UIView+LeomaExtension.m
//  LeomaFramework
//
//  Created by corptest on 14-1-9.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import "UIView+LeomaExtension.h"

@implementation UIView (Frame)

- (CGFloat) x
{
    return self.frame.origin.x;
}

- (void) setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat) y
{
    return self.frame.origin.y;
}

- (void) setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGPoint) origin
{
    return self.frame.origin;
}

- (void) setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGFloat) width
{
    return self.frame.size.width;
}

- (void) setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat) height
{
    return self.frame.size.height;
}

- (void) setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize) size
{
    return self.frame.size;
}

- (void) setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end

@implementation UIView (Layout)

- (void) clearSubView
{
    NSArray *subs = self.subviews;
    if (subs && subs.count > 0) {
        for (UIView *sub in subs) {
            [sub removeFromSuperview];
        }
    }
}

- (NSArray *) allSubviews
{
    if (self  && self.subviews && self.subviews != 0) {
        NSMutableArray *allSubviews = [NSMutableArray array];
        for (UIView *v in self.subviews) {
            [allSubviews addObject:v];
            NSArray *a = [v allSubviews];
            if (a && a.count != 0) {
                [allSubviews addObjectsFromArray:a];
            }
        }
        return allSubviews;
    }
    return nil;
}

- (NSArray *) sortedInputs
{
    NSMutableArray *canBecomeFirstResponders = [NSMutableArray array];
    NSArray *allSubviews = [self allSubviews];
    for (UIView *v in allSubviews) {
        if ([v isKindOfClass:[UITextField class]] && !v.hidden && v.userInteractionEnabled) {
            UITextField *tf = (UITextField *)v;
            if (tf.enabled) {
                [canBecomeFirstResponders addObject:v];
            }
        }
        
        if ([v isKindOfClass:[UITextView class]] && !v.hidden && v.userInteractionEnabled) {
            UITextView *tv = (UITextView *)v;
            if (tv.editable) {
                [canBecomeFirstResponders addObject:v];
            }
        }
    }
    
    [canBecomeFirstResponders sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UIView *v1 = (UIView *)obj1;
        UIView *v2 = (UIView *)obj2;
        
        CGPoint p1 = [v1 convertPoint:(CGPoint){0, 0} toView:self];
        CGPoint p2 = [v2 convertPoint:(CGPoint){0, 0} toView:self];
        
        if (p1.y < p2.y) {
            return NSOrderedAscending;
        }
        if (p1.y > p2.y) {
            return NSOrderedDescending;
        }
        
        if (p1.x < p2.x) {
            return NSOrderedAscending;
        }
        if (p1.x > p2.x) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    return canBecomeFirstResponders.count == 0 ? nil : canBecomeFirstResponders;
}

- (UIView *) superviewWithClass:(Class)clazz
{
    if ([self.superview isKindOfClass:clazz]) {
        return self;
    }
    if (self.superview) {
        return [self.superview superviewWithClass:clazz];
    }
    return nil;
}

@end

@implementation UIView (NestNib)

+ (instancetype)viewFromNib{
    if([[NSBundle mainBundle] pathForResource:NSStringFromClass(self) ofType:@"nib"]){
        return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
    }
    return nil;
}

- (BOOL) isPlaceHolder{
    return NO;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
    if(self.isPlaceHolder) {
        UIView * receiver = [[self class] viewFromNib];
        if(!receiver) return self;
        receiver.frame = self.frame;
        receiver.translatesAutoresizingMaskIntoConstraints = NO;
        [receiver applyAutolayoutConstrainsOfView:self needApplySuper:NO];
        return receiver;
    }
    return self;
}

- (void)applyAutolayoutConstrainsOfView:(UIView *)placeholderView needApplySuper:(BOOL)applySuper
{
    for (NSLayoutConstraint *constraint in placeholderView.constraints) {
        if(constraint.firstItem != placeholderView || constraint.secondItem != nil) continue;
        [self addConstraint:[UIView duplicateConstraint:constraint to:self and:nil]];
    }
    if(!applySuper) return;
    for (NSLayoutConstraint * constraint in placeholderView.superview.constraints){
        UIView * firstItem, *secondItem;
        if(constraint.firstItem == placeholderView.superview && constraint.secondItem == placeholderView){
            firstItem = placeholderView.superview;
            secondItem = self;
        }else if(constraint.secondItem == placeholderView.superview && constraint.firstItem == placeholderView){
            firstItem = self;
            secondItem = placeholderView.superview;
        }else continue;
        [placeholderView.superview addConstraint:[UIView duplicateConstraint:constraint to:firstItem and:secondItem]];
    }
}

+(NSLayoutConstraint*)duplicateConstraint:(NSLayoutConstraint*)constraint to:(UIView*)firstItem and:(UIView*)secondItem{
    NSLayoutConstraint* newConstraint  = [NSLayoutConstraint constraintWithItem:firstItem
                                                                      attribute:constraint.firstAttribute
                                                                      relatedBy:constraint.relation
                                                                         toItem:secondItem
                                                                      attribute:constraint.secondAttribute
                                                                     multiplier:constraint.multiplier
                                                                       constant:constraint.constant];
    newConstraint.shouldBeArchived = constraint.shouldBeArchived;
    newConstraint.priority = constraint.priority;
    return newConstraint;
}


@end

@implementation NSLayoutConstraint (LeomaExtension)

@end
