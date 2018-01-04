//
//  CorpMessage.m
//  Pods
//
//  Created by klaus on 14-3-15.
//
//

#import "LeomaMessage.h"
#import "ASIFormDataRequest.h"
#import "LeomaMessageController.h"

#define LeomaConsoleLog(...) if(_consoleLog){NSLog(@"%@\n%@", _action, [NSString stringWithFormat:__VA_ARGS__]);}else {}
NSTimeInterval const MessageTimeOutInterVal = 30.0;
NSString * const MessageHeaderUA = @"UserAgent";
NSString * const MessageHeaderReferer = @"Referer";
static NSString * MessageRefer;

@interface FileParam : NSObject
@property (nonatomic, strong) NSString *            filePath;
@property (nonatomic, strong) NSData *              fileData;
@property (nonatomic, strong) NSString *            fileName;
@property (nonatomic, strong) NSString *            contentType;
@end
@implementation FileParam
@end

@interface LeomaMessage ()

@property (nonatomic, copy  ) NSString            * action;
@property (nonatomic, strong) ASIHTTPRequest      * request;

@property (nonatomic, strong) NSMutableDictionary * inputData;
@property (nonatomic, strong) NSMutableDictionary * inputFiles;
@property (nonatomic, strong) NSMutableDictionary * requestHeaders;

@property (nonatomic, assign) LeomaMessageStatus    status;

@property (nonatomic, assign) Class                 clazz;
@property (nonatomic, copy  ) NSString*             localPath;
@property (nonatomic, copy  ) NSString*             refer;

@property (nonatomic, assign) int                   responseStatusCode;
@property (nonatomic, strong) id                    responseBody;
@property (nonatomic, retain) NSError *             error;

@end

@implementation LeomaMessage{
    BOOL _remoteLog;
    BOOL _consoleLog;
    
    NSTimeInterval _timeOut;
    LeomaMessageSubmit _submit;
    LeomaMessageType _type;
}

+ (void) registerMessageRefer:(NSString *)refer
{
    MessageRefer = [refer copy];
}
#pragma mark - init/dealoac

+(instancetype)messageGetWithURLString:(NSString *)urlString{
    return [self messageWithURLString:urlString type:LeomaMessageTypeGet];
}

+(instancetype)messageDownloadWithURLString:(NSString *)urlString localPath:(NSString *)path{
    LeomaMessage * message = [self messageWithURLString:urlString type:LeomaMessageTypeDownload];
    message.localPath = path;
    return message;
}

+(instancetype)messageAjaxWithURLString:(NSString *)urlString responseClass:(Class)jsonClass{
    LeomaMessage * message = [self messageWithURLString:urlString type:LeomaMessageTypeAJAX];
    message.clazz = jsonClass ?: message.clazz;
    [message setRemoteLog:YES];
    return message;
}

+(instancetype)messagePostWithURLString:(NSString *)urlString{
    return [self messageWithURLString:urlString type:LeomaMessageTypePost];
}

+(instancetype) messageWithURLString:(NSString *)urlString type:(LeomaMessageType)type{
    LeomaMessage *message = [[LeomaMessage alloc] init];
    message.action = [NSString isBlank:urlString] ? nil : [urlString blankTrim];
    message.type = type;
    return message;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.inputData = [NSMutableDictionary dictionary];
        self.inputFiles = [NSMutableDictionary dictionary];
        self.requestHeaders = [NSMutableDictionary dictionary];
        self.responseStatusCode = -1;
        self.clazz = [NSDictionary class];
        _timeOut = MessageTimeOutInterVal;
        _submit = LeomaMessageSubmitForm;
        _consoleLog = YES;
        _remoteLog = NO;
    }
    return self;
}

- (void) dealloc
{
    self.action = nil;
    [self.inputData removeAllObjects];
    [self.inputFiles removeAllObjects];
    [self.requestHeaders removeAllObjects];
}

#pragma mark -

- (NSDictionary *) parameters
{
    return self.inputData;
}

- (NSTimeInterval) timeConsuming
{
    if (_sendTimeStamp != 0 && _recvTimeStamp != 0) {
        return _recvTimeStamp - _sendTimeStamp;
    }
    return 0;
}

- (BOOL) finished
{
    return self.status == LeomaMessageStatusSuccessed || self.status == LeomaMessageStatusCanceled || self.status == LeomaMessageStatusFailed;
}

- (instancetype) setTimeOutInterval:(NSTimeInterval)time
{
    _timeOut = time;
    return self;
}
- (instancetype) setSubmitType:(LeomaMessageSubmit)submit
{
    _submit = submit;
    return self;
}

- (instancetype) setRemoteLog:(BOOL)remote
{
    _remoteLog = remote;
    return self;
}

- (instancetype) setConsoleLog:(BOOL)console
{
    _consoleLog = console;
    return self;
}

-(void)setStatus:(LeomaMessageStatus)status
{
    _status = status;
    if(self.messageStatusChangeDelegate && [self.messageStatusChangeDelegate respondsToSelector:@selector(messageStatusChange:)]){
        [self.messageStatusChangeDelegate messageStatusChange:self];
    }
}

- (void) setType:(LeomaMessageType)type
{
    _type = type;
    if(_type == LeomaMessageTypeAJAX){
        [self inputHeaderWithKey:@"Accept" value:@"text/javascript, text/html, application/xml, application/json, text/xml, */*"];
        [self inputHeaderWithKey:@"content-type" value:@"application/json;charset=UTF-8"];
    }
}

- (instancetype) inputKey:(NSString *)key
                    value:(id)value
{
    if (key && value) {
        id lastValue = [self.inputData objectForKey:key];
        if (lastValue) {
            if ([lastValue isKindOfClass:[NSMutableArray class]]) {
                [((NSMutableArray *)lastValue) addObject:value];
            } else {
                NSMutableArray *ma = [NSMutableArray array];
                [ma addObject:lastValue];
                [ma addObject:value];
                [self.inputData setObject:ma forKey:key];
            }
        } else {
            [self.inputData setObject:value forKey:key];
        }
    }
    return self;
}

- (instancetype) inputParams:(NSDictionary *)params
{
    [params enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL * stop) {
        [self inputKey:key value:obj];
    }];
    return self;
}

- (instancetype) inputFileWithKey:(NSString *)key
                            value:(id)value
                         fileName:(NSString *)fileName
                      contentType:(NSString *)contentType
{
    if (key && value && ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSData class]])) {
        FileParam *fp = [[FileParam alloc] init];
        if ([value isKindOfClass:[NSString class]]) {
            BOOL isDirectory = NO;
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:(NSString *)value isDirectory:&isDirectory];
            if (fileExists && !isDirectory) {
                fp.filePath = (NSString *)value;
            } else {
                fp.fileData = [((NSString *)value) dataUsingEncoding:NSUTF8StringEncoding];
            }
        } else if ([value isKindOfClass:[NSData class]]) {
            fp.fileData = (NSData *)value;
        }
        fp.fileName = fileName;
        fp.contentType = contentType;
        [self.inputFiles setObject:fp forKey:key];
    }
    return self;
}

- (instancetype) inputHeaderWithKey:(NSString *)key
                              value:(NSString *)value
{
    if (key && value) {
        [self.requestHeaders setObject:value
                                      forKey:key];
    }
    return self;
}

- (id) requestInputForKey:(NSString *)key
{
    id input = [self.inputData objectForKey:key];
    if(input) return input;
    FileParam * file = [self.inputFiles objectForKey:key];
    if(input) return file.fileData ?: file.filePath;
    return nil;
}

- (NSString *) requestHeaderForKey:(NSString *)key
{
    return [self.requestHeaders objectForKey:key];
}

- (instancetype) send
{
    return [self send:YES];
}

- (instancetype) send:(BOOL)async
{
    return [self _doSend:async];
}

- (BOOL) is:(id)obj
{
    if ([obj isKindOfClass:[NSString class]]) {
        return [self.action isEqualToString:(NSString *)obj];
    }
    return [super is:obj];
}

#pragma mark -

- (instancetype) _doSend:(BOOL)async
{
    if (_remoteLog && _type == LeomaMessageTypeAJAX){
        [LeomaLog LogTracing:nil withTitle:[NSString stringWithFormat:@"AJAX - %@", self.action]];
    }
    if (_consoleLog){
        LogConsole(self.action);
        LogConsole(@"Message Params:%@", _inputData);
    }
    _request = [self generateMessageEntity];
    [_request setUserAgentString:[[NSUserDefaults standardUserDefaults] objectForKey:MessageHeaderUA]];
    if(MessageRefer) [_request addRequestHeader:MessageHeaderReferer value:MessageRefer];
    for (NSString *key in _requestHeaders.allKeys) {
        if([@"User-Agent" isEqualToString:key] || [@"UserAgent" isEqualToString:key]){
            [_request setUserAgentString:[_requestHeaders objectForKey:key]];
        }else{
            [_request addRequestHeader:key value:[_requestHeaders objectForKey:key]];
        }
    }
    [_request setTimeOutSeconds:_timeOut];
    [_request setResponseEncoding:NSUTF8StringEncoding];
    [_request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [_request setShouldAttemptPersistentConnection:NO];
    _sendTimeStamp = [[NSDate date] timeIntervalSince1970];
    self.status = LeomaMessageStatusSending;
    if (async) {
        [self _doAsyncSend];
    } else {
        [self _doSyncSend];
    }
    return self;
}

- (void) _doAsyncSend{
    void(^Handle)(void) = ^{
        [self analysisResponse];
    };
    [_request setCompletionBlock:Handle];
    [_request setFailedBlock:Handle];
    [_request startAsynchronous];
}

- (void) _doSyncSend{
    [_request startSynchronous];
    [self analysisResponse];
}

-(void)analysisResponse{
    _recvTimeStamp = [[NSDate date] timeIntervalSince1970];
    _responseStatusCode = _request.responseStatusCode;
    if(_responseStatusCode < 300){//success
        [self analysisSuccessResponse];
    }else {
        [self analysisFailResponse];
    }
    
}

-(void)analysisFailResponse{
    _error = _request.error;
    if (_consoleLog){
        LogConsole(self.action);
        LogConsole(@"Message Failed:%@\nMessage Consuming: %f", _error, self.timeConsuming);
    }
    self.status = LeomaMessageStatusFailed;
    return;
}

-(void)analysisSuccessResponse{
    LogConsole(self.action);
    switch (_type) {
        case LeomaMessageTypeGet:
            _responseBody = _request.responseString;
            if (_consoleLog){
                LogConsole(self.action);
                LogConsole(@"Message Succeed:%@\nMessage Consuming: %f", _responseBody, self.timeConsuming);
            }
            break;
        case LeomaMessageTypePost:
            _responseBody = _request.responseData;
            if (_consoleLog){
                LogConsole(self.action);
                LogConsole(@"Message Succeed:[NSData]\nMessage Consuming: %f", self.timeConsuming);
            }
            break;
        case LeomaMessageTypeAJAX:
        {
            NSDictionary * data = [_request.responseData JSONDataToDictionary];
            _responseBody = [_clazz objectFromDictionary:data];
            if (_consoleLog){
                LogConsole(self.action);
                LogConsole(@"Message Succeed:%@\nMessage Consuming: %f", data, self.timeConsuming);
            }
            break;
        }
        case LeomaMessageTypeDownload:
        {
            if(fileSave(_request.responseData, _localPath)){
                _responseBody = _localPath;
                if (_consoleLog){
                    LogConsole(self.action);
                    LogConsole(@"Message Succeed:%@\nMessage Consuming: %f", _responseBody, self.timeConsuming);
                }
            }else{
                _responseBody = _request.responseData;
                if (_consoleLog){
                    LogConsole(self.action);
                    LogConsole(@"Message Succeed:[NSData]\nMessage Consuming: %f", self.timeConsuming);
                }
            }
            break;
        }
    }
    self.status = LeomaMessageStatusSuccessed;
}

- (ASIHTTPRequest*) generateMessageEntity
{
    switch (self.type) {
        case LeomaMessageTypeAJAX:
        case LeomaMessageTypePost:
            return [self generatePostRequest];
        case LeomaMessageTypeDownload:
        case LeomaMessageTypeGet:
            return [self generateGetRequest];
    }
}

- (ASIHTTPRequest*) generateGetRequest
{
    NSString * paramString = [self.inputData parameterDictionaryToQueryString];
    NSString * urlString = paramString.length > 0 ? [NSString stringWithFormat:@"%@?%@", self.action, paramString] : self.action;
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setRequestMethod:@"GET"];
    return request;
}

- (ASIHTTPRequest*) generatePostRequest
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:self.action]];
    switch (_submit) {
        case LeomaMessageSubmitForm:
            for (id key in self.inputData.allKeys) {
                id value = [self.inputData objectForKey:key];
                if ([value isKindOfClass:[NSMutableArray class]]) {
                    for (id v in ((NSArray *)value)) {
                        [request addPostValue:v
                                       forKey:key];
                    }
                } else {
                    [request setPostValue:[self.inputData objectForKey:key]
                                   forKey:key];
                }
            }
            for (id key in self.inputFiles.allKeys) {
                FileParam *fp = [self.inputFiles objectForKey:key];
                if (fp.fileData) {
                    [request addData:fp.fileData
                        withFileName:fp.fileName
                      andContentType:fp.contentType
                              forKey:key];
                } else if (fp.filePath) {
                    [request addFile:fp.filePath
                        withFileName:fp.fileName
                      andContentType:fp.contentType
                              forKey:key];
                }
            }
            break;
        case LeomaMessageSubmitJSON:
            [request setPostBody:[NSMutableData dataWithData:self.inputData.JSONData]];
            break;
    }
    [request setRequestMethod:@"POST"];
    return request;
}

#pragma mark tools
BOOL fileSave (NSData* item, NSString* dir)
{
    if([NSString isBlank:dir]) return NO;
    NSString* intermediateDir = [dir substringToIndex:[dir rangeOfString:@"/" options:NSBackwardsSearch].location];
    if([[NSFileManager defaultManager] fileExistsAtPath:dir]){
        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    }else if(![[NSFileManager defaultManager] fileExistsAtPath:intermediateDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:intermediateDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [[NSFileManager defaultManager] createFileAtPath:dir contents:item attributes:nil];
}

@end
