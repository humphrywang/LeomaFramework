//
//  CorpHttpSession.m
//  Pods
//
//  Created by CorpDev on 31/8/16.
//
//

#import "LeomaHttpSession.h"
#import "ASIFormDataRequest.h"

#define HTTP_GET @"GET"
#define HTTP_POST @"POST"

@interface LeomaHttpSession(){
    LeomaHttpMethod httpMethod;
}

@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* httpMethodName;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (strong, nonatomic) LeomaHTTPResponseHandler responseBlock;

@property (assign, nonatomic) BOOL needTrace;
@property (strong, nonatomic) NSString* logUID;

@property (strong, nonatomic) NSMutableDictionary<NSString*, NSString*>* headers;
@property (strong, nonatomic) NSMutableDictionary* params;
@property (strong, nonatomic) NSData * data;

@property (assign, nonatomic) Class responseClass;

@property (strong, nonatomic) ASIHTTPRequest * request;

@end

@implementation LeomaHttpSession


+(LeomaHttpSession *)sessionWithUrl:(NSString *)url{
    LeomaHttpSession * session = [[LeomaHttpSession alloc] init];
    url = [url hasPrefix:@"//"] ? [NSString stringWithFormat:@"http:%@", url] : url;
    session.url = url;
    session.headers = [NSMutableDictionary dictionary];
    session.params = [NSMutableDictionary dictionary];
    session.timeout = LeomaSessionTimeOut;
    session.needTrace = YES;
    session.responseClass = [NSData class];
    [session setRequestMethod:LeomaHttpMethodGet];
    return session;
}

-(void)setRequestMethod:(LeomaHttpMethod)method{
    httpMethod = method;
    switch (method) {
        case LeomaHttpMethodGet:
            self.httpMethodName = HTTP_GET;
            break;
        case LeomaHttpMethodPost:
            self.httpMethodName = HTTP_POST;
            break;
    }
}

-(void)setHttpResponseBlock:(LeomaHTTPResponseHandler)responseBlock{
    self.responseBlock = responseBlock;
}

-(void)setTimeOutInterval:(NSTimeInterval)timeout{
    self.timeout = timeout;
}

-(void)setRequestHeader:(NSString *)value ofKey:(NSString *)key{
    [self.headers setValue:value forKey:key];
}
-(void)setRequestHeaders:(NSDictionary<NSString*, NSString*>*)headers{
    [self.headers setValuesForKeysWithDictionary:headers];
}

-(void)setRequestParameter:(id)value ofKey:(NSString *)key{
    [self.params setValue:value forKey:key];
}
-(void)setRequestParameters:(NSDictionary<NSString*, id>*)params{
    [self.params setValuesForKeysWithDictionary:params];
    
}
-(void)setRequestData:(id)data{
    self.data = [[[data asNSDictionary] JSONString] asNSData];
}

-(void)sessionStart:(BOOL)sync{
    [self generateRequestEntity];
    [self.request setRequestMethod:self.httpMethodName];
    [self.request setTimeOutSeconds:self.timeout];
    [self.request setNumberOfTimesToRetryOnTimeout:0];
    [self.request setResponseEncoding:NSUTF8StringEncoding];
    [self.request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [self.request setShouldAttemptPersistentConnection:NO];
    [self.request setUserAgentString:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"]];
    for(NSString * key in self.headers){
        if([key isEqualToString:@"UserAgent"] || [key isEqualToString:@"User-Agent"]){
            [self.request setUserAgentString:[self.headers objectForKey:key]];
        }else{
            [self.request addRequestHeader:key value:[self.headers objectForKey:key]];
        }
    }
    __block LeomaHttpSession * ref = self;
    void(^ResponseBlock)() = ^(){
        if(ref.responseBlock){
            int statusCode = ref.request.responseStatusCode;
            BOOL success = !self.request.error && (statusCode / 100 == 2);
            id response;
            if(success){
                if(!self.responseClass || self.responseClass == [NSData class]) response = ref.request.responseData;
                else if(self.responseClass == [NSString class]) response = ref.request.responseString;
                else response = [self.responseClass objectFromDictionary:[ref.request.responseString JSONToDictionary]];
            }
            ref.responseBlock(success, statusCode, response);
            ref.responseBlock = nil;
        }
    };
    if(sync){
        [self sessionStartSyncly:ResponseBlock];
    }else{
        [self sessionStartAsyncly:ResponseBlock];
    }
}

-(void)sessionCancel{
    [self.request clearDelegatesAndCancel];
    self.responseBlock = nil;
}

-(void)sessionStartAsyncly:(void(^)())responseBlock{
    __block LeomaHttpSession * ref = self;
    [self.request setCompletionBlock:responseBlock];
    [self.request setFailedBlock:responseBlock];
    [self.request startAsynchronous];
}

-(void)sessionStartSyncly:(void(^)())responseBlock{
    [self.request startSynchronous];
    if(responseBlock) responseBlock();
}

-(void)generateRequestEntity{
    switch (httpMethod) {
        case LeomaHttpMethodPost:
            self.request = [self generatePostRequest];
            break;
        case LeomaHttpMethodGet:
            self.request = [self generateGetRequest];
            break;
    }
}

-(ASIHTTPRequest*)generateGetRequest{
    NSString * paramString = [self.params parameterDictionaryToQueryString];
    NSString * urlString = paramString.length > 0 ? [NSString stringWithFormat:@"%@?%@", self.url, paramString] : self.url;
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    return request;
}

-(ASIHTTPRequest*)generatePostRequest{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:self.url]];
    if(self.data) [request setPostBody:[NSMutableData dataWithData:self.data]];
    for(NSString * key in self.params){
        id value = [self.params objectForKey:key];
        if([value isKindOfClass:[NSData class]]){
            [request addData:value withFileName:nil andContentType:nil forKey:key];
        }else{
            [request setPostValue:value forKey:key];
        }
    }
    return request;
}

@end
