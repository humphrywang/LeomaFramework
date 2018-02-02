//
//  NSArray+LeomaExtension.m
//  LeomaFramework
//
//  Created by corptest on 14-1-9.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import "NSArray+LeomaExtension.h"

@implementation NSArray (Leoma)

+ (NSArray *) collectWithArray:(NSArray *)array  closureBlock:(id (^)(id obj))closureBlock
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:array.count];
    for (id obj in array) {
        [ret addObject:closureBlock(obj)];
    }
    return ret;
}

- (NSArray *) collectWithClosureBlock:(id (^)(id obj))closureBlock
{
    return [[self class] collectWithArray:self closureBlock:closureBlock];
}

- (id) filteredOneUsingPredicate:(NSPredicate *)predicate
{
    NSArray *array = [self filteredArrayUsingPredicate:predicate];
    if (array.count > 0) {
        return [array objectAtIndex:0];
    }
    return nil;
}

@end

@implementation NSMutableArray (WeakReferences)

+ (id)arrayUsingWeakReferences {
    return [self arrayUsingWeakReferencesWithCapacity:0];
}

+ (id)arrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    // Cast of C pointer type 'CFMutableArrayRef' (aka 'struct __CFArray *') to Objective-C pointer type 'id' requires a bridged cast
    return (id)CFBridgingRelease(CFArrayCreateMutable(0, capacity, &callbacks));
    // return (id)(CFArrayCreateMutable(0, capacity, &callbacks));
}

+ (id)arrayWithPlaceholdersOfCapacity:(NSUInteger)capacity{
    NSMutableArray * array = [NSMutableArray array];
    for(NSUInteger i = 0; i < capacity; i++){
        array[i] = [NSNull null];
    }
    return array;
}
@end

@implementation NSMutableSet (WeakReferences)

+(instancetype)setUsingWeakReferences{
    return [self setUsingWeakReferencesWithCapacity:0];
}

+(instancetype)setUsingWeakReferencesWithCapacity:(NSUInteger)capacity{
    CFSetCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    return (id)CFBridgingRelease(CFSetCreateMutable(0, capacity, &callbacks));
}

@end
