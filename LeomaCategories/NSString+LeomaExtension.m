//
//  NSString+LeomaExtension.m
//  LeomaFramework
//
//  Created by corptest on 14-1-3.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import "NSString+LeomaExtension.h"
#import <CommonCrypto/CommonDigest.h>
#import "LeomaNumberUtils.h"

@implementation NSString (Leoma)

+ (BOOL) isBlank:(NSString *)str
{
    return str == [NSNull null] || str == nil || str.length == 0;
}

+ (BOOL) isNotBlank:(NSString *)str
{
    return ![NSString isBlank:str];
}

- (NSDictionary *) queryStringToParameterDictionary
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    if ([NSString isBlank:self]) {
        return ret;
    }
    NSArray *keyValues = [self componentsSeparatedByString:@"&"];
    for (NSString *keyValue in keyValues) {
        NSArray *kv = [keyValue componentsSeparatedByString:@"="];
        if (kv && kv.count == 2) {
            [ret setObject:[kv objectAtIndex:1] forKey:[kv objectAtIndex:0]];
        }
    }
    return ret;
}

- (BOOL) isEmail
{
	NSString *		regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL) isUrl
{
    NSString *		regex = @"http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL) isIPAddress
{
	NSArray *			components = [self componentsSeparatedByString:@"."];
	NSCharacterSet *	invalidCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
	
	if ( [components count] == 4 ) {
		NSString *part1 = [components objectAtIndex:0];
		NSString *part2 = [components objectAtIndex:1];
		NSString *part3 = [components objectAtIndex:2];
		NSString *part4 = [components objectAtIndex:3];
		
		if ( [part1 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part2 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part3 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part4 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound ) {
			if ( [part1 intValue] < 255 &&
                [part2 intValue] < 255 &&
                [part3 intValue] < 255 &&
                [part4 intValue] < 255 ) {
				return YES;
			}
		}
	}
	
	return NO;
}

- (BOOL) isEqualToStringIgnoreCase:(NSString *)aString
{
    return [[self lowercaseString] isEqualToString:[aString lowercaseString]];
}

/**
 *  去除json中的空格，回车，注释
 *
 *  @return 格式化后的json字符串
 */
- (NSString *) formatToJsonString
{
    UIWebView *_wv = [[UIWebView alloc] init];
    NSString *_ret = [_wv stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"(function(){var _json=%@;return JSON.stringify(_json);})();", self]];
    return _ret;
}

- (NSDictionary *) JSONToDictionary{
    NSError * error = nil;
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    return (!error && !error.domain) ? dict : [NSDictionary dictionary];
}

- (BOOL) isInteger
{
    return [LeomaNumberUtils isInteger:self];
}

- (BOOL) isLongLong
{
    return [LeomaNumberUtils isLongLong:self];
}

- (BOOL) isFloat
{
    return [LeomaNumberUtils isFloat:self];
}

- (BOOL) isDouble
{
    return [LeomaNumberUtils isDouble:self];
}

- (NSString*) lastToken{
    return [self substringWithRange:NSMakeRange(self.length-1, 1)];
}

- (BOOL)endsWith:(NSString*)token{
    if(!token || token.length == 0 || token.length > self.length) return NO;
    NSRange range = NSMakeRange(self.length - token.length, token.length);
    return [token isEqualToStringIgnoreCase:[self substringWithRange:range]];
}

- (BOOL)startsWith:(NSString*)token{
    if(!token || token.length == 0 || token.length > self.length) return NO;
    NSRange range = [self rangeOfString:token options:NSCaseInsensitiveSearch];
    return range.location == 0 && range.length == token.length;
}

- (NSString*) urlDecode{
    return (__bridge_transfer NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
}

- (NSString*) urlEncode{
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL, CFSTR("!*'(){};:@&=+$,/?%#[]\" "), kCFStringEncodingUTF8);
}

- (BOOL)isEqualToStringIgnoreSeperator:(NSString *)aString{
    if(!aString) return false;
    BOOL equals = [self isEqualToStringIgnoreCase:aString];
    if(equals) return equals;
    NSString * temp = [self endsWith:@"/"] ? (self.length >= 1 ? [self substringToIndex:self.length - 1] : self) : [NSString stringWithFormat:@"%@/", self];
    return [temp isEqualToStringIgnoreCase:aString];
}

- (NSArray*)componentsOfLine{
    if([self rangeOfString:@"\r\n"].length>0) return [self componentsSeparatedByString:@"\r\n"];
    else return [self componentsSeparatedByString:@"\n"];
}

- (NSString*)slashTrim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
}

- (NSString*)blankTrim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \r\n"]];
}

@end
