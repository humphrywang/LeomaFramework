//
//  NSObject+LeomaExtension.h
//  LeomaFramework
//
//  Created by corptest on 14-1-3.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Leoma)

// 执行多参数的方法
- (id) performSelector:(SEL)aSelector withArguments:(id)arg, ... NS_REQUIRES_NIL_TERMINATION;

- (void) performBlock:(void (^)(void))block delay:(NSTimeInterval)delay;

- (BOOL) is:(id)obj;

//忽视path末尾的</>，如ct.ctrip.com/m/与ct.ctrip.com/m获取到相同的结果
-(id)objectForPathIgnoreSeperator:(NSString*)path;

//忽视Path协议，目前包括http://、https://、//
-(id)objectForVirtualPath:(NSString*)path;

@end

#undef	CONVERT_PROPERTY_CLASS
#define	CONVERT_PROPERTY_CLASS( __name, __class ) \
    + (Class)convertPropertyClassFor_##__name \
    { \
        return NSClassFromString( [NSString stringWithUTF8String:#__class] ); \
    }

@interface NSObject (Deserialization)
/**
 *  将多个dictionary转换为多个指定对象
 *
 */
+ (NSArray *) objectsFromArray:(NSArray *)array;

/**
 *  将dictionary转换为指定对象
 *
 */
+ (id) objectFromDictionary:(id)dic;

@end

@interface NSObject (UserDefault)

- (void) saveToUserDefaultForKey:(NSString *)key;

+ (void) userDefaultWriteObject:(id)obj forKey:(NSString *)key;

+ (id) userDefaultRead:(NSString *)key;

+ (void) userDefaultRemove:(NSString *)key;

@end


@interface NSObject (TypeConversion)

- (NSInteger) asNSInteger;

- (long) asLong;

- (long) asLongLong;

- (float) asFloat;

- (double) asDouble;

- (BOOL) asBool;

- (NSNumber *) asNSNumber;

- (NSString *) asNSString;

- (NSDate *) asNSDate;

- (NSData *) asNSData;

- (NSArray *) asNSArray;

- (NSString *) JSONString;

- (NSData *) JSONData;

- (NSDictionary *) asNSDictionary;

@end

@interface NSObject (AssociateProp)
#define AssociateCategoryNumber(LKey, UKey, type)\
-(void)set##UKey:(type)LKey{\
if(LKey == NSNotFound) [[self categoryProps] removeObjectForKey:@#LKey];\
else [[self categoryProps] setObject:@(LKey) forKey:@#LKey];\
}\
-(type)LKey{\
NSNumber * prop = [[self categoryProps] objectForKey:@#LKey];\
return prop ? prop.integerValue : 0;\
}\

#define AssociateCategoryObject(LKey, UKey, Clazz)\
-(void)set##UKey:(Clazz*)LKey{\
if(!LKey) [[self categoryProps] removeObjectForKey:@#LKey];\
else [[self categoryProps] setObject:LKey forKey:@#LKey];\
}\
-(Clazz*)LKey{\
Clazz * LKey = [[self categoryProps] objectForKey:@#LKey];\
if(!LKey){\
LKey = [[Clazz alloc] init];\
self.LKey = LKey;\
}\
return LKey;\
}
-(NSMutableDictionary*)categoryProps;
@end
