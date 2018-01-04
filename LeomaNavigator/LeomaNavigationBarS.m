//
//  LeomaNavigationBar.m
//  LeomaFramework
//
//  Created by CorpDev on 2017/11/7.
//

#import "LeomaNavigationBarS.h"
#import "UIKit+LeomaNavigation.h"

typedef NS_ENUM(NSInteger, LeomaNavigationTitle){
    LeomaNavigationTitleLeft,
    LeomaNavigationTitleCenter,
    LeomaNavigationTitleRight,
    LeomaNavigationTitleFarLeft = 5
};

@interface LeomaBarItemS()

@property (strong, nonatomic) UIButton * barItem;
@property (weak, nonatomic) id<LeomaNavigationSceneDelegate> delegate;
@property (weak, nonatomic) NSLayoutConstraint * widthConstraint;
@property (weak, nonatomic) NSLayoutConstraint * heightConstraint;

@end

@interface LeomaNavigationBarS() <LeomaNavigationSceneDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIView *BarContent;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *LeftItemHolder;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *RightItemHolder;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *TitleHolder;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSMutableArray *NaviTitles;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *StaticTitle;

@property (strong, nonatomic) NSMutableArray<LeomaBarItemS*>* leftItems;
@property (strong, nonatomic) NSMutableArray<LeomaBarItemS*>* rightItems;

@property (assign, nonatomic) int anchor;
@property (assign, nonatomic) BOOL navigating;

@end

@implementation LeomaNavigationBarS

-(BOOL)isPlaceHolder{
    return self.subviews.count == 0;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.leftItems = [NSMutableArray array];
    self.rightItems = [NSMutableArray array];
    [self barInit];
}

-(void)barInit{
    self.frame = CGRectMake(0, 0, Screen_Width, LeomaNavigation.navigationBarHeight);
    [self setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | NSLayoutAttributeLeftMargin | NSLayoutAttributeRightMargin];
    self.anchor = 1;
    [self pushBarItem:[[LeomaBarItemS alloc] initWithStyle:LeomaBarItemStyleNavi delegate:self index:0] AtPosition:LeomaBarPositionLeft];
}

-(void)setLeftBarItem:(id)item{
    LeomaBarItemS * navi = self.leftItems.firstObject;
    if(!item){
        [navi setStyle:LeomaBarItemStyleNavi];
    }else if(item && [item isKindOfClass:[NSString class]]){
        [navi setTitle:item];
    }else if([item isKindOfClass:[NSNumber class]]){
        [navi setStyle:[item integerValue]];
    }
}

-(void)setTitleContent:(BOOL)animated{
    self.TitleHolder.hidden = !animated;
    self.StaticTitle.hidden = animated;
}

-(void)updateLeftGuide:(NSString *)guide{
    [self updateTitle:LeomaNavigationTitleLeft content:guide];
}
-(void)updateNavigationBarArea:(LeomaNavigationBarArea)area WithBridge:(LeomaNavigationBarBridge *)bridge{
    switch (area) {
        case LeomaNavigationBarAreaRight:
            return [self updateBarRightArea:bridge];
        case LeomaNavigationBarAreaCenter:
            return [self updateBarCenterArea:bridge];
        case LeomaNavigationBarAreaLeft:
            return [self updateBarLeftArea:bridge];
    }
}

-(void)updateBarLeftArea:(LeomaNavigationBarBridge *)bridge{
    [self setLeftBarItem:bridge.left];
    if([bridge.left isKindOfClass:[NSString class]]) [self setTitleContent:NO];
}
-(void)updateBarRightArea:(LeomaNavigationBarBridge *)bridge{
    [self setRightBarItems:bridge.right];
}
-(void)updateBarCenterArea:(LeomaNavigationBarBridge *)bridge{
    [self updateTitle:LeomaNavigationTitleCenter content:bridge.title];
    [self.StaticTitle setTitle:bridge.title forState:UIControlStateNormal];
}

-(void)finishNavigation:(LeomaNavigationConfig *)config{
    [self.StaticTitle setTitle:config.presentingVC.bridge.title forState:UIControlStateNormal];
    [self updateTitle:LeomaNavigationTitleLeft content:config.presentingVC.prioViewController.bridge.title];
    [self updateTitle:LeomaNavigationTitleCenter content:config.presentingVC.bridge.title];
    [self setTitleContent:config.action == LeomaNavigationActionPush && !self.leftItems.firstObject.isStyleTitle];
    if(config.presentingVC.bridge.style == LeomaNavigationBarHidden){
        [self removeFromSuperview];
    }
}

-(void)performNavigation:(LeomaNavigationConfig *)config{
    UIViewController * presenting = config.presentingVC;
    UIViewController * dismissing = config.dismissingVC;
    if(presenting.bridge.style == LeomaNavigationBarHidden){
        switch (config.action) {
            case LeomaNavigationActionPush:
                self.origin = config.reverse ? CGPointMake(Screen_Width, 0) : CGPointMake(- Screen_Width / 2, 0);
                break;
            case LeomaNavigationActionModal:
                self.origin = config.reverse ? CGPointMake(0, Screen_Height) : CGPointZero;
                break;
            case LeomaNavigationActionTab:
                self.origin = CGPointMake(Screen_Width, 0);
                break;
        }
    }else {
        self.origin = CGPointZero;
    }
    self.anchor = self.anchor + (config.reverse ? 2 : 1);
    [self relocateTitle:LeomaNavigationTitleCenter];
    [self relocateTitle:LeomaNavigationTitleLeft];
    [self relocateTitle:config.reverse ? LeomaNavigationTitleRight : LeomaNavigationTitleFarLeft];
}

-(void)prepareNavigation:(LeomaNavigationConfig *)config{
    UIViewController * presenting = config.presentingVC;
    UIViewController * dismissing = config.dismissingVC;
    [self setBackgroundColor:UIColor.leomaBackground];
    LeomaNavigationBarBridge * barBridge = presenting.bridge.style == LeomaNavigationBarHidden ? dismissing.bridge : presenting.bridge;
    [self setLeftBarItem:barBridge.left];
    [self setRightBarItems:barBridge.right];
    if(!self.superview){
        switch (config.action) {
            case LeomaNavigationActionPush:
                self.origin = !config.reverse ? CGPointMake(Screen_Width, 0) : CGPointMake(- Screen_Width / 2, 0);
                break;
            case LeomaNavigationActionModal:
                self.origin = !config.reverse ? CGPointMake(0, Screen_Height) : CGPointZero;
                break;
            case LeomaNavigationActionTab:
                self.origin = CGPointMake(Screen_Width, 0);
                break;
        }
        if (presenting.bridge.style != LeomaNavigationBarHidden){
            [self removeFromSuperview];
            [presenting.view.superview insertSubview:self aboveSubview:presenting.view];
        }
    }else if(presenting.bridge.style == LeomaNavigationBarHidden){
        [self removeFromSuperview];
        [presenting.view.superview insertSubview:self aboveSubview:dismissing.view];
    }else {
        [self removeFromSuperview];
        [presenting.view.superview addSubview:self];
    }
    [self.TitleHolder layoutIfNeeded];
    if(config.reverse){
        [self updateTitle:LeomaNavigationTitleFarLeft content:presenting.prioViewController.bridge.title];
    }else{
        [self updateTitle:LeomaNavigationTitleRight content:presenting.bridge.title];
    }
    
}

-(void)setRightBarItems:(NSArray<NSNumber*>*)styles{
    [self clearBarItems:LeomaBarPositionRight];
    [styles enumerateObjectsUsingBlock:^(id item, NSUInteger i, BOOL * stop) {
        if([item isKindOfClass:[NSNumber class]]){
            LeomaBarItemStyle style = [item integerValue];
            if(style < 0 || style > LeomaBarItemStyleEnd) return;
            [self pushBarItem:[[LeomaBarItemS alloc] initWithStyle:style delegate:self index:i + 1] AtPosition:LeomaBarPositionRight];
        }else if([item isKindOfClass:[NSString class]]){
            [self pushBarItem:[[LeomaBarItemS alloc] initWithTitle:item delegate:self index:i + 1] AtPosition:LeomaBarPositionRight];
        }
    }];
}

-(void)clearBarItems:(LeomaBarPosition)position{
    [[self itemsOfPosition:position] removeAllObjects];
    [[self containerOfPosition:position] clearSubView];
}

-(void)pushBarItem:(LeomaBarItemS *)item AtPosition:(LeomaBarPosition)position{
    NSMutableArray<LeomaBarItemS*>* items = [self itemsOfPosition:position];
    UIView * container = [self containerOfPosition:position];
    [container clearSubView];
    [items addObject:item];
    [items enumerateObjectsUsingBlock:^(LeomaBarItemS* item, NSUInteger i, BOOL * stop) {
        [container addSubview:item.barItem];
    }];
    [self organizeBarItems:items OfContainer:container];
}

-(void)organizeBarItems:(NSArray<LeomaBarItemS*>*)items OfContainer:(UIView*)container{
    [items enumerateObjectsUsingBlock:^(LeomaBarItemS * item, NSUInteger i, BOOL * stop) {
        UIView * view = item.barItem;
        UIView * left = i == 0 ? container : items[i - 1].barItem;
        UIView * right = i == items.count - 1 ? container : items[i + 1].barItem;
        NSString * leftFormat = left == container ? @"|-5" : @"[left]-20";
        NSString * rightFormat = right == container ? @"5-|" : @"20-[right]";
        NSDictionary * views = NSDictionaryOfVariableBindings(left, view, right);
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@-[view]-%@", leftFormat, rightFormat]
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
        [container addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:container
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
    }];
    [container layoutIfNeeded];
}

#pragma mark function

-(NSMutableArray<LeomaBarItemS*>*)itemsOfPosition:(LeomaBarPosition)position{
    return position == LeomaBarPositionLeft ? self.leftItems : self.rightItems;
}
-(UIView*)containerOfPosition:(LeomaBarPosition)position{
    return position == LeomaBarPositionLeft ? self.LeftItemHolder : self.RightItemHolder;
}

-(UIButton*)currTitle{
    return [self navigationTitle:LeomaNavigationTitleCenter];
}
-(UIButton*)prevTitle{
    return [self navigationTitle:LeomaNavigationTitleLeft];
}
-(UIButton*)hideTitle{
    return [self navigationTitle:LeomaNavigationTitleRight];
}
-(UIButton*)navigationTitle:(LeomaNavigationTitle)position{
    return self.NaviTitles[(self.anchor + 2 + position) % 3];
}

-(void)updateTitle:(LeomaNavigationTitle)position content:(NSString*)content{
    UIButton * title = [self navigationTitle:position];
    [title setTitle:content forState:UIControlStateNormal];
    [self relocateTitle:position];
}

-(void)relocateTitle:(LeomaNavigationTitle)position{
    UIButton * title = [self navigationTitle:position];
    if(!title) return;
    [title setUserInteractionEnabled:position == LeomaNavigationTitleLeft];
    title.alpha = 1;
    switch (position) {
        case LeomaNavigationTitleRight:
        case LeomaNavigationTitleFarLeft:
            title.alpha = 0;
        case LeomaNavigationTitleLeft:
            [title setTitleColor:UIColor.leomaForegroundS forState:UIControlStateNormal];
            title.titleLabel.font = [UIFont systemFontOfSize:14];
            break;
        case LeomaNavigationTitleCenter:
            [title setTitleColor:UIColor.leomaForeground forState:UIControlStateNormal];
            title.titleLabel.font = [UIFont systemFontOfSize:18];
            break;
    }
    [title sizeToFit];
    CGFloat w = title.width / 2;
    CGFloat W = self.TitleHolder.width / 2;
    CGFloat H = self.TitleHolder.height / 2;
    title.center = position == LeomaNavigationTitleFarLeft ? CGPointMake(-w, H) : CGPointMake(position * W + (1 - position) * w, H);
}

-(void)setAnchor:(int)anchor{
    int target = ((anchor - _anchor) % 3 + 3) % 3;
    if(target == 0) return;
    _anchor = anchor % 3;
}

-(BOOL)onNavigationBarItemClicked:(NSUInteger)index withStyle:(LeomaBarItemStyle)style withContent:(NSString *)content{
    UIViewController * activeRoot = LeomaNavigation.activeRoot;
    if([activeRoot respondsToSelector:@selector(onNavigationBarItemClicked:withStyle:withContent:)]){
        BOOL intercepted = [activeRoot onNavigationBarItemClicked:index withStyle:style withContent:content];
        if(intercepted) return YES;
    }
    switch (style) {
        case LeomaBarItemStyleNavi:
        case LeomaBarItemStyleClose:
            [activeRoot dismissViewController:LeomaNavigationOptionNone completion:nil];
            break;
        case LeomaBarItemStyleHome:
            [activeRoot dismissViewController:LeomaNavigation.rootViewController options:LeomaNavigationOptionNone completion:nil];
            break;
        case LeomaBarItemStyleMore:
            break;
    }
    return YES;
}

#pragma mark title action

- (IBAction)onTitleClicked:(UIButton *)sender {
    [self onNavigationBarItemClicked:0 withStyle:LeomaBarItemStyleNavi withContent:nil];
}
@end

@implementation LeomaBarItemS
@synthesize index = _index;

-(instancetype)init{
    self = [super init];
    if(self){
        self.barItem = [UIButton buttonWithType:UIButtonTypeCustom];
        self.barItem.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.barItem setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        self.barItem.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.barItem addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(void)updateItemConstraints:(CGSize)imgSize{
    if(IOS_WebKit){
        self.widthConstraint.active = NO;
        self.heightConstraint.active = NO;
    }else{
        [self.barItem removeConstraint:self.widthConstraint];
        [self.barItem removeConstraint:self.heightConstraint];
    }
    if(imgSize.width == 0 || imgSize.height == 0) return;
    CGFloat height = 16;
    CGFloat width = imgSize.height * height / imgSize.height;
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.barItem attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:width];
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.barItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:height];
    if(IOS_WebKit){
        self.widthConstraint.active = YES;
        self.heightConstraint.active = YES;
    }else{
        [self.barItem addConstraint:self.widthConstraint];
        [self.barItem addConstraint:self.heightConstraint];
    }
}
-(instancetype)initWithStyle:(LeomaBarItemStyle)style delegate:(id<LeomaNavigationSceneDelegate>)delegate index:(NSUInteger)index{
    self = [self init];
    [self setStyle:style];
    self.delegate = delegate;
    _index = index;
    return self;
}
-(instancetype)initWithTitle:(NSString *)title delegate:(id<LeomaNavigationSceneDelegate>)delegate index:(NSUInteger)index{
    self = [self init];
    [self setTitle:title];
    self.delegate = delegate;
    _index = index;
    return self;
}

-(void)setTitle:(NSString *)title{
    _title = [title copy];
    _style = LeomaBarItemStyleNavi;
    [self.barItem setTitle:_title forState:UIControlStateNormal];
    [self.barItem setImage:nil forState:UIControlStateNormal];
    [self updateItemConstraints:CGSizeZero];
}

-(void)setStyle:(LeomaBarItemStyle)style{
    _style = style;
    _title = nil;
    [self.barItem setTitle:nil forState:UIControlStateNormal];
    [self.barItem setImage:[self imageOfStyle:_style] forState:UIControlStateNormal];
}

-(BOOL)isStyleTitle{
    return self.title != nil;
}

-(void)itemClicked:(id)sender{
    [self.delegate onNavigationBarItemClicked:self.index withStyle:self.style withContent:self.title];
}

#pragma mark function
-(UIImage*)imageOfStyle:(LeomaBarItemStyle)style{
    UIImage * image;
    switch (style) {
        case LeomaBarItemStyleNavi:
            image = [UIImage customImageNamed:@"back"];
            break;
        case LeomaBarItemStyleHome:
            image = [UIImage customImageNamed:@"home"];
            break;
        case LeomaBarItemStyleMore:
            image = [UIImage customImageNamed:@"more"];
            break;
        case LeomaBarItemStyleClose:
            image = [UIImage customImageNamed:@"close"];
            break;
        default:
            break;
    }
    [self updateItemConstraints:image.size];
    return image;
}

@end
