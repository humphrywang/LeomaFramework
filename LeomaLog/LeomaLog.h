//
//  LeomaLog.h
//  Pods
//
//  Created by CorpDev on 22/5/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LeomaLogType){
    LeomaLogTypeException,//崩溃日志
    LeomaLogTypeMessage//API调用日志
};

@interface LeomaLog : NSObject

#define LogConsole(...) NSLog(__VA_ARGS__)

+(NSString*)LoggerSession;
//注册日志上传用的api
+(void)LoggerRegisterAPI:(NSString*)api;

//切换日志记录级别
+(void)LoggerDisable:(BOOL)disable;

+(void)LogTracing:(id)message withTitle:(NSString *)title;

+(void)LogMessage:(id)message withTitle:(NSString*)title;


@end
