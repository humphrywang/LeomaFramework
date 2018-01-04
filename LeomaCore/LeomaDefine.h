//
//  LeomaDefine.h
//  Leoma
//
//  Created by CorpDev on 31/3/17.
//  Copyright © 2017年 Ctrip.Com (Hong Kong) Limited. All rights reserved.
//

#ifndef LeomaDefine_h
#define LeomaDefine_h

#define LeomaVersion 1.0
#define LeomaSpec @"Leoma"
#define LeomaBundle @"LeomaBundle"
#define LeomaEmpty @""
#define WebContenntTimeOut 15.0
#define LeomaSessionTimeOut 30.0
#define LeomaDebug YES
#define LocalHost @"localhost"

//Notification Tags
#define LeomaWebViewCorePrefModified @"leomawebviewcoreprefmodified"
#define LeomaInterceptsEvent @"leomainterceptsevent"
#define LeomaInterActionURLProtocol @"leomainteractionurlptotocol"

//Tags
#define LeomaNetIgnoreProtocol @"netignoreprotocol"

//Functionality
#define LeomaLogg(...) if(LeomaDebug)NSLog(@"<Leoma[%@]> %@", @(LeomaVersion), [NSString stringWithFormat:__VA_ARGS__]);

#define LeomaHandlerClass(arg) [NSString stringWithFormat:@"Leoma%@", arg]

#define LeomaSingletonWithOnceBlock(clazz, name, block) {static clazz * name;\
leoma_dispatch_once(^{name = [[clazz alloc] init]; void(^handler)(void) = block; if(handler) handler();});\
return name;}\

#define LeomaSingleton(clazz, name) LeomaSingletonWithOnceBlock(clazz, name, nil)

#endif /* LeomaDefine_h */
