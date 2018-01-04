//
//  Leoma.h
//  LeomaFramework
//
//  Created by CorpDev on 6/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeomaModel.h"

extern NSString * const LeomaInjectSlotCore;
extern NSString * const LeomaInjectSlotEnvironment;
extern LeomaResponse* dispatchLeomaInteractionRequest(LeomaInteractionModel* userInfo);
extern LeomaResponse* sendLeomaInteractionResponse(LeomaInteractionModel* userInfo, LeomaResponseStatusCode statusCode, id data);
extern LeomaResponse* sendLeomaSuccessResponse(LeomaInteractionModel* userInfo, id data);
extern LeomaResponse* sendLeomaFailResponse(LeomaInteractionModel* userInfo, LeomaResponseStatusCode statusCode);
extern LeomaResponse* sendLeomaEmptyResponse();
//不可为null时为null，不为null时class不符合
#define LeomaAssertUserInfo(userInfo, clazz, _nullable) \
if((!_nullable && !userInfo.Data) || (userInfo.Data && ![userInfo.Data isKindOfClass:clazz])){\
    return sendLeomaFailResponse(userInfo, LeomaResponseStatusCodeIllegal);\
}

@interface Leoma : NSObject

@property (readonly, nonatomic) NSString * injectScriptTemplate;

+(void)registerLeoma:(nullable Class)urlProtocol WithLeomaAPIs:(NSArray<NSString*>*)apis;
+(instancetype)sharedLeoma;

@end
