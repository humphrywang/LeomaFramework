//
//  LeomaLog.m
//  Pods
//
//  Created by CorpDev on 22/5/17.
//
//

#import "LeomaLog.h"
#import "LeomaMessage.h"

typedef NS_ENUM(NSInteger, LeomaLogLevel) {
    LeomaLogLevelDebug    = 0,
    LeomaLogLevelInfo     = 1,
    LeomaLogLevelWarn     = 2,
    LeomaLogLevelError    = 3,
    LeomaLogLevelFatal    = 4
};
@interface LeomaLog()

@property (   atomic, strong) NSMutableString * tracingInfo; // 用户行为跟踪
@property (nonatomic, strong) NSString * api;// 上传API
@property (nonatomic, strong) NSString * session;// 唯一UID
@property (nonatomic, assign) BOOL disabled;// 禁用日志
@end

@implementation LeomaLog

void UncaughtExceptionHandler(NSException * exception){
    [LeomaLog LogException:exception];
}

static LeomaLog * instance;

+(void)LoggerDisable:(BOOL)disable{
    [self LoggerInitialize];
    instance.disabled = disable;
}

+(NSString *)LoggerSession{
    [self LoggerInitialize];
    return instance.session;
}

+(void)LoggerRegisterAPI:(NSString *)api{
    [self LoggerInitialize];
    instance.api = api;
}

+(void)LoggerInitialize{
    leoma_dispatch_once(^{
        instance = [[LeomaLog alloc] init];
        instance.tracingInfo = [NSMutableString string];
        instance.session = [[NSUUID UUID] UUIDString];
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    });
}

+(void)LogTracing:(id)message withTitle:(NSString *)title{
    [self LoggerInitialize];
    if(instance.disabled) return;
    leoma_dispatch_back(^{
        if(title){
            [instance.tracingInfo appendFormat:@"[%@] - %.2f\n", title, [[NSDate date] timeIntervalSince1970]];
        }
        if(message){
            [instance.tracingInfo appendString:[message asNSString]?:@""];
            [instance.tracingInfo appendString:@"\n"];
        }
    });
}

+(void)LogMessage:(id)message withTitle:(NSString *)title{
    [self LoggerInitialize];
    if(instance.disabled) return;
    leoma_dispatch_back(^{
        NSMutableString * value = [NSMutableString string];
        [value appendString:instance.tracingInfo?:@""];
        [value appendString:@"\n--------------------------------\n\n"];
        [value appendString:title?:@""];
        [value appendString:@"\n\n"];
        [value appendString:[message asNSString]?:@""];
        [value appendString:@"\n\n"];
        [instance _post:value level:LeomaLogLevelInfo type:LeomaLogTypeMessage];
    });
}

+(void)LogException:(NSException *)exception{
    [self LoggerInitialize];
    if(instance.disabled || !exception) return;
    NSMutableString * value = [NSMutableString stringWithString:instance.tracingInfo];
    [value appendString:@"\n--------------------------------\n\n"];
    [value appendString:exception.name?:@""];
    [value appendString:@"\n\n"];
    [value appendFormat:@"Reason:%@\nCallStack:\n", exception.reason];
    [[exception callStackSymbols] enumerateObjectsUsingBlock:^(NSString * stackStep, NSUInteger i, BOOL * stop) {
        if(!stackStep) return;
        [value appendString:stackStep];
        [value appendString:@"\n"];
    }];
    [instance _post:value level:LeomaLogLevelFatal type:LeomaLogTypeException];
}

-(void)_post:(NSString*)log level:(LeomaLogLevel)level type:(LeomaLogType)type{
    if(!self.api) return;
    self.tracingInfo = [NSMutableString string];
    LeomaMessage * message = [LeomaMessage messagePostWithURLString:self.api];
    [message inputKey:@"TagS" value:[self tags:type]];
    [message inputKey:@"level" value:@(level)];
    [message inputKey:@"value" value:log];
    [message setRemoteLog:NO];
    [message send:NO];
}

-(NSString *)tags:(LeomaLogType)type{
    NSMutableString * tags = [NSMutableString string];
    [tags appendString:@"P|iOS,"];
    [tags appendFormat:@"LS|%@,", self.session];//log session
    [tags appendFormat:@"V|%@,", [LeomaSystem appVersion]];
    [tags appendFormat:@"U|%@,", [LeomaSystem modelDetail]];
    [tags appendFormat:@"LT|%@", [self logTypeString:type]];//log type
    return tags;
}

-(NSString *)logTypeString:(LeomaLogType)type{
    switch (type) {
        case LeomaLogTypeMessage:
            return @"Message";
        case LeomaLogTypeException:
            return @"Exception";
    }
}

@end
