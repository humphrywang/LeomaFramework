//
//  UIView+LeomaExtension.h
//  LeomaFramework
//
//  Created by corptest on 14-1-9.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

- (CGFloat) x;

- (void) setX:(CGFloat)x;

- (CGFloat) y;

- (void) setY:(CGFloat)y;

- (CGPoint) origin;

- (void) setOrigin:(CGPoint)origin;

- (CGFloat) width;

- (void) setWidth:(CGFloat)width;

- (CGFloat) height;

- (void) setHeight:(CGFloat)height;

- (CGSize) size;

- (void) setSize:(CGSize)size;

@end

@interface UIView (Layout)

- (void) clearSubView;

- (NSArray *) allSubviews;

/**
 *  得到所有的可输入的view
 *
 *  @return 从上到下，从左到右的可输入的view的集合
 */
- (NSArray *) sortedInputs;

- (UIView *) superviewWithClass:(Class)clazz;

@end

@interface UIView (NestNib)

+ (instancetype) viewFromNib;
- (void) applyAutolayoutConstrainsOfView:(UIView *)placeholderView;
- (BOOL) isPlaceHolder;//判定当前实例是否是nib构建时生成的placeholder

@end

@interface NSLayoutConstraint (LeomaExtension)

@end
