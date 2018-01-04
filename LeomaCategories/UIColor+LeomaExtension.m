//
//  UIColor+LeomaExtension.m
//  LeomaFramework
//
//  Created by corptest on 16/1/12.
//
//

#import "UIColor+LeomaExtension.h"
NSString *const LeomaBackground = @"background";
NSString *const LeomaForeground = @"foreground";
NSString *const LeomaForegroundS = @"foregroundS";

@implementation UIColor (Leoma)

+(UIColor*)backGroundGray{
    return UIColorFromRGB(0xdfe4ea);
}


+(UIColor*)textGrayColor{
    return UIColorFromRGB(0x666666);
}

+(UIColor *)leomaBackground{
    NSInteger colorHex = [self leomaColorHexForKey:LeomaBackground];
    if(colorHex == NSNotFound) colorHex = 0xffffff;
    return UIColorFromRGB(colorHex);
}
+(UIColor *)leomaForeground{
    NSInteger colorHex = [self leomaColorHexForKey:LeomaForeground];
    if(colorHex == NSNotFound) colorHex = 0x333333;
    return UIColorFromRGB(colorHex);
}
+(UIColor *)leomaForegroundS{
    NSInteger colorHex = [self leomaColorHexForKey:LeomaForeground];
    if(colorHex == NSNotFound) colorHex = 0x666666;
    return UIColorFromRGB(colorHex);
}

+(NSInteger)leomaColorHexForKey:(NSString*)key{
    if([NSString isBlank:key]) return NSNotFound;
    NSNumber * number = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"leoma_bar_%@", key]];
    return number ? number.integerValue : NSNotFound;
}

+(void)setLeomaColor:(NSInteger)colorHex forKey:(NSString *)key{
    NSString * leomaKey = [NSString stringWithFormat:@"leoma_bar_%@", key];
    if(colorHex == NSNotFound) [[NSUserDefaults standardUserDefaults] removeObjectForKey:leomaKey];
    else [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:colorHex] forKey:[NSString stringWithFormat:@"leoma_bar_%@", key]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation CALayer (Leoma)

-(void)setBorderIBColor:(UIColor*)color{
    [self setBorderColor:color.CGColor];
}
-(void)setShadowIBColor:(UIColor*)color{
    [self setShadowColor:color.CGColor];
}

@end
