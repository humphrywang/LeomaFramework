//
//  LeomaClassUtils.h
//  LeomaFramework
//
//  Created by CorpDev on 14-5-2.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

typedef NS_ENUM(NSInteger, LeomaClassType) {
    LeomaClassType_Unknow            = 0,   // 未知类型
    LeomaClassType_Int_NSInteger,           // int
    LeomaClassType_Long,                    // long
    LeomaClassType_Long_Long,               // long long
    LeomaClassType_Float_CGFloat,           // float
    LeomaClassType_Double,                  // double
    LeomaClassType_NSNumber,                // NSNumber
    LeomaClassType_NSString,                // NSString
    LeomaClassType_NSDate,                  // NSDate
    LeomaClassType_NSArray,                 // NSArray d
    LeomaClassType_NSDictionary,            // NSDictionary
    LeomaClassType_Object,                  // Object
    LeomaClassType_Null                     // nil|NSNull
};

UIKIT_EXTERN NSString *const LeomaClassPropertyNameKey;
UIKIT_EXTERN NSString *const LeomaClassPropertyTypeKey;
UIKIT_EXTERN NSString *const LeomaClassPropertyColumnNameKey;

@interface LeomaClassUtils : NSObject

/**
 *  获取一个类中的属性列表
 *
 *  @param clazz
 *
 *  @return
 */
+ (NSArray *) propertiesInClass:(Class)clazz;

/**
 *  获取一个类中指定属性的类型
 *
 *  @param propertyName
 *  @param clazz
 *
 *  @return
 */
+ (LeomaClassType) typeWithPropertyName:(NSString *)propertyName
                            inClass:(Class)clazz;

/**
 *  获取一个对象的类别
 *
 *  @param obj
 *
 *  @return 
 */
+ (LeomaClassType) typeWithObject:(id)obj;

/**
 *  获取指定class中的指定成员名的class类型
 *
 *  @param propertyName 成员名称
 *  @param clazz
 *
 *  @return 成员名对应的class类型
 */
+ (Class) classWithPropertyName:(NSString *)propertyName
                        inClass:(Class)clazz;

@end
