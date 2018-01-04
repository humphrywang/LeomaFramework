//
//  NSData+LeomaExtension.h
//  LeomaFramework
//
//  Created by CorpDev on 2017/11/23.
//

#import <Foundation/Foundation.h>

@protocol LeomaBundleProtocol

-(void) saveToLeoma:(NSString*)name;
+(instancetype) loadFromLeoma:(NSString*)name;
+(void) deleteFromLeoma:(NSString*)name;

@end

@interface NSData (LeomaExtension) <LeomaBundleProtocol>

-(NSDictionary *) JSONDataToDictionary;

@end
