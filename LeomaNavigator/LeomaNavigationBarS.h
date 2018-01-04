//
//  LeomaNavigationBar.h
//  LeomaFramework
//
//  Created by CorpDev on 2017/11/7.
//

#import <UIKit/UIKit.h>
#import "LeomaEffectiveNavigation.h"

typedef NS_ENUM(NSInteger, LeomaBarPosition){
    LeomaBarPositionLeft,
    LeomaBarPositionRight
};
@interface LeomaBarItemS : NSObject

-(BOOL)isStyleTitle;

@property (copy, nonatomic) NSString * title;
@property (assign, nonatomic) LeomaBarItemStyle style;
@property (assign, readonly) NSUInteger index;

-(instancetype)initWithTitle:(NSString *)title delegate:(id<LeomaNavigationSceneDelegate>)delegate index:(NSUInteger)index;
-(instancetype)initWithStyle:(LeomaBarItemStyle)style delegate:(id<LeomaNavigationSceneDelegate>)delegate index:(NSUInteger)index;

@end

@class LeomaNavigationBarBridge;
@interface LeomaNavigationBarS : UIView

-(void)setLeftBarItem:(NSString*)title;//title 为nil时，使用返回图标，为string时使用显示名字，并且隐藏头部动画与左标题
-(void)setRightBarItems:(NSArray<id>*)styles;

-(void)prepareNavigation:(LeomaNavigationConfig*)config;
-(void)performNavigation:(LeomaNavigationConfig*)config;
-(void)performNavigation:(CGPoint)position OfConfig:(LeomaNavigationConfig*)config;
-(void)finishNavigation:(LeomaNavigationConfig*)config;

-(void)updateLeftGuide:(NSString*)guide;
-(void)updateNavigationBarArea:(LeomaNavigationBarArea)area WithBridge:(LeomaNavigationBarBridge *)bridge;

@end
