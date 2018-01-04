//
//  LeomaNumberUtils.m
//  LeomaFrameWork
//
//  Created by CorpDev on 14-5-19.
//
//

#import "LeomaNumberUtils.h"

@implementation LeomaNumberUtils

+ (BOOL) isInteger:(id)obj
{
    NSScanner *scanner = [NSScanner scannerWithString:[obj description]];
    int i;
    return [scanner scanInt:&i] && [scanner isAtEnd];
}

+ (BOOL) isLongLong:(id)obj
{
    NSScanner *scanner = [NSScanner scannerWithString:[obj description]];
    long long ll;
    return [scanner scanLongLong:&ll] && [scanner isAtEnd];
}

+ (BOOL) isFloat:(id)obj
{
    NSScanner *scanner = [NSScanner scannerWithString:[obj description]];
    float f;
    return [scanner scanFloat:&f] && [scanner isAtEnd];
}

+ (BOOL) isDouble:(id)obj
{
    NSScanner *scanner = [NSScanner scannerWithString:[obj description]];
    double d;
    return [scanner scanDouble:&d] && [scanner isAtEnd];
}

@end
