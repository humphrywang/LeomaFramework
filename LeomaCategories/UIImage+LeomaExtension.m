//
//  UIImage+LeomaExtension.m
//  LeomaFramework
//
//  Created by corptest on 14-1-9.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import "UIImage+LeomaExtension.h"

@implementation UIImage (Leoma)

+ (UIImage *) imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *) resize:(CGSize)size
{
    // Create a bitmap graphics context
    // This will also set it as the current context
    size = CGSizeMake(size.width>0?size.width:self.size.width, size.height>0?size.height:self.size.height);
    UIGraphicsBeginImageContext(size);
    
    // Draw the scaled image in the current context
    [self drawInRect:(CGRect){0, 0, size.width, size.height}];
    
    // Create a new image from current context
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Pop the current context from the stack
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *) stretch
{
    return [self stretchableImageWithLeftCapWidth:self.size.width / 2 topCapHeight:self.size.height / 2];
}

+ (UIImage *)customImageNamed:(NSString *)name{
    return [self loadFromLeoma:name] ?: [self imageNamed:name];
}

-(void)saveToLeoma:(NSString *)name{
    [UIImagePNGRepresentation(self) saveToLeoma:name];
}

+(instancetype)loadFromLeoma:(NSString *)name{
    return [[UIImage alloc] initWithData:[NSData loadFromLeoma:name] scale:1];
}

+(void)deleteFromLeoma:(NSString *)name{
    [NSData deleteFromLeoma:name];
}

@end
