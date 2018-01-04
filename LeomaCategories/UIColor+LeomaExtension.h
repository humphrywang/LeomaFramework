//
//  UIColor+LeomaExtension.h
//  LeomaFramework
//
//  Created by corptest on 16/1/12.
//
//

#import <UIKit/UIKit.h>
extern NSString *const LeomaBackground;
extern NSString *const LeomaForeground;
extern NSString *const LeomaForegroundS;

#ifndef UIColor_Leoma_h
#define UIColor_Leoma_h

#define RGBCOLOR(r,g,b) \
[UIColor colorWithRed:r/256.f green:g/256.f blue:b/256.f alpha:1.f]

#define RGBACOLOR(r,g,b,a) \
[UIColor colorWithRed:r/256.f green:g/256.f blue:b/256.f alpha:a]

#define UIColorFromRGB(rgbValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

#define UIColorFromRGBA(rgbValue, alphaValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#endif

@interface UIColor (Leoma)

+(UIColor*)backGroundGray;
+(UIColor*)textGrayColor;

+(UIColor*)leomaBackground;
+(UIColor*)leomaForeground;
+(UIColor*)leomaForegroundS;

+(void)setLeomaColor:(NSInteger)colorHex forKey:(NSString*)key;

@end

@interface CALayer (Leoma)

@property (nonatomic, assign) UIColor* shadowIBColor;
@property (nonatomic, assign) UIColor* borderIBColor;

@end
