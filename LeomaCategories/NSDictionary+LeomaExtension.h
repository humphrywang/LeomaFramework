//
//  NSDictionary+LeomaExtension.h
//  LeomaFramework
//
//  Created by corptest on 14-1-6.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -

#pragma mark -

@interface NSDictionary (Leoma)

- (id) objectForPath:(NSString *)path;
- (NSString *) parameterDictionaryToQueryString;

@end
