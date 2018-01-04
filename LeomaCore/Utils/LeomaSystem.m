//
//  LeomaSystem.m
//  LeomaFramework
//
//  Created by CorpDev on 14-3-21.
//
//

#import "LeomaSystem.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "sys/utsname.h"
#import "NSString+MD5Addition.h"
#import <AdSupport/AdSupport.h>

@implementation LeomaSystem

#pragma mark - system

+ (NSString *) macAddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

+ (NSString *) systemVersion
{
    return [UIDevice currentDevice].systemVersion;
}
+ (NSString *) deviceModel
{
    return [UIDevice currentDevice].model;
}
+ (NSString *) machine
{
    struct utsname u;
    uname(&u);
    return [NSString stringWithFormat:@"%s", u.machine];
}

+ (NSString *) modelDetail{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (float) modelVersion{
    NSString *modelDetail = [self modelDetail];
    return [[[modelDetail stringByReplacingOccurrencesOfString:@"[^\\d,]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, modelDetail.length)] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
    
}
+ (NSString *) uniqueDeviceIdentifier{
    NSString *macaddress = [self macAddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
    NSString *uniqueIdentifier = [stringToHash stringFromMD5];
    
    return uniqueIdentifier;
}

+ (NSString *) uniqueGlobalDeviceIdentifier{
    NSString *macaddress = [self macAddress];
    NSString *uniqueIdentifier = [macaddress stringFromMD5];
    
    return uniqueIdentifier;
}

+(NSString *)idfa{
    return nil;
//    return [[[[ASIdentifierManager alloc] init] advertisingIdentifier] UUIDString];
}

+ (CGSize) screenSizeInPixel
{
    return [UIScreen mainScreen].currentMode.size;
}

+ (CGRect) screenBounds
{
    return [UIScreen mainScreen].bounds;
}

#pragma mark - app

+ (NSString *) appVersion;
{
    NSString *ret = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersion"];
    return ret?ret:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
+ (NSString *) appBuildVersion;
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}
+ (NSString *) appIdentifier;
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}
+ (NSString *) appURLScheme
{
    NSArray* urlTypes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    return [[urlTypes.firstObject objectForKey:@"CFBundleURLSchemes"] asNSArray].firstObject;
}

+ (NSString *) documentsDirectory
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}
+ (NSString *) documentsContentPath:(NSString *)virtualPath
{
    return [NSString stringWithFormat:@"%@%@", [self documentsDirectory], virtualPath];
}

@end
//GCD
void leoma_dispatch_back(void(^block)()){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
void leoma_dispatch_main(void(^block)()){
    dispatch_async(dispatch_get_main_queue(), block);
}

void leoma_dispatch_back_delay(void(^block)(), NSTimeInterval delay){
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

void leoma_dispatch_main_delay(void(^block)(), NSTimeInterval delay){
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), block);
}
