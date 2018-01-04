//
//  NSData+LeomaExtension.m
//  LeomaFramework
//
//  Created by CorpDev on 2017/11/23.
//

#import "NSData+LeomaExtension.h"

@implementation NSData (LeomaExtension)

-(void)saveToLeoma:(NSString *)name{
    if([NSString isBlank:name]) return;
    [[NSFileManager defaultManager] createFileAtPath:[leomaBundle() stringByAppendingPathComponent:name] contents:self attributes:nil];
}
+(instancetype)loadFromLeoma:(NSString*)name{
    return [NSData dataWithContentsOfFile:[leomaBundle() stringByAppendingPathComponent:name]];
}
+(void)deleteFromLeoma:(NSString *)name{
    [[NSFileManager defaultManager] removeItemAtPath:[leomaBundle() stringByAppendingPathComponent:name] error:nil];
}

NSString* leomaBundle(){
    NSString * leomaBundle = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:LeomaBundle];
    if(![[NSFileManager defaultManager] fileExistsAtPath:leomaBundle]){
        [[NSFileManager defaultManager] createDirectoryAtPath:leomaBundle withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return leomaBundle;
}
-(NSDictionary *)JSONDataToDictionary{
    NSError * error = nil;
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:&error];
    return (!error && !error.domain) ? dict : [NSDictionary dictionary];
}
@end
