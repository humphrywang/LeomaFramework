//
//  UIImage+LeomaExtension.h
//  LeomaFramework
//
//  Created by corptest on 14-1-9.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSData+LeomaExtension.h"

@interface UIImage (Leoma)<LeomaBundleProtocol>

+ (UIImage *) imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *) resize:(CGSize)size;

- (UIImage *) stretch;

+ (UIImage *) customImageNamed:(nonnull NSString*)name;

@end
