//
//  LeomaWebViewPreference.m
//  Pods
//
//  Created by CorpDev on 2017/9/28.
//
//

#import "LeomaWebViewPreference.h"
#import "Leoma.h"

typedef NS_ENUM(NSInteger, LeomaPlatform){
    LeomaPlatformUnknown,
    LeomaPlatformiOS,
    LeomaPlatformAndroid
};

typedef NS_ENUM(NSInteger, LeomaCore){
    LeomaCoreUnknown,
    LeomaCoreWebKit,
    LeomaCoreUIKit,
    LeomaCoreXWalk,
    LeomaCoreWebView
};
typedef NS_ENUM(NSInteger, LeomaAsync){
    LeomaAsyncUnknown,
    LeomaAsyncJSCore,
    LeomaAsyncPrompt,
    LeomaAsyncAjax,
    LeomaAsyncMeaasge
};
typedef NS_ENUM(NSInteger, LeomaSync){
    LeomaSyncUnknown,
    LeomaSyncJSCore,
    LeomaSyncPrompt,
};

@implementation LeomaCoreConfig

+(instancetype)defaultConfig{
    LeomaCoreConfig * config = [[LeomaCoreConfig alloc] init];
    config.core = LeomaCoreEffectVisual;
    config.sync = LeomaCoreSyncVisual;
    config.async = LeomaCoreAsyncVisual;
    return config;
}
@end

@implementation LeomaWebViewPreference{
    LeomaPlatform platform;
    LeomaCore core;
    LeomaAsync async;
    LeomaSync sync;
    
    NSString* environment;
    NSString* coreConfig;
}

-(instancetype)initWithConfig:(LeomaCoreConfig *)config{
    self = [self init];
    if(self){
        [self initCoreInfo:config];
        [self registerCoreConfig];
    }
    return self;
}

-(void)initCoreInfo:(LeomaCoreConfig*)config{
    platform = LeomaPlatformiOS;
    core = config.core == LeomaCoreEffectVisual && IOS_WebKit ? LeomaCoreWebKit : LeomaCoreUIKit;
    sync = core == LeomaCoreUIKit && config.sync == LeomaCoreEffectVisual && IOS_JSCore ? LeomaSyncJSCore : LeomaSyncPrompt;
    switch (config.async) {
        case LeomaCoreAsyncVisual:
            async = core == LeomaCoreUIKit ? LeomaAsyncAjax : LeomaAsyncMeaasge;
            break;
        case LeomaCoreAsyncNormal:
            if(core == LeomaCoreWebKit) async = LeomaAsyncPrompt;
            else async = IOS_JSCore ? LeomaAsyncJSCore : LeomaAsyncAjax;
            break;
        case LeomaCoreAsyncExtern:
            async = core == LeomaCoreUIKit ? LeomaAsyncPrompt : LeomaAsyncMeaasge;
            break;
    }
}

-(void)registerLeomaEnvironment:(NSDictionary *)userInfo{
    userInfo = userInfo ?: @{};
    environment = [NSString stringWithFormat:@",Environment:%@", [userInfo JSONString]];
}

-(void)registerCoreConfig{
    coreConfig = [NSString stringWithFormat:@"Platform:%@,Core:%@,Async:%@,Sync:%@,", @(platform), @(core), @(async),@(sync)];
}

#pragma Preference APIs
-(NSString *)InjectScript{
    NSMutableString * injectScript = [NSMutableString stringWithString:[Leoma sharedLeoma].injectScriptTemplate];
    [injectScript replaceOccurrencesOfString:LeomaInjectSlotCore
                                  withString:coreConfig ?: @""
                                     options:NSCaseInsensitiveSearch
                                       range:NSMakeRange(0, injectScript.length)];
    [injectScript replaceOccurrencesOfString:LeomaInjectSlotEnvironment
                                  withString:environment ?: @""
                                     options:NSCaseInsensitiveSearch
                                       range:NSMakeRange(0, injectScript.length)];
    return injectScript;
}

-(BOOL)webKitInside{
    return core == LeomaCoreWebKit;
}


@end
