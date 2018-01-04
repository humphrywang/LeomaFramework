//
//  NSDictionary+LeomaExtension.m
//  LeomaFramework
//
//  Created by corptest on 14-1-6.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import "NSDictionary+LeomaExtension.h"

@implementation NSDictionary (Leoma)

- (id) objectForPath:(NSString *)path
{
    if (!path) {
        return nil;
    }
    
    NSArray *array = [path componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/."]];
    id ret = self;
    for (NSString *key in array) {
        if (!ret) {
            return nil;
        }
        if ([ret isKindOfClass:[NSDictionary class]]) {
            ret = [((NSDictionary *)ret) objectForKey:key];
        } else {
            return nil;
        }
    }
    
    return ret;
}

- (NSString *) parameterDictionaryToQueryString
{
    NSMutableString * queryString = [NSMutableString string];
    for(NSString* key in self.allKeys){
        id object = [self objectForKey:key];
        if(!object || ![object isKindOfClass:[NSString class]]){
            continue;
        }
        [queryString appendFormat:@"&%@=%@", key, object];
    }
    if(queryString.length>0)
        queryString = [queryString substringFromIndex:1];
    return queryString;
}

@end
