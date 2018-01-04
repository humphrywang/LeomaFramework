//
//  LeomaModel.m
//  LeomaFramework
//
//  Created by CorpDev on 6/4/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#import "LeomaModel.h"
#import "JSONKit.h"

@implementation LeomaInteractionModel

-(BOOL)legal{
    return self.Handler && self.InterAction != LeomaInteractionNone;
}
-(id)copy{
    LeomaInteractionModel * model = [[LeomaInteractionModel alloc] init];
    model.InterAction = self.InterAction;
    model.Data = nil;
    model.WebView = self.WebView;
    model.Controller = self.Controller;
    model.CallBack = [self.CallBack copy];//Case LeomaInteractionAsyncCallBack
    model.Handler = nil;
    model.Protocol = self.Protocol;
    model.UUID = self.UUID;
    model.UA = self.UA;
    return model;
}

@end

@implementation LeomaResponseStatus
+ (instancetype) statusWithCode:(LeomaResponseStatusCode)code
{
    LeomaResponseStatus *status = [[LeomaResponseStatus alloc] init];
    status.code = code;
    return status;
}
@end

@implementation LeomaResponse
+ (instancetype) responseWithStatusCode:(LeomaResponseStatusCode)statusCode
                                   data:(id)data;
{
    LeomaResponse *response = [[LeomaResponse alloc] init];
    response.status = [LeomaResponseStatus statusWithCode:statusCode];
    response.data = data;
    return response;
}

- (NSString*)description{
    return [[self asNSDictionary] JSONString];
}
@end
