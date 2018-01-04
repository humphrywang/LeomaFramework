//
//  CorpHttpSession.h
//  Pods
//
//  Created by CorpDev on 31/8/16.
//
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

typedef NS_ENUM(NSInteger, LeomaHttpMethod){
    LeomaHttpMethodGet,
    LeomaHttpMethodPost
};

typedef void(^LeomaHTTPResponseHandler)(BOOL success, int statusCode, id response);

@interface LeomaHttpSession : NSObject

+(instancetype)sessionWithUrl:(NSString *)url;

-(void)setNeedTrace:(BOOL)needTrace;

-(void)setHttpResponseBlock:(LeomaHTTPResponseHandler)responseBlock;

-(void)setRequestMethod:(LeomaHttpMethod)method;
-(void)setTimeOutInterval:(NSTimeInterval)timeout;

-(void)setRequestHeader:(NSString *)value ofKey:(NSString *)key;
-(void)setRequestHeaders:(NSDictionary<NSString*, NSString*>*)headers;

-(void)setRequestParameter:(id)value ofKey:(NSString *)key;
-(void)setRequestParameters:(NSDictionary<NSString*, id>*)params;

-(void)setRequestData:(id)data;

-(void)setResponseClass:(Class)clazz;

-(void)sessionStart:(BOOL)sync;

-(void)sessionCancel;

@end
