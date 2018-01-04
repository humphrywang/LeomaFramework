//
//  LeomaClassUtils.m
//  LeomaFramework
//
//  Created by CorpDev on 14-5-2.
//
//

#import "LeomaClassUtils.h"
#import <objc/runtime.h>
#import "NSString+LeomaExtension.h"
#import "LeomaNumberUtils.h"

NSString *const LeomaClassPropertyNameKey        = @"LeomaClassPropertyNameKey";
NSString *const LeomaClassPropertyTypeKey        = @"LeomaClassPropertyTypeKey";
NSString *const LeomaClassPropertyColumnNameKey  = @"LeomaClassPropertyColumnNameKey";

@implementation LeomaClassUtils

+ (NSArray *) propertiesInClass:(Class)class
{
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList(class, &propertyCount);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:propertyCount];
    for (int i = 0; i < propertyCount; i ++) {
        const char * name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        const char * attr = property_getAttributes(properties[i]);
        LeomaClassType type = [self typeOf:attr];
        [propertyArray addObject:@{
                                   LeomaClassPropertyNameKey : propertyName,
                                   LeomaClassPropertyTypeKey : @(type)
                                   }];
    }
    if (properties) {
        free(properties);
    }
    return propertyArray;
}

+ (LeomaClassType) typeWithPropertyName:(NSString *)_propertyName
                            inClass:(Class)class
{
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList(class, &propertyCount);
    for (int i = 0; i < propertyCount; i ++) {
        const char * name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        if ([propertyName isEqualToStringIgnoreCase:_propertyName]) {
            const char * attr = property_getAttributes(properties[i]);
            return [self typeOf:attr];
        }
    }
    return LeomaClassType_Unknow;
}

+ (LeomaClassType) typeWithObject:(id)obj
{
    if (!obj || [obj isKindOfClass:[NSNull class]]) {
        return LeomaClassType_Null;
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return LeomaClassType_NSString;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        if ([LeomaNumberUtils isInteger:obj]) {
            return LeomaClassType_Int_NSInteger;
        }
        if ([LeomaNumberUtils isLongLong:obj]) {
            return LeomaClassType_Long_Long;
        }
        if ([LeomaNumberUtils isFloat:obj]) {
            return LeomaClassType_Float_CGFloat;
        }
        if ([LeomaNumberUtils isDouble:obj]) {
            return LeomaClassType_Double;
        }
        return LeomaClassType_NSNumber;
    }
    if ([obj isKindOfClass:[NSArray class]]) {
        return LeomaClassType_NSArray;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return LeomaClassType_NSDictionary;
    }
    if ([obj isKindOfClass:[NSObject class]]) {
        return LeomaClassType_Object;
    }
    return LeomaClassType_Unknow;
}

+ (Class) classWithPropertyName:(NSString *)propertyName
                        inClass:(Class)inClass
{
    Class clazz = nil;
    unsigned int        propertyCount = 0;
    objc_property_t *   properties = class_copyPropertyList(inClass, &propertyCount);
    for (int i = 0; i < propertyCount; i ++) {
        const char *    name = property_getName(properties[i]);
        NSString *      pn = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        if ([propertyName isEqualToString:pn]) {
            const char *    attr = property_getAttributes(properties[i]);
            clazz = [self classWithPropertAttributes:attr];
            break;
        }
    }
    
    if (properties) {
        free(properties);
    }
    return clazz;
}

#pragma mark - private

+ (Class) classWithPropertAttributes:(const char *)attr
{
	if ( attr[0] != 'T' )
		return nil;
	
	const char * type = &attr[1];
	if ( type[0] == '@' )
	{
		if ( type[1] != '"' )
			return nil;
		
		char typeClazz[128] = { 0 };
		
		const char * clazz = &type[2];
		const char * clazzEnd = strchr( clazz, '"' );
		
		if ( clazzEnd && clazz != clazzEnd )
		{
			unsigned int size = (unsigned int)(clazzEnd - clazz);
			strncpy( &typeClazz[0], clazz, size );
		}
		
		return NSClassFromString([NSString stringWithUTF8String:typeClazz]);
	}
	
	return nil;
}

+ (LeomaClassType) typeOf:(const char *)attr
{
    if (attr[0] != 'T') {
		return LeomaClassType_Unknow;
    }
	
	const char * type = &attr[1];
	if (type[0] == '@') {
        if ( type[1] != '"' )
			return LeomaClassType_Unknow;
		
		char typeClazz[128] = { 0 };
		
		const char * clazz = &type[2];
		const char * clazzEnd = strchr( clazz, '"' );
		
		if ( clazzEnd && clazz != clazzEnd )
		{
			unsigned int size = (unsigned int)(clazzEnd - clazz);
			strncpy( &typeClazz[0], clazz, size );
		}
		
		if ( 0 == strcmp((const char *)typeClazz, "NSNumber") )
		{
			return LeomaClassType_NSNumber;
		}
		else if ( 0 == strcmp((const char *)typeClazz, "NSString") )
		{
			return LeomaClassType_NSString;
		}
		else if ( 0 == strcmp((const char *)typeClazz, "NSDate") )
		{
			return LeomaClassType_NSDate;
		}
		else if ( 0 == strcmp((const char *)typeClazz, "NSArray") )
		{
			return LeomaClassType_NSArray;
		}
		else if ( 0 == strcmp((const char *)typeClazz, "NSDictionary") )
		{
			return LeomaClassType_NSDictionary;
		}
		else
		{
			return LeomaClassType_Object;
		}
    } else if ((type[0] == 'i' || type[0] == 'I') && type[1] == ',') {
        return LeomaClassType_Int_NSInteger;
    } else if ((type[0] == 'l' || type[0] == 'L') && type[1] == ',') {
        return LeomaClassType_Long;
    } else if ((type[0] == 'q' || type[0] == 'Q') && type[1] == ',') {
        return LeomaClassType_Long_Long;
    } else if ((type[0] == 'f' || type[0] == 'F') && type[1] == ',') {
        return LeomaClassType_Float_CGFloat;
    } else if ((type[0] == 'd' || type[0] == 'D') && type[1] == ',') {
        return LeomaClassType_Double;
    }
    return LeomaClassType_Unknow;
}

@end
