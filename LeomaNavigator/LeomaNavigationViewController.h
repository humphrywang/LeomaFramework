//
//  LeomaNavigationViewController.h
//  Pods
//
//  Created by CorpDev on 21/4/17.
//
//

#import <UIKit/UIKit.h>
#import "UIKit+LeomaNavigation.h"

@interface LeomaNavigationViewController : UIViewController
#pragma mark switch
-(BOOL)canAcceptTask:(LeomaNavigationAction)action;
-(BOOL)canMask;

#pragma mark instruction option
-(void)setRootViewController:(UIViewController*)vc withOptions:(LeomaNavigationOption)flag;
-(void)makeCurrentViewControllerRoot;//如果当前vc是modal型的，会设置modal前的最后一个vc为root
-(void)performInstruction;
-(void)cancelInstruction;

#pragma mark vc stack
-(UIViewController*)standByViewController;
-(UIViewController*)currentViewController;
-(UIViewController*)rootViewController;
-(UIViewController*)prioViewControllerOf:(UIViewController*)vc;
-(UIViewController*)postViewControllerOf:(UIViewController*)vc;

#pragma mark mask option
-(void)presentMask:(UIView*)contentView silent:(BOOL)silent;
-(void)dismissMask:(UIView*)contentView silent:(BOOL)silent;

#pragma mark Navigation Bar Staus Updated
-(void)navigationBarAreaModified:(LeomaNavigationBarArea)area WithBridge:(LeomaNavigationBarBridge*)bridge;
@end
