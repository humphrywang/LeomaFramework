//
//  NSBundle+LeomaExtension.m
//  LeomaFramework
//
//  Created by CorpDev on 25/4/17.
//
//

#import "NSBundle+LeomaExtension.h"

@implementation NSBundle (Leoma)

-(NSString*)contentOfResource:(NSString*)name OfType:(NSString*)extension encoding:(NSStringEncoding)encoding{
    return [NSString stringWithContentsOfFile:[self pathForResource:name ofType:extension] encoding:encoding error:NULL];
}

@end
