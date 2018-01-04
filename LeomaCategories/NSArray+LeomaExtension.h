//
//  NSArray+LeomaExtension.h
//  LeomaFramework
//
//  Created by corptest on 14-1-9.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Leoma)

/**
 *  从array中取出某元素的array
 *
 *  @return 元素array
 */
+ (NSArray *) collectWithArray:(NSArray *)array closureBlock:(id (^)(id obj))closureBlock;
- (NSArray *) collectWithClosureBlock:(id (^)(id obj))closureBlock;

/*
 过滤出来一个
 */
- (id) filteredOneUsingPredicate:(NSPredicate *)predicate;

@end

/**
 * 不增加元素的引用计数的'NSMutableArray'
 *
 **/
@interface NSMutableArray (WeakReferences)
+ (id)arrayUsingWeakReferences;
+ (id)arrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity;

+ (id)arrayWithPlaceholdersOfCapacity:(NSUInteger)capacity;

@end
