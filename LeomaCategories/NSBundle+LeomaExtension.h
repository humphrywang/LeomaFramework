//
//  NSBundle+LeomaExtension.h
//  LeomaFramework
//
//  Created by CorpDev on 25/4/17.
//
//

#import <Foundation/Foundation.h>

@interface NSBundle (Leoma)

-(NSString*)contentOfResource:(NSString*)name OfType:(NSString*)extension encoding:(NSStringEncoding)encoding;

@end
