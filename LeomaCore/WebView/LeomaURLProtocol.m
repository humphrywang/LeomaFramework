//
//  CTURLProtocol.m
//  Corp
//
//  Created by 王宏 on 15/6/25.
//  Copyright (c) 2015年 corp. All rights reserved.
//

#import "LeomaURLProtocol.h"
#import "LeomaModel.h"
#import "Leoma.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define LeomaInterAction @"Interaction"

@interface LeomaURLProtocol()

@end

@implementation LeomaURLProtocol


+ (BOOL)isLeomaInterAction:(NSURL*)url{
    return [url.path.lowercaseString rangeOfString:[NSString stringWithFormat:@"%@/%@", LeomaSpec, LeomaInterAction].lowercaseString].length > 0;
}
#pragma mark - NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    //LeomaFrame request should ignore, request header contains @LeomaNetIgnoreProtocol
    if([NSURLProtocol propertyForKey:LeomaNetIgnoreProtocol inRequest:request]) return NO;
    //LeomaFrame InterAction Api, URL is like "http://host/leoma/interaction?data"
    if([LeomaURLProtocol isLeomaInterAction:request.URL]) return YES;
    if([LocalHost isEqualToString:request.URL.host]) return YES;
    return NO;
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)theRequest
{
    return theRequest;
}

- (void)startLoading {
    if([LeomaURLProtocol isLeomaInterAction:self.request.URL]) [self leomaDespatchInterAction];
    else if([LocalHost isEqualToString:self.request.URL.host]){
        NSURLResponse *response=[[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:[LeomaURLProtocol getMimeType:self.request.URL.pathExtension] expectedContentLength:0 textEncodingName:@"utf-8"];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:[NSData dataWithContentsOfFile:self.request.URL.path]];
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)stopLoading
{
    // NSLog(@"Did stop loading %@",self.request.URL);
}

#pragma mark - Mock responses

-(void)leomaDespatchInterAction{
    id client = [self client];
    LeomaInteractionModel * interAction = [LeomaInteractionModel objectFromDictionary:[[self.request.URL.query urlDecode] JSONToDictionary]];
    interAction.Protocol = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:LeomaInterActionURLProtocol object:interAction];
}

+(NSString*)getMimeType:(NSString*)componet{
    CFStringRef UTI=UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)CFBridgingRetain(componet), NULL);
    CFStringRef MimeType=UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString * mimeType = (NSString*)CFBridgingRelease(MimeType);
    if(!mimeType||mimeType.length==0){
        mimeType=[self getMimeType:@"htm"];
    }
    return mimeType;
}

@end
