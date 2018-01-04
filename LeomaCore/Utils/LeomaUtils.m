//
//  LeomaUtils.m
//  Pods
//
//  Created by CorpDev on 25/4/17.
//
//

#import "LeomaUtils.h"

@implementation LeomaUtils

+(NSString*)formatedTimestampOfNow{
    return [LeomaUtils formatedTimestampOf:[NSDate date]];
}
+(NSString*)formatedTimestampOf:(NSDate*)date{
    NSDateFormatter * formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formater stringFromDate:date];
}

+(NSString*)bundleContentPath:(NSString*)component{
//    NSBundle * resBundle =[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:LeomaSpec ofType:@"bundle"]];
    
    return [[NSBundle mainBundle] pathForResource:component ofType:@""];
}
@end
