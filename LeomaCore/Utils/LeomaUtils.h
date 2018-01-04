//
//  LeomaUtils.h
//  Pods
//
//  Created by CorpDev on 25/4/17.
//
//

#import <Foundation/Foundation.h>

@interface LeomaUtils : NSObject

+(NSString*)formatedTimestampOfNow;
+(NSString*)formatedTimestampOf:(NSDate*)date;

+(NSString*)bundleContentPath:(NSString*)component;

@end
