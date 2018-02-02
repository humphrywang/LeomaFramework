//
//  LeomaBuildIn.h
//  LeomaFramework
//
//  Created by CorpDev on 2018/2/1.
//

#import <Foundation/Foundation.h>
#import "LeomaModel.h"
@interface LeomaBuildIn : NSObject

//cookie
+(LeomaHandler)cookie_updated;
+(LeomaHandler)cookie_fetch;

//Function
+(LeomaHandler)console_log;

@end
