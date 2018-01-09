    //
//  LeomaModel.h
//  LeomaFramework
//
//  Created by CorpDev on 6/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeomaWebProtocol.h"

#pragma InterAction Model
typedef NS_ENUM(NSInteger, LeomaInteraction){
    LeomaInteractionNone = 0,
    LeomaInteractionSyncReturn,//同步的返回值式的交互
    //LeomaInteractionSyncAjax,//同步的Ajax请求式的交互
    LeomaInteractionAsyncCallBack,//异步的回调函数式的交互
    LeomaInteractionAsyncAjax,//异步的Ajax请求式的交互
    LeomaInteractionAsyncNative//Native调用的方式
};

@interface LeomaInteractionModel : NSObject

@property (nonatomic, assign) LeomaInteraction                  InterAction;
@property (nonatomic, strong) id                                Data;
@property (nonatomic, weak)   LeomaWebCore *                    WebView;
@property (nonatomic, weak)   UIViewController *                Controller;
@property (nonatomic, copy)   NSString *                        CallBack;//Case LeomaInteractionAsyncCallBack
@property (nonatomic, copy)   NSString *                        Handler;
@property (nonatomic, strong) NSURLProtocol *                   Protocol;//Case LeomaInteractionSyncAjax & LeomaInteractionASyncAjax
@property (nonatomic, copy)   NSString *                        UUID;
@property (nonatomic, copy)   NSString *                        UA;
@property (nonatomic, copy)   void(^NativeCompletion)(NSInteger code, id result);

@property (nonatomic, assign, readonly) BOOL                    legal;

@end

#pragma LeomaResponse Model
typedef NS_ENUM(NSInteger, LeomaResponseStatusCode) {
    LeomaResponseStatusCodeSuccess = 0,
    LeomaResponseStatusCodeIllegal = 99,
    LeomaResponseStatusCodeCanceled = 100,
    LeomaResponseStatusCodeFailed = 101,
    LeomaResponseStatusCodeDenied = 102,
    LeomaResponseStatusCodeError = 103
};

@interface LeomaResponseStatus : NSObject

@property (assign, nonatomic) LeomaResponseStatusCode    code;

+ (instancetype) statusWithCode:(LeomaResponseStatusCode)code;

@end

@interface LeomaResponse : NSObject

@property (strong, nonatomic) LeomaResponseStatus *  status;
@property (strong, nonatomic) id                    data;

+ (instancetype) responseWithStatusCode:(LeomaResponseStatusCode)statusCode
                              data:(id)data;


@end

typedef LeomaResponse* (^LeomaHandler)(LeomaInteractionModel* data);
typedef void (^LeomaAsyncHandler)(LeomaResponseStatusCode code, id data);
