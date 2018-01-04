//
//  NSObject+LeomaExtension.m
//  LeomaFramework
//
//  Created by corptest on 14-1-3.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import "NSObject+LeomaExtension.h"
#import "NSDictionary+LeomaExtension.h"
#import <objc/runtime.h>
#import "JSONKit.h"
#import "LeomaClassUtils.h"

@implementation NSObject (Leoma)

- (id) performSelector:(SEL)aSelector withArguments:(id)arg, ...
{
    NSMethodSignature *sig = [self methodSignatureForSelector:aSelector];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:self];
    [inv setSelector:aSelector];
    // 0被target占用，1被selector占用，故参数从2开始
    int index = 2;
    if (arg) {
        [inv setArgument:&arg atIndex:index];
        id argVa;
        va_list args;
        va_start(args, arg);
        while ((argVa = va_arg(args, id))) {
            index ++;
            [inv setArgument:&argVa atIndex:index];
        }
        va_end(args);
        [inv retainArguments];
    }
    [inv invoke];
    id ret = nil;
    [inv getReturnValue:&ret];
    return ret;
}

- (void) performBlock:(void (^)(void))block delay:(NSTimeInterval)delay
{
    block = [block copy];
    [self performSelector:@selector(_doPerformBlock:)
               withObject:block
               afterDelay:delay];
}

- (void) _doPerformBlock:(void (^)(void))block
{
    block();
}

- (BOOL) is:(id)obj
{
    return self == obj;
}

-(id)objectForPathIgnoreSeperator:(NSString*)path{
    if(!path || path.length == 0 || ![self respondsToSelector:@selector(objectForKey:)]) return nil;
    id object = [self performSelector:@selector(objectForKey:) withObject:path];
    if(!object && path.length >= 2){
        NSString * temp = [path endsWith:@"/"] ? [path substringToIndex:path.length-1] : [NSString stringWithFormat:@"%@/", path];
        object = [self performSelector:@selector(objectForKey:) withObject:temp];
    }
    return object;
}

-(id)objectForVirtualPath:(NSString*)path{
    id object = [self objectForPathIgnoreSeperator:path];
    if(!object){
        NSRange range = [path rangeOfString:@"//"];
        if(range.length == 2){
            NSString * virtualPath = [path substringFromIndex:range.location + range.length ];
            object = [self objectForPathIgnoreSeperator:[NSString stringWithFormat:@"//%@", virtualPath]];
            if(!object) object = [self objectForPathIgnoreSeperator:[NSString stringWithFormat:@"http://%@", virtualPath]];
            if(!object) object = [self objectForPathIgnoreSeperator:[NSString stringWithFormat:@"https://%@", virtualPath]];
        }
    }
    return object;
}

@end

@implementation NSObject (Deserialization)

+ (NSArray *) objectsFromArray:(NSArray *)array
{
    if (nil == array) {
        return nil;
    }
    
    if (NO == [array isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray * results = [NSMutableArray array];
    __strong NSObject *obj;
    for (obj in (NSArray *)array) {
        [results addObject:[self objectFromDictionary:obj]];
    }
    
    return results;
}

+ (instancetype) objectFromDictionary:(id)dic{
    if (nil == dic) {
        return nil;
    }
    Class clazz = [self class];
    if([clazz isSubclassOfClass:[NSDictionary class]]) return dic;
    id object = [[clazz alloc] init];
    if (nil == object) {
        return nil;
    }
    unsigned int        propertyCount = 0;
    objc_property_t *   properties = class_copyPropertyList(clazz, &propertyCount);
    for(int i = 0; i< propertyCount; i++){
        NSString * propertyKey = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        Class propertyClass = [LeomaClassUtils classWithPropertyName:propertyKey inClass:clazz];
        
        NSObject *tmpValue = [dic objectForKey:propertyKey];
        LeomaClassType type = [LeomaClassUtils typeWithObject:tmpValue];
        id value = nil;
        if (tmpValue) {
            if (type == LeomaClassType_Int_NSInteger) {
                value = @([tmpValue asNSInteger]);
            } else if (type == LeomaClassType_Long) {
                value = @([tmpValue asLong]);
            } else if (type == LeomaClassType_Long_Long) {
                value = @([tmpValue asLongLong]);
            } else if (type == LeomaClassType_Float_CGFloat) {
                value = @([tmpValue asFloat]);
            } else if (type == LeomaClassType_Double) {
                value = @([tmpValue asDouble]);
            } else if (type == LeomaClassType_NSNumber) {
                value = [tmpValue asNSNumber];
            } else if (type == LeomaClassType_NSString) {
                value = [tmpValue asNSString];
            } else if (type == LeomaClassType_NSDate) {
                value = [tmpValue asNSDate];
            } else if (type == LeomaClassType_NSArray) {
                SEL sel = NSSelectorFromString([NSString stringWithFormat:@"GenericClassOf%@", propertyKey]);
                if([clazz respondsToSelector:sel]){
                    Class (*imp) (Class, SEL) = (void*)[clazz methodForSelector:sel];
                    Class convertClass = imp(clazz, sel);
                    value = [convertClass objectsFromArray:tmpValue];
                }else value = [tmpValue asNSArray];
            } else if (type == LeomaClassType_NSDictionary) {
                if(propertyClass == [NSDictionary class] || !propertyClass){
                    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"GenericClassOf%@", propertyKey]);
                    if([clazz respondsToSelector:sel]){
                        Class (*imp) (Class, SEL) = (void*)[clazz methodForSelector:sel];
                        Class convertClass = imp(clazz, sel);
                        NSMutableDictionary * convertDic = [NSMutableDictionary dictionary];
                        [(NSDictionary*)tmpValue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                            [convertDic setObject:[convertClass objectFromDictionary:obj] forKey:key];
                        }];
                        value = convertDic;
                    }else value = tmpValue;
                }
                else value = [propertyClass objectFromDictionary:tmpValue];
            } else if (type == LeomaClassType_Object) {
                if([tmpValue isKindOfClass:propertyClass]) value = tmpValue;
                else value = [propertyClass objectFromDictionary:[tmpValue asNSDictionary]];
            }
        }
        if(value) {
            [object setValue:value forKey:propertyKey];
        }
    }
    if(properties) free(properties);
    return object;
}

@end

@implementation NSObject (UserDefault)

- (void) saveToUserDefaultForKey:(NSString *)key
{
    [[self class] userDefaultWriteObject:self forKey:key];
}

+ (void) userDefaultWriteObject:(id)obj forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id) userDefaultRead:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void) userDefaultRemove:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


@implementation NSObject (TypeConversion)

- (NSInteger) asNSInteger
{
    return ((NSString *)self).integerValue;
}

- (long) asLong
{
    return (long)((NSString *)self).longLongValue;
}

- (long) asLongLong
{
    return ((NSString *)self).longLongValue;
}

- (float) asFloat
{
    return ((NSString *)self).floatValue;
}

- (double) asDouble
{
    return ((NSString *)self).doubleValue;
}

- (BOOL) asBool
{
	return [[self asNSNumber] boolValue];
}

- (NSNumber *) asNSNumber
{
	if ([self isKindOfClass:[NSNumber class]]) {
		return (NSNumber *)self;
	} else if ([self isKindOfClass:[NSString class]]) {
		return [NSNumber numberWithInteger:[(NSString *)self integerValue]];
	} else if ([self isKindOfClass:[NSDate class]]) {
		return [NSNumber numberWithDouble:[(NSDate *)self timeIntervalSince1970]];
	} else if ([self isKindOfClass:[NSNull class]]) {
		return [NSNumber numberWithInteger:0];
	}
    
	return nil;
}

- (NSString *) asNSString
{
	if ( [self isKindOfClass:[NSNull class]] )
		return nil;
    
	if ( [self isKindOfClass:[NSString class]] )
	{
		return (NSString *)self;
	}
	else if ( [self isKindOfClass:[NSData class]] )
	{
		NSData * data = (NSData *)self;
		return [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
	}
    else if ( [self isKindOfClass:[NSDictionary class]] ){
        return [self JSONString];
    }
	else
	{
		return self.description;
	}
}

- (NSDate *) asNSDate
{
	if ( [self isKindOfClass:[NSDate class]] )
	{
		return (NSDate *)self;
	}
	else if ( [self isKindOfClass:[NSString class]] )
	{
		NSDate * date = nil;
        
		if ( nil == date )
		{
			NSString * format = @"yyyy-MM-dd HH:mm:ss z";
			NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			NSString * format = @"yyyy/MM/dd HH:mm:ss z";
			NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			NSString * format = @"yyyy-MM-dd HH:mm:ss";
			NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			NSString * format = @"yyyy/MM/dd HH:mm:ss";
			NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		return date;
	}
	else
	{
		return [NSDate dateWithTimeIntervalSince1970:[self asNSNumber].doubleValue];
	}
	
	return nil;
}

- (NSData *) asNSData
{
	if ( [self isKindOfClass:[NSString class]]) {
		return [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	}
	else if ( [self isKindOfClass:[NSData class]] )
	{
		return (NSData *)self;
	}
    
	return nil;
}

- (NSArray *) asNSArray
{
	if ( [self isKindOfClass:[NSArray class]] )
	{
		return (NSArray *)self;
	}
	else
	{
		return [NSArray arrayWithObject:self];
	}
}

- (NSString *) JSONString
{
    id dic = [self asNSDictionary];
    if ([dic isKindOfClass:[NSDictionary class]] ||[dic isKindOfClass:[NSArray class]]) {
        return [dic JSONString];
    }
    if ([dic isKindOfClass:[NSString class]]) {
        return dic;
    }
    return nil;
}

- (NSData *) JSONData{
    return [[self asNSDictionary] JSONData];
}

- (id) asNSDictionary
{
	if ([self isKindOfClass:[NSNumber class]]) {
        return self;
    }
    if ([self isKindOfClass:[NSString class]]) {
        return self;
    }
    if ([self isKindOfClass:[NSDate class]]) {
        return self;
    }
    if ([self isKindOfClass:[NSArray class]]) {
        NSMutableArray *a1 = [NSMutableArray arrayWithCapacity:((NSArray *)self).count];
        for (id obj in (NSArray *)self) {
            [a1 addObject:[obj asNSDictionary]];
        }
        return a1;
    }
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *d1 = [NSMutableDictionary dictionaryWithCapacity:((NSDictionary *)self).count];
        for (id key in [((NSDictionary *)self) allKeys]) {
            [d1 setObject:[[((NSDictionary *)self) objectForKey:key] asNSDictionary]
                   forKey:key];
        }
        return d1;
    }
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
    for (int i = 0; i < propertyCount; i ++) {
        const char * name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:propertyName];
        NSInteger type = [LeomaClassUtils typeWithObject:value];
        id result = nil;
        if (type == LeomaClassType_NSArray) {
            if ([value isKindOfClass:[NSArray class]]) {
                NSMutableArray *a1 = [NSMutableArray arrayWithCapacity:((NSArray *)value).count];
                for (id obj in (NSArray *)value) {
                    [a1 addObject:[obj asNSDictionary]];
                }
                result = a1;
            } else {
                result = value;
            }
        } else if (type == LeomaClassType_NSDictionary) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *d1 = [NSMutableDictionary dictionaryWithCapacity:((NSDictionary *)value).count];
                for (id key in [((NSDictionary *)value) allKeys]) {
                    [d1 setObject:[[((NSDictionary *)value) objectForKey:key] asNSDictionary]
                           forKey:key];
                }
                result = d1;
            } else {
                result = value;
            }
        } else if (type == LeomaClassType_Unknow) {
            if ([value isKindOfClass:[NSObject class]]) {
                result = [value asNSDictionary];
            } else {
                result = value;
            }
        } else if (type == LeomaClassType_Object) {
            result = [value asNSDictionary];
        } else {
            result = value;
        }
        if (value) {
            [dic setObject:result forKey:propertyName];
        }
    }
    return dic;
}

@end

@implementation NSObject (AssociateProp)

-(NSMutableDictionary*)categoryProps{
    NSMutableDictionary * props = objc_getAssociatedObject(self, @"category_props");
    if(!props){
        props = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @"category_props", props, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return props;
}
@end
