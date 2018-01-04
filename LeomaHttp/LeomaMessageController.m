//
//  CorpBaseModel.m
//  CorpFramework
//
//  Created by corptest on 14-1-7.
//  Copyright (c) 2014年 corp. All rights reserved.
//

#import "LeomaMessageController.h"
#import "LeomaMessage.h"

@interface LeomaMessageController()<LeomaMessageStatusChangeDelegate>

@property (nonatomic, strong) NSMutableArray *      messageArray;

@end

@implementation LeomaMessageController {
    NSMutableArray *_observers;
}
+ (instancetype) standardController LeomaSingleton(LeomaMessageController, instance)

- (void) dealloc
{
    [_observers removeAllObjects];
    [self.messageArray removeAllObjects];
}

- (id) init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype) addObserver:(id)observer
{
    if(!observer || [_observers containsObject:observer]) return self;
    [_observers addObject:observer];
    return self;
}

- (instancetype) removeObserver:(id)observer
{
    if (_observers && observer) {
        [_observers removeObject:observer];
    }
    return self;
}

#pragma mark - message
- (LeomaMessage*) messageAjaxWithURLString:(NSString *)urlString responseClass:(Class)jsonClass{
    LeomaMessage *message = [LeomaMessage messageAjaxWithURLString:urlString responseClass:jsonClass];
    message.messageStatusChangeDelegate = self;
    [self.messageArray addObject:message];
    return message;
}

- (LeomaMessage*) messageGetWithURLString:(NSString *)urlString{
    LeomaMessage *message = [LeomaMessage messageGetWithURLString:urlString];
    message.messageStatusChangeDelegate = self;
    [self.messageArray addObject:message];
    return message;
}

- (LeomaMessage*) messagePostWithURLString:(NSString *)urlString{
    LeomaMessage *message = [LeomaMessage messagePostWithURLString:urlString];
    message.messageStatusChangeDelegate = self;
    [self.messageArray addObject:message];
    return message;
}

- (LeomaMessage*) messageDownloadWithURLString:(NSString *)urlString localPath:(NSString*)path{
    LeomaMessage *message = [LeomaMessage messageDownloadWithURLString:urlString localPath:path];
    message.messageStatusChangeDelegate = self;
    [self.messageArray addObject:message];
    return message;
}

#pragma mark - private

- (void) initialize
{
    _observers = [NSMutableArray arrayUsingWeakReferences];
    [self addObserver:self];
    
    self.messageArray = [NSMutableArray array];
}

#pragma mark - delegate

- (void) logStatus:(LeomaMessage *)message
{
    switch (message.status) {
        case LeomaMessageStatusPreparing:
            LeomaLogg(@"preparing");
            break;
        case LeomaMessageStatusSending:
            LeomaLogg(@"sending");
            break;
        case LeomaMessageStatusCanceled:
            LeomaLogg(@"canceled");
            break;
        case LeomaMessageStatusFailed:
            LeomaLogg(@"failed");
            break;
        case LeomaMessageStatusSuccessed:
            LeomaLogg(@"succeed");
            break;
    }
}

- (void) messageStatusChange:(LeomaMessage *)message
{
    for (id<LeomaMessageObserver> observer in _observers) {
        if (!observer) continue;
        if (!message.finished && [observer respondsToSelector:@selector(sendingMessage:)]){
            [observer sendingMessage:message];
        }else if (message.finished && [observer respondsToSelector:@selector(handleMessage:)]) {
            [observer handleMessage:message];
        }
    }
    
    if (message.finished) {
        [self.messageArray removeObject:message];
    }
    [self logStatus:message];
}

- (void) sendingMessage:(LeomaMessage *)message
{
    
}

- (void) handleMessage:(LeomaMessage *)message
{
}

@end
