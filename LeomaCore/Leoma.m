//
//  Leoma.m
//  LeomaFramework
//
//  Created by CorpDev on 6/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import "Leoma.h"
#import "LeomaURLProtocol.h"
#import "JSONKit.h"

#define LeomaCallBack @"Leoma.CallBack"
#define LeomaInjectComponent @"LeomaInject.script"

NSString * const LeomaInjectSlotCore        = @"/*$1*/";
NSString * const LeomaInjectSlotRights      = @"/*$2*/";
NSString * const LeomaInjectSlotEnvironment = @"/*$3*/";
static Leoma * instance;

@interface Leoma()

@property (copy, nonatomic) NSString * injectScriptTemplate;

@property (strong, nonatomic) NSMutableDictionary<NSString*, LeomaHandler>* leomaHandlers;

@property (strong, nonatomic) NSMutableDictionary<NSString*, id>* sessionStorage;

@property (copy, nonatomic) NSArray * LeomaAPIs;

@end

@implementation Leoma
+(void)registerLeoma:(nullable Class)protClazz WithLeomaAPIs:(NSArray<NSString *> *)apis{
    leoma_dispatch_once(^{
        instance = [[Leoma alloc] init];
        instance.LeomaAPIs = apis;
        if(![NSURLProtocol registerClass:protClazz]) [NSURLProtocol registerClass:LeomaURLProtocol.class];
        [instance commonInit];
    });
}

+(instancetype)sharedLeoma{
    if(!instance) NSLog(@"Should Register Leoma First");
    return instance;
}

-(void)commonInit{
    self.leomaHandlers = [NSMutableDictionary dictionary];
    self.sessionStorage = [NSMutableDictionary dictionary];
    [self registAPIs];
    
    int cacheSizeMemory = 20 * 1024 * 1024; // 20MB
    int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
    NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory
                                                            diskCapacity:cacheSizeDisk
                                                                diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
}

-(void)registAPIs{
    //获取注入脚本模版
    self.injectScriptTemplate = [NSString stringWithContentsOfFile:[LeomaUtils bundleContentPath:LeomaInjectComponent] encoding:NSUTF8StringEncoding error:nil] ;
    NSMutableString * rights = [NSMutableString stringWithFormat:@"Ver:%f",LeomaVersion];
    //注册API与声明权限
    for(NSString* content in self.LeomaAPIs) {
        NSString* clearContent = [content componentsSeparatedByString:@"//"].firstObject;
        if([NSString isBlank:clearContent]) continue;
        //DeviceApp.leoma_handler#LeomaHandler:true
        NSArray * apiComponents = [clearContent componentsSeparatedByString:@"#"];
        [self analysisHandler:apiComponents[0]];
        if(apiComponents.count > 1) [rights appendFormat:@",%@",apiComponents[1]];
    }
    self.injectScriptTemplate = [self.injectScriptTemplate stringByReplacingOccurrencesOfString:LeomaInjectSlotRights withString:rights];
}

-(void)analysisHandler:(NSString*)handlerName{
    NSArray *comp = [handlerName componentsSeparatedByString:@"."];
    if (comp.count != 2) {
        LeomaLogg(@"Error:Handler name <%@> must be like **.**", handlerName);
        return;
    }
    NSString * className = LeomaHandlerClass(comp[0]);
    NSString * methodName = comp[1];
    Class class = NSClassFromString(className);
    if (!class) {
        LeomaLogg(@"Error:Unknown class <%@> in handler name <%@>.", className, handlerName);
        return;
    }
    SEL selector = NSSelectorFromString(methodName);
    if (![class respondsToSelector:selector]) {
        LeomaLogg(@"Error:Can not found class method <%@> in class <%@> for handler name <%@>.", methodName, className, handlerName);
        return;
    }
    LeomaHandler (*imp)(Class, SEL) = (void*)[class methodForSelector:selector];
    LeomaHandler ret = imp(class, selector);
    if (!ret) {
        LeomaLogg(@"Error:<[%@ %@]> return nil.", class, methodName);
        return;
    }
    [self registHandler:handlerName withHandler:ret];
}

-(void)registHandler:(NSString*)handlerName withHandler:(LeomaHandler)handler{
    [self.leomaHandlers setObject:[handler copy] forKey:handlerName];
}



@end

void tracingLeomaInteraction(LeomaInteractionModel* userInfo){
#pragma mark RecordLog
    LeomaLogg(@"InterAction [%@] Accepted", userInfo.Handler);
    [LeomaLog LogTracing:nil withTitle:[NSString stringWithFormat:@"调用接口 %@", userInfo.Handler]];

}

void recordLeomaInteraction(LeomaInteractionModel* userInfo, LeomaResponse* response){
#pragma mark RecordLog
    if(response.status.code == LeomaResponseStatusCodeSuccess) return;
    [LeomaLog LogMessage:userInfo.Data
               withTitle:[NSString stringWithFormat:@"[接口返回异常]:%@ ;\n[返回值]:%d ;", userInfo.Handler, response.status.code]];
}

LeomaResponse* dispatchLeomaInteractionRequest(LeomaInteractionModel* userInfo){
    tracingLeomaInteraction(userInfo);
    LeomaHandler handler = [Leoma sharedLeoma].leomaHandlers[userInfo.Handler];
    if(!handler) return nil;
    if([userInfo.Handler rangeOfString:@"AppNavigator"].length > 0 || [userInfo.Handler rangeOfString:@"NativeScene"].length > 0){
        leoma_dispatch_main(^{
            handler(userInfo);
        });
        return nil;
    }else return handler(userInfo);
}

LeomaResponse* sendLeomaInteractionResponse(LeomaInteractionModel* userInfo, LeomaResponseStatusCode statusCode, id data){
    if(!userInfo) return nil;
    LeomaResponse * response = [LeomaResponse responseWithStatusCode:statusCode data:data];
    recordLeomaInteraction(userInfo, response);
    if(userInfo.InterAction == LeomaInteractionAsyncAjax && userInfo.Protocol){
        [userInfo.Protocol.client URLProtocol:userInfo.Protocol didLoadData:[[response asNSDictionary] JSONData]];
        [userInfo.Protocol.client URLProtocolDidFinishLoading:userInfo.Protocol.client];
    }else if(userInfo.InterAction == LeomaInteractionAsyncCallBack && userInfo.CallBack && userInfo.WebView){
        [userInfo.WebView executeJS:[NSString stringWithFormat:@"%@('%@', %@)", LeomaCallBack, userInfo.CallBack, [[response asNSDictionary] JSONString]]];
    }else if(userInfo.InterAction == LeomaInteractionSyncReturn){
        return response;
    }
    return nil;
}
LeomaResponse* sendLeomaSuccessResponse(LeomaInteractionModel* userInfo, id data){
    return sendLeomaInteractionResponse(userInfo, LeomaResponseStatusCodeSuccess, data);
}
LeomaResponse* sendLeomaFailResponse(LeomaInteractionModel* userInfo, LeomaResponseStatusCode statusCode){
    return sendLeomaInteractionResponse(userInfo, statusCode, nil);
}
LeomaResponse* sendLeomaEmptyResponse(){
    return nil;
}
