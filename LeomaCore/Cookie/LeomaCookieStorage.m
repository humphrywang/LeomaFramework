//
//  LeomaCookieStorage.m
//  LeomaFramework
//
//  Created by CorpDev on 2018/2/1.
//

#import "LeomaCookieStorage.h"

NSString *const LeomaCookieStorageKey = @"leoma_synchronized_cookie_storage";

@interface LeomaCookieStorage()

@property (atomic, strong) NSMutableDictionary * cookieStorage;
@property (nonatomic, strong) NSMutableSet * observers;

@end

@implementation LeomaCookieStorage

#pragma mark Observer
-(void)addObserver:(id<LeomaCookieObserver>)observer{
    if(!observer) return;
    [self.observers addObject:observer];
}

-(void)removeObserver:(id<LeomaCookieObserver>)observer{
    if(!observer) return;
    [self.observers removeObject:observer];
}

+(LeomaCookieStorage *)sharedCookieStorage LeomaSingleton(LeomaCookieStorage, instance)

-(instancetype)init{
    self = [super init];
    if(self){
        self.cookieStorage = [[NSUserDefaults standardUserDefaults] objectForKey:LeomaCookieStorageKey];
        self.observers = [NSMutableSet setUsingWeakReferences];
    }
    return self;
}
#pragma mark APIs
-(void)storeCookie:(NSString*)cookie forName:(NSString*)name forDomain:(NSString*)domain{
    domain = legalizedDomain(domain);
    if([NSString isBlank:domain]) return;
    NSMutableDictionary * storage = [self cookieStorageForDomain:domain];
    if(![self cookieStorageSet:cookie ofName:name ofDomain:domain toStorage:storage]) return;
    [self synchronizeCookieStorage];
    synchronizeCookieToNative(name, cookie, domain);
}

-(void)storeCookies:(NSString*)cookieString forDomain:(NSString*)domain{
    domain = legalizedDomain(domain);
    if([NSString isBlank:domain]) return;
    NSMutableDictionary * storage = [self cookieStorageForDomain:domain];
    NSArray * cookieTokens = [cookieString componentsSeparatedByString:@"; "];
    for(NSString * cookieToken in cookieTokens){
        NSArray * cookie = [[cookieToken componentsSeparatedByString:@";"][0] componentsSeparatedByString:@"="];
        NSString * name = cookie[0];
        NSString * value = cookie.count < 2 ? nil : cookie[1];
        if(![self cookieStorageSet:value ofName:name ofDomain:domain toStorage:storage]) continue;
        synchronizeCookieToNative(name, value, domain);
    }
    [self synchronizeCookieStorage];
}

-(void)storeCookieEntities:(NSDictionary *)cookieEntity forDomain:(NSString *)domain{
    domain = legalizedDomain(domain);
    if([NSString isBlank:domain]) return;
    NSMutableDictionary * storage = [self cookieStorageForDomain:domain];
    [cookieEntity enumerateKeysAndObjectsUsingBlock:^(NSString * name, NSString * value, BOOL *  stop) {
        if(![self cookieStorageSet:value ofName:name ofDomain:domain toStorage:storage]) return ;
        synchronizeCookieToNative(name, value, domain);
    }];
    [self synchronizeCookieStorage];
}

-(NSString*)fetchCookiesForDomain:(NSString*)domain{
    domain = legalizedDomain(domain);
    if([NSString isBlank:domain]) return @"";
    return cookieEntityToString([self cookieStorageForDomain:domain]);
}
-(NSString*)fetchCookieForName:(NSString*)name forDomain:(NSString*)domain{
    domain = legalizedDomain(domain);
    if([NSString isBlank:domain]) return @"";
    return [[self cookieStorageForDomain:domain] objectForKey:name];
}

-(NSDictionary*)fetchCookieEntitiesForDomain:(NSString*)domain{
    domain = legalizedDomain(domain);
    if([NSString isBlank:domain]) return @{};
    return [NSDictionary dictionaryWithDictionary:[self cookieStorageForDomain:domain]];
}

-(void)dumplicateCookieFromHome:(NSString *)home toTargets:(NSArray<NSString *> *)targets{
    NSDictionary * storage = [self cookieStorageForDomain:legalizedDomain(home)];
    for(NSString * target in targets){
        NSString * host = legalizedDomain(target);
        self.cookieStorage[host] = [NSMutableDictionary dictionaryWithDictionary:storage];
        synchronizeCookiesToNative(storage, host);
    }
    [self synchronizeCookieStorage];
}

#pragma mark Private APIs
//init cookie storage
-(void)setCookieStorage:(NSDictionary *)cookieStorage{
    _cookieStorage = [NSMutableDictionary dictionary];
    [cookieStorage enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* storage, BOOL * stop) {
        _cookieStorage[key] = [NSMutableDictionary dictionaryWithDictionary:storage];
    }];
}

-(BOOL)cookieStorageSet:(NSString*)value ofName:(NSString*)name ofDomain:(NSString*)domain toStorage:(NSMutableDictionary*)entity{
    if([NSString isBlank:name]) return NO;
    [entity setObject:[NSString isBlank:value] ? @"" : value forKey:name];
    leoma_dispatch_main(^{
        [self.observers enumerateObjectsUsingBlock:^(id<LeomaCookieObserver> observer, BOOL * stop) {
            if(!observer) return ;
            [observer onCookieModified:value ofName:name ofDomain:domain];
        }];
    });
    return YES;
}

NSMutableDictionary * cookieStringToEntity(NSString* cookieString){
    NSMutableDictionary * cookieEntity = [NSMutableDictionary dictionary];
    NSArray * cookieTokens = [cookieString componentsSeparatedByString:@"; "];
    for(NSString * cookieToken in cookieTokens){
        NSArray * cookie = [[cookieToken componentsSeparatedByString:@";"][0] componentsSeparatedByString:@"="];
        if(cookie.count < 2) continue;
        [cookieEntity setObject:cookie[1] forKey:cookie[0]];
    }
    return cookieEntity;
}
NSString * cookieEntityToString(NSDictionary* cookieEntity){
    NSMutableString * cookieString = [NSMutableString string];
    [cookieEntity enumerateKeysAndObjectsUsingBlock:^(NSString * name, NSString * value, BOOL *  stop) {
        [cookieString appendFormat:@"%@=%@; ", name, [NSString isBlank:value] ? @"" : value];
    }];
    return cookieString;
}

NSString * legalizedDomain(id domain){
    NSString * host = nil;
    if(!domain || [domain isKindOfClass:[NSNull class]]) host = nil;
    else if([domain isKindOfClass:[NSString class]]){
        NSURL * url = [NSURL URLWithString:domain];
        if(!url || [NSString isBlank:url.host]) host = domain;
        else host = url.host;
    }
    else if([domain respondsToSelector:@selector(host)]) host = [domain host];
    return host ?: @"";
}

-(NSMutableDictionary*)cookieStorageForDomain:(NSString*)domain{
    domain = domain.lowercaseString.blankTrim;
    NSMutableDictionary * storage = self.cookieStorage[domain];
    if(!storage){
        storage = [NSMutableDictionary dictionary];
        self.cookieStorage[domain] = storage;
    }
    return storage;
}

-(void)synchronizeCookieStorage{
    [[NSUserDefaults standardUserDefaults] setObject:self.cookieStorage forKey:LeomaCookieStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//sync native cookie to nshttpcookiestorage
void synchronizeCookiesToNative(NSDictionary* cookies, NSString* domain){
    [cookies enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSString* value, BOOL * stop) {
        synchronizeCookieToNative(name, value, domain);
    }];
}

void synchronizeCookieToNative(NSString* name, NSString* value, NSString* domain){
    if([NSString isNotBlank:value]){
        NSHTTPCookie * cookie = generateCookie(name, value, domain);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }else{
        NSArray<NSHTTPCookie*>* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", domain]]];
        for(NSHTTPCookie * cookie in cookies){
            if(cookie && [cookie.name isEqualToString:name]){
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                return;
            }
        }
    }
}

NSHTTPCookie* generateCookie(NSString* name, NSString* value, NSString* domain){
    NSDictionary * info = @{
                            NSHTTPCookieDomain: domain,
                            NSHTTPCookieName: name,
                            NSHTTPCookieValue: value,
                            NSHTTPCookiePath: @"/",
                            NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 365]
                            };
    return [NSHTTPCookie cookieWithProperties:info];
}

@end
