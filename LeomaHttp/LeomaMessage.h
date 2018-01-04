//
//  LeomaMessage.h
//  LeomaFramework
//
//  Created by klaus on 14-3-15.
//
//  处理网络请求

#import <Foundation/Foundation.h>

extern NSTimeInterval const MessageTimeOutInterVal;

typedef NS_ENUM(NSInteger, LeomaMessageStatus) {
    LeomaMessageStatusPreparing,
    LeomaMessageStatusSending,               // 消息已经被发送
    LeomaMessageStatusSuccessed,             // 成功
    LeomaMessageStatusFailed,                // 失败
    LeomaMessageStatusCanceled,              // 取消
};

typedef NS_ENUM(NSInteger, LeomaMessageType){
    LeomaMessageTypeAJAX,
    LeomaMessageTypeGet,
    LeomaMessageTypePost,
    LeomaMessageTypeDownload
};

typedef NS_ENUM(NSInteger, LeomaMessageSubmit){
    LeomaMessageSubmitForm,//webform
    LeomaMessageSubmitJSON//jsonform
};

typedef void(^LeomaMessageBlock)(BOOL success);

@class LeomaMessage;

@protocol LeomaMessageStatusChangeDelegate <NSObject>

@optional
- (void) messageStatusChange:(LeomaMessage *)message;

@end

@interface LeomaMessage : NSObject

@property (nonatomic, weak) id<LeomaMessageStatusChangeDelegate>    messageStatusChangeDelegate;

+ (instancetype) messageAjaxWithURLString:(NSString *)urlString responseClass:(Class)jsonClass;

+ (instancetype) messageGetWithURLString:(NSString *)urlString;

+ (instancetype) messagePostWithURLString:(NSString *)urlString;

+ (instancetype) messageDownloadWithURLString:(NSString *)urlString localPath:(NSString*)path;

@property (nonatomic, assign, readonly) NSTimeInterval              sendTimeStamp;
@property (nonatomic, assign, readonly) NSTimeInterval              recvTimeStamp;
@property (nonatomic, assign, readonly) NSTimeInterval              timeConsuming;

@property (readonly) BOOL                                           finished;
@property (nonatomic, assign, readonly) LeomaMessageStatus          status;
@property (nonatomic, assign, readonly) LeomaMessageType            type;

//设置 请求的超时时间，默认为30秒
- (instancetype) setTimeOutInterval:(NSTimeInterval)time;
//设置 请求的表单格式，默认为webform表单。
- (instancetype) setSubmitType:(LeomaMessageSubmit)submit;
//设置 开启日志记录的开关，默认为关闭
- (instancetype) setRemoteLog:(BOOL)remote;
//设置 开始控制台日志的开关，默认为开启
- (instancetype) setConsoleLog:(BOOL)console;

/**
 *  输入参数
 */
- (instancetype) inputKey:(NSString *)key
                    value:(id)value;
- (instancetype) inputParams:(NSDictionary *)params;
/**
 *  输入文件
 */
- (instancetype) inputFileWithKey:(NSString *)key
                            value:(id)value
                         fileName:(NSString *)fileName
                      contentType:(NSString *)contentType;
- (instancetype) inputHeaderWithKey:(NSString *)key
                              value:(NSString *)value;

- (id) requestInputForKey:(NSString *)key;

- (NSString *) requestHeaderForKey:(NSString *)key;

- (instancetype) send;//Do Async

- (instancetype) send:(BOOL)async;

@property (readonly) int                         responseStatusCode;
@property (readonly) id                          responseBody;
@property (readonly) NSError *                   error;

+ (void) registerMessageRefer:(NSString*)refer;

@end
