//
//  LeomaApplication.m
//  Pods
//
//  Created by CorpDev on 8/5/17.
//
//

#import "LeomaApplication.h"
#import "Leoma.h"
@interface LeomaApplication()
@end

@implementation LeomaApplication
-(void)sendEvent:(UIEvent *)event{
    return [super sendEvent:event];
//    if(![Leoma sharedLeoma].preference.InterceptEvent || ![[LeomaTouchDispatcher sharedDispatcher] decideEvent:event]) return [super sendEvent:event];
}

@end

