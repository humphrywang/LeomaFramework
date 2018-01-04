//
//  LeomaMessageController.h
//  LeomaFramework
//
//  Created by corptest on 14-1-7.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LeomaMessage;

@protocol LeomaMessageObserver <NSObject>

@optional

- (void) sendingMessage:(LeomaMessage *)message;

- (void) handleMessage:(LeomaMessage *)message;

@end

@interface LeomaMessageController : NSObject <LeomaMessageObserver>

+ (instancetype) standardController;

- (instancetype) addObserver:(id<LeomaMessageObserver>)observer;

- (instancetype) removeObserver:(id<LeomaMessageObserver>)observer;

#pragma mark - message

- (LeomaMessage*) messageAjaxWithURLString:(NSString *)urlString responseClass:(Class)jsonClass;

- (LeomaMessage*) messageGetWithURLString:(NSString *)urlString;

- (LeomaMessage*) messagePostWithURLString:(NSString *)urlString;

- (LeomaMessage*) messageDownloadWithURLString:(NSString *)urlString localPath:(NSString*)path;

@end
