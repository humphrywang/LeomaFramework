//
//  LeomaWebViewPreference.h
//  Pods
//
//  Created by CorpDev on 2017/9/28.
//
//

#import <Foundation/Foundation.h>
#import "LeomaWebProtocol.h"

@interface LeomaCoreConfig : NSObject

@property (assign, nonatomic) LeomaCoreEffect core;
@property (assign, nonatomic) LeomaCoreSync sync;
@property (assign, nonatomic) LeomaCoreAsync async;

+(instancetype)defaultConfig;

@end

@interface LeomaWebViewPreference : NSObject
@property (readonly) BOOL webKitInside;
@property (readonly) NSString * InjectScript;

-(instancetype)initWithConfig:(LeomaCoreConfig*)config;

-(void)registerLeomaEnvironment:(NSDictionary*)userInfo;

@end
