//
//  LeomaSystem.h
//  LeomaFramework
//
//  Created by CorpDev on 14-3-21.
//
//  系统和app信息


/**buildIn Model Version与具体设备的对照关系
 *  iPhone1,1      iPhone 1G";
 *  iPhone1,2      iPhone 3G";
 *  iPhone2,1      iPhone 3GS";
 *  iPhone3,1      iPhone 4
 *  iPhone3,2      iPhone 4
 *  iPhone3,3      iPhone 4
 *  iPhone4,1      iPhone 4S
 *  iPhone5,1      iPhone 5
 *  iPhone5,2      iPhone 5 (GSM+CDMA)
 *  iPhone5,3      iPhone 5c (GSM)
 *  iPhone5,4      iPhone 5c (GSM+CDMA)
 *  iPhone6,1      iPhone 5s (GSM)
 *  iPhone6,2      iPhone 5s (GSM+CDMA)
 *  iPhone7,1      iPhone 6 Plus
 *  iPhone7,2      iPhone 6
 *  iPhone8,1      iPhone 6s
 *  iPhone8,2      iPhone 6s Plus
 *  iPhone8,4      iPhone SE
 *  iPhone9,1      国行、日版、港行iPhone 7
 *  iPhone9,2      港行、国行iPhone 7 Plus
 *  iPhone9,3      美版、台版iPhone 7
 *  iPhone9,4      美版、台版iPhone 7 Plus
 *  iPhone10,1     iPhone 8
 *  iPhone10,2     iPhone 8 Plus
 *  iPhone11,1     iPhone X
 *
 *  iPod1,1        iPod Touch 1G
 *  iPod2,1        iPod Touch 2G
 *  iPod3,1        iPod Touch 3G
 *  iPod4,1        iPod Touch 4G
 *  iPod5,1        iPod Touch (5 Gen)
 
 *  iPad1,1        iPad
 *  iPad1,2        iPad 3G
 *  iPad2,1        iPad 2 (WiFi)
 *  iPad2,2        iPad 2
 *  iPad2,3        iPad 2 (CDMA)
 *  iPad2,4        iPad 2
 *  iPad2,5        iPad Mini (WiFi)
 *  iPad2,6        iPad Mini
 *  iPad2,7        iPad Mini (GSM+CDMA)
 *  iPad3,1        iPad 3 (WiFi)
 *  iPad3,2        iPad 3 (GSM+CDMA)
 *  iPad3,3        iPad 3
 *  iPad3,4        iPad 4 (WiFi)
 *  iPad3,5        iPad 4
 *  iPad3,6        iPad 4 (GSM+CDMA)
 *  iPad4,1        iPad Air (WiFi)
 *  iPad4,2        iPad Air (Cellular)
 *  iPad4,4        iPad Mini 2 (WiFi)
 *  iPad4,5        iPad Mini 2 (Cellular)
 *  iPad4,6        iPad Mini 2
 *  iPad4,7        iPad Mini 3
 *  iPad4,8        iPad Mini 3
 *  iPad4,9        iPad Mini 3
 *  iPad5,1        iPad Mini 4 (WiFi)
 *  iPad5,2        iPad Mini 4 (LTE)
 *  iPad5,3        iPad Air 2
 *  iPad5,4        iPad Air 2
 *  iPad6,3        iPad Pro 9.7
 *  iPad6,4        iPad Pro 9.7
 *  iPad6,7        iPad Pro 12.9
 *  iPad6,8        iPad Pro 12.9
 *
 *  AppleTV2,1      Apple TV 2
 *  AppleTV3,1      Apple TV 3
 *  AppleTV3,2      Apple TV 3
 *  AppleTV5,3      Apple TV 4
 *
 *  i386         Simulator
 *  x86_64       Simulator
 
 */

#ifndef LeomaSystem_h
#define LeomaSystem_h

#define Screen_Width [LeomaSystem screenBounds].size.width
#define Screen_Height [LeomaSystem screenBounds].size.height
#define Screen_Scale [UIScreen mainScreen].scale

#define Platform_iPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Platform_iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IOS_6_OR_LATER		    ([[[UIDevice currentDevice] systemVersion] intValue] >= 6)
#define IOS_7_OR_LATER		    ([[[UIDevice currentDevice] systemVersion] intValue] >= 7)
#define IOS_8_OR_LATER		    ([[[UIDevice currentDevice] systemVersion] intValue] >= 8)
#define IOS_9_OR_LATER		    ([[[UIDevice currentDevice] systemVersion] intValue] >= 9)
#define IOS_10_OR_LATER		    ([[[UIDevice currentDevice] systemVersion] intValue] >= 10)
#define IOS_11_OR_LATER		    ([[[UIDevice currentDevice] systemVersion] intValue] >= 11)

#define IOS_6_OR_EARLIER		([[[UIDevice currentDevice] systemVersion] intValue] <= 6)
#define IOS_7_OR_EARLIER		([[[UIDevice currentDevice] systemVersion] intValue] <= 7)
#define IOS_8_OR_EARLIER		([[[UIDevice currentDevice] systemVersion] intValue] <= 8)
#define IOS_9_OR_EARLIER		([[[UIDevice currentDevice] systemVersion] intValue] <= 9)
#define IOS_10_OR_EARLIER	    ([[[UIDevice currentDevice] systemVersion] intValue] <= 10)
#define IOS_11_OR_EARLIER	    ([[[UIDevice currentDevice] systemVersion] intValue] <= 11)

#define IS_IOS_6                ([[[UIDevice currentDevice] systemVersion] intValue] == 6)
#define IS_IOS_7                ([[[UIDevice currentDevice] systemVersion] intValue] == 7)
#define IS_IOS_8                ([[[UIDevice currentDevice] systemVersion] intValue] == 8)
#define IS_IOS_9                ([[[UIDevice currentDevice] systemVersion] intValue] == 9)
#define IS_IOS_10               ([[[UIDevice currentDevice] systemVersion] intValue] == 10)
#define IS_IOS_11               ([[[UIDevice currentDevice] systemVersion] intValue] == 11)

#define Device_Is_Screen_Size(__width, __height) ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(__width, __height), [[UIScreen mainScreen] currentMode].size) : NO)
#define Is_iPhone_4inch         (Device_Is_Screen_Size(640, 1136))//iphone 5
#define Is_iPhone_Non_Retina    (Device_Is_Screen_Size(320, 640))//iphone 4 & -
#define Is_iPhone_Retina        (Device_Is_Screen_Size(640, 960))//iphone 4s
#define Is_iPhone_4_7inch       (Device_Is_Screen_Size(750, 1334))//iphone 6 & 7
#define Is_iPhone_5_5inch       (Device_Is_Screen_Size(1242, 2208)||Corp_Device_Is_Screen_Size(1125, 2001))//iphone XP 放大模式下分辨率为2001*1125//
#define Is_iPhone_5_8inch       (Device_Is_Screen_Size(1125, 2436))//iphone x
#define Is_iPad_Non_Retina      (Device_Is_Screen_Size(768, 1024))
#define Is_iPad_Retina          (Device_Is_Screen_Size(1536, 2048))
#define Is_iPad_Pro             (Device_Is_Screen_Size(2048, 2732))//iPad Pro

#define IOS_JSCore              IOS_7_OR_LATER//7.0开始支持JSCore
#define IOS_ImmersiveStatusBar  IOS_JSCore//7.0开始使用沉浸式状态栏
#define IOS_WebKit              IOS_8_OR_LATER//8.0开始支持WKWebView
#define IOS_FileRequest         IOS_9_OR_LATER//9.0开始WKWebView支持加载本地文件夹中的文件
#define __High_Effect_Model     if([LeomaSystem modelVersion] >= 5 + (Platform_iPhone ? 1 : 0))
#define __Low_Effect_Model      if([LeomaSystem modelVersion] < 5 + (Platform_iPhone ? 1 : 0))

#define DECGeneric(name) +(Class)GenericClassOf##name;
#define RELGeneric(name, clazz) +(Class)GenericClassOf##name { return clazz;}
#endif

@interface LeomaSystem : NSObject

#pragma mark - system

+ (NSString *) macAddress;
+ (NSString *) deviceUID;
+ (NSString *) systemVersion;
+ (NSString *) deviceModel;
+ (NSString *) machine;
+ (NSString *) modelDetail;
+ (float) modelVersion;
+ (NSString *) uniqueDeviceIdentifier;//mac+bundleid => md5
+ (NSString *) uniqueGlobalDeviceIdentifier;//mac => md5
+ (NSString *) idfa;

+ (CGSize) screenSizeInPixel;
+ (CGRect) screenBounds;

#pragma mark - app

+ (NSString *) appVersion;
+ (NSString *) appBuildVersion;
+ (NSString *) appIdentifier;
+ (NSString *) appURLScheme;

+ (NSString *) documentsDirectory;
+ (NSString *) documentsContentPath:(NSString *)virtulaPath;

@end
//GCD
#define leoma_dispatch_once(block) {\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, block);\
}
void leoma_dispatch_back(void(^block)());
void leoma_dispatch_main(void(^block)());
void leoma_dispatch_back_delay(void(^block)(), NSTimeInterval delay);
void leoma_dispatch_main_delay(void(^block)(), NSTimeInterval delay);
