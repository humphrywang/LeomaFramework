//
//  LeomaBuildIn.m
//  LeomaFramework
//
//  Created by CorpDev on 2018/2/1.
//

#import "LeomaBuildIn.h"
#import "Leoma.h"
#import "LeomaCookieStorage.h"

@implementation LeomaBuildIn

+(LeomaHandler)cookie_updated{
    return ^(LeomaInteractionModel* userInfo){
        LeomaAssertUserInfo(userInfo, [NSDictionary class], NO);
        NSString * domain = userInfo.Data[@"domain"];
        NSString * cookie = userInfo.Data[@"cookie"];
        [[LeomaCookieStorage sharedCookieStorage] storeCookies:cookie forDomain:domain];
        return sendLeomaSuccessResponse(userInfo, nil);
    };
}

+(LeomaHandler)cookie_fetch{
    return ^(LeomaInteractionModel* userInfo){
        LeomaAssertUserInfo(userInfo, [NSString class], NO);
        //TODO: fetch all cookies of all combinations. e.g. for "a.b.c.com", fetch "c.com" "b.c.com" "a.b.c.com"
        return sendLeomaSuccessResponse(userInfo, [[LeomaCookieStorage sharedCookieStorage] fetchCookiesForDomain:userInfo.Data]);
    };
}

+(LeomaHandler)console_log{
    return ^(LeomaInteractionModel* userInfo){
        LeomaLogg(@"%@", userInfo.Data);
        return sendLeomaSuccessResponse(userInfo, nil);
    };
}



@end
