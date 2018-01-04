//
//  UIViewController+LeomaExtension.m
//  LeomaFramework
//
//  Created by corptest on 14-3-19.
//
//

#import "UIViewController+LeomaExtension.h"
#import "UIView+LeomaExtension.h"

@implementation UIViewController (Leoma)

- (NSArray *) sortedInputs
{
    return [self.view sortedInputs];
}

- (UIView *) focusInput
{
    NSArray *allInput = [self sortedInputs];
    for (UIView *input in allInput) {
        if ([input isFirstResponder]) {
            return input;
        }
    }
    return nil;
}
@end
