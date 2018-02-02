//
//  LeomaCookieStorage.h
//  LeomaFramework
//
//  Created by CorpDev on 2018/2/1.
//

#import <Foundation/Foundation.h>

@protocol LeomaCookieObserver

-(void)onCookieModified:(NSString*)value ofName:(NSString*)name ofDomain:(NSString*)domain;

@end

@interface LeomaCookieStorage : NSObject

@property (class, readonly) LeomaCookieStorage * sharedCookieStorage;

-(void)addObserver:(id<LeomaCookieObserver>)observer;
-(void)removeObserver:(id<LeomaCookieObserver>)observer;

-(void)storeCookie:(NSString*)cookie forName:(NSString*)name forDomain:(NSString*)domain;
-(void)storeCookies:(NSString*)cookieString forDomain:(NSString*)domain;

-(NSString*)fetchCookiesForDomain:(NSString*)domain;
-(NSString*)fetchCookieForName:(NSString*)name forDomain:(NSString*)domain;

-(void)storeCookieEntities:(NSDictionary*)cookieEntity forDomain:(NSString*)domain;
-(NSDictionary*)fetchCookieEntitiesForDomain:(NSString*)domain;

-(void)dumplicateCookieFromHome:(NSString*)home toTargets:(NSArray<NSString*>*)targets;

@end
