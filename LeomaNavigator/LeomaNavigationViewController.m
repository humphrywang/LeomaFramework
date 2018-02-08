//
//  LeomaNavigationViewController.m
//  Pods
//
//  Created by CorpDev on 21/4/17.
//
//

#import "LeomaNavigationViewController.h"
#import "LeomaNavigationBarS.h"
#import "LeomaMaskView.h"
#import "LeomaEffectiveTransform.h"

#define FollowSlideThreshold 100
#define FollowSlideShouldFinishThreshold 50


typedef NS_ENUM(NSUInteger, LeomaNaviStatus){
    LeomaNaviStatusWaiting,//等待新的导航命令，可导航状态
    LeomaNaviStatusPreparing,//数据准备或等待noitify中
    LeomaNaviStatusPresenting//正在滑页（动画执行中）
};


@interface LeomaNavigationViewController ()
//Outlets
@property (weak, nonatomic) IBOutlet UIView                             *   naviContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UIView                *   naviMask;
@property (strong, nonatomic) LeomaNavigationBarS                       *   navigateBar;
//NaviProps

@property (strong, nonatomic)   NSMutableArray<UIViewController*>       *   controllerStack;
@property (strong, nonatomic)   UIViewController                        *   modal;

@property (strong, nonatomic)   LeomaNavigationConfig                   *   navigateConfig;
@property (strong, nonatomic)   NSMutableArray<void(^)(BOOL)>           *   navigateTasks;

@property (assign, nonatomic)   LeomaNaviStatus                             status;

@property (strong, nonatomic)   NSMutableArray<UIView*>                 *   confirmMasks;
@property (strong, nonatomic)   NSMutableArray<UIView*>                 *   overlayMasks;
@property (strong, nonatomic)   NSMutableArray<UIView*>                 *   viewMasks;

@end

@implementation LeomaNavigationViewController

- (instancetype)init
{
    self = [super initWithNibName:@"LeomaNavigationViewController" bundle:nil];
    if(self){
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [LeomaSystem screenBounds];
    [self barInit];
    [self.view layoutIfNeeded];
    // Do any additional setup after loading the view.
}

-(void)commonInit{
    self.controllerStack = [NSMutableArray array];
    self.navigateTasks = [NSMutableArray array];
    self.modal = nil;
}

-(void)barInit{
    self.navigateBar = [LeomaNavigationBarS viewFromNib];
}

-(void)setViewShadow:(UIView*)view{
    view.layer.shadowColor = UIColorFromRGB(0x666666).CGColor;
    view.layer.shadowOpacity = 0.4;//阴影透明度，默认0
    view.layer.shadowRadius = 4;//阴影半径，默认3
    view.layer.shadowOffset = CGSizeMake(-3,-3);
}
#pragma props
-(UIViewController *)standByViewController{
    return self.navigateConfig.presentingVC;
}
-(UIViewController*)currentViewController{
    return self.modal ?: self.controllerStack.lastObject;
}
-(UIViewController*)rootViewController{
    return self.controllerStack.firstObject;
}
-(UIViewController*)prioViewControllerOf:(UIViewController*)vc{
    if(vc == self.modal) return self.controllerStack.lastObject;
    if(vc == self.controllerStack.firstObject) return nil;
    NSUInteger index = [self.controllerStack indexOfObject:vc];
    return index == NSNotFound ? nil : self.controllerStack[index - 1];
}
-(UIViewController *)postViewControllerOf:(UIViewController *)vc{
    if(vc == self.currentViewController) return nil;
    if(vc == self.controllerStack.lastObject) return self.modal;
    NSUInteger index = [self.controllerStack indexOfObject:vc];
    return index == NSNotFound ? nil : self.controllerStack[index + 1];
}
-(void)setRootViewController:(UIViewController*)vc withOptions:(LeomaNavigationOption)flag{
    vc.action = LeomaNavigationActionTab;
    vc.policy = LeomaNavigationPolicyShufflePrev;
    [self presentViewController:vc options:flag completion:^(BOOL finish) {
        if(finish) [self makeCurrentViewControllerRoot];
    }];
}

-(void)makeCurrentViewControllerRoot{
    if(self.controllerStack.count == 0) return;
    [self.controllerStack removeObjectsInRange:NSMakeRange(0, self.controllerStack.count - 1)];
}
#pragma Navigation
//任务队列
-(void)dispatchNavigationTask:(void(^)(BOOL))task policy:(LeomaNavigationPolicy)policy{
    if(!task) return [self fireTask];
    switch (policy) {
        case LeomaNavigationPolicyWaitCancel:
            if(self.status > LeomaNaviStatusWaiting || self.navigateTasks.count > 0) {
                return task(NO);
            }
            break;
        case LeomaNavigationPolicyShufflePrev:
            for(void(^task)(BOOL) in self.navigateTasks){
                task(NO);
            }
            [self.navigateTasks removeAllObjects];
            if(self.status != LeomaNaviStatusPresenting) [self cancelInstruction];
            break;
        case LeomaNavigationPolicyWaitPrev:
            break;
    }
    [self.navigateTasks addObject:task];
    [self fireTask];
}
-(void)fireTask{
    if(self.navigateTasks.count > 0 && self.status == LeomaNaviStatusWaiting){
        void(^task)(BOOL) = self.navigateTasks[0];
        [self.navigateTasks removeObjectAtIndex:0];
        task(YES);
    }
}
#pragma mark Navigation APIs
//展示部分
-(void)presentViewController:(UIViewController *)viewControllerToPresent options:(LeomaNavigationOption)flag completion:(void (^)(BOOL))completion{
    [self dispatchNavigationTask:^(BOOL accept){
        [self prepareInstruction:[self gengerateConfig:viewControllerToPresent
                                               options:flag
                                               present:YES
                                          shouldAccept:accept
                                            completion:completion]];
    } policy:viewControllerToPresent.policy];
}
//隐藏部分
-(void)dismissViewController:(UIViewController *)viewControllerDismissTo options:(LeomaNavigationOption)flag completion:(void (^)(BOOL))completion{
    [self dispatchNavigationTask:^(BOOL accept){
        [self prepareInstruction:[self gengerateConfig:viewControllerDismissTo
                                               options:flag
                                               present:NO
                                          shouldAccept:accept
                                            completion:completion]];
    } policy:viewControllerDismissTo.policy];
}
-(void)dismissViewController:(LeomaNavigationOption)flag completion:(void (^)(BOOL))completion{
    [self dispatchNavigationTask:^(BOOL accept){
        [self prepareInstruction:[self gengerateConfig:self.currentViewController.prioViewController
                                               options:flag
                                               present:NO
                                          shouldAccept:accept
                                            completion:completion]];
    } policy:LeomaNavigationPolicyWaitPrev];
}
//分发部分
-(void)prepareInstruction:(LeomaNavigationConfig*)config
{
    if(![self shouldRejectNavigation:config]){
        if(self.navigateConfig) [self cancelInstruction];
        self.status = LeomaNaviStatusPreparing;
        self.navigateConfig = config;
        
        [self.navigateConfig.presentingVC viewMaybeAppear];
        [self.navigateConfig.dismissingVC viewMaybeDisappear];
        
        [self.naviContainer addSubview:self.navigateConfig.presentingVC.view];
        self.navigateConfig.presentingVC.view.origin = CGPointMake(self.naviContainer.width, 0);
        [self.navigateConfig.presentingVC.view.layer removeAllAnimations];
        //  -----·····
        //  |   |·   ·
        //  | D |· P ·
        //  |   |·   ·
        //  -----·····
        
        if(self.navigateConfig.now) [self performInstruction];
        return;
    }else if(config.completion){
        config.completion(NO);
    }
    
}

-(void)finishPresentingInstruction{
    switch (self.navigateConfig.action) {
        case LeomaNavigationActionTab:
            if(self.controllerStack.count > 0){
                [self.controllerStack replaceObjectAtIndex:self.controllerStack.count-1 withObject:self.navigateConfig.presentingVC];
                self.navigateConfig.presentingVC.action = LeomaNavigationActionPush;
                break;
            }
        case LeomaNavigationActionPush:
            [self.controllerStack addObject:self.navigateConfig.presentingVC];
            break;
        case LeomaNavigationActionModal:
            self.modal = self.navigateConfig.presentingVC;
            break;
    }
    [self finishInstruction];
}
-(void)finishDismissingInstruction{
    NSUInteger index = [self.controllerStack indexOfObject:self.navigateConfig.presentingVC] + 1;
    [self.controllerStack removeObjectsInRange:NSMakeRange(index, self.controllerStack.count - index)];
    if(self.navigateConfig.action == LeomaNavigationActionModal) self.modal = nil;
    [self finishInstruction];
}
//公共处理部分

-(void)performInstruction{
    if(!self.navigateConfig || !self.navigateConfig.presentingVC || self.status != LeomaNaviStatusPreparing) return;
    self.status = LeomaNaviStatusPresenting;
    if(self.navigateConfig.present) [self setViewShadow:self.navigateConfig.presentingVC.view];
    //导航动画。
    [LeomaEffectiveNavigation prepareNavigation:self.navigateConfig];
    [self.navigateBar prepareNavigation:self.navigateConfig];
    [self performEffectiveNavigation:^{
        [LeomaEffectiveNavigation performNavigation:self.navigateConfig];
        [self.navigateBar performNavigation:self.navigateConfig];
    } completion:^(BOOL finished){
        if(self.navigateConfig.present) [self finishPresentingInstruction];
        else [self finishDismissingInstruction];
    }];
}

-(void)performEffectiveNavigation:(void(^ _Nonnull)())navigation completion:(void(^ _Nonnull)(BOOL))completion{
    if(self.navigateConfig.animated) EffectiveUI(navigation, completion, 0.5, 0);
    else{
        navigation();
        completion(YES);
    }
}

-(void)finishInstruction{
    [self.navigateConfig.dismissingVC.view removeFromSuperview];
    [self.navigateBar finishNavigation:self.navigateConfig];
    if(self.navigateConfig.completion) self.navigateConfig.completion(YES);
    
    [self.navigateConfig.presentingVC performSelectorOnMainThread:@selector(viewHasAppear:) withObject:@(YES) waitUntilDone:NO];
    [self.navigateConfig.dismissingVC performSelectorOnMainThread:@selector(viewHasDisappear:) withObject:@(YES) waitUntilDone:NO];
    
    if(IOS_7_OR_LATER) [self setNeedsStatusBarAppearanceUpdate];
#pragma mark RecordLog
    [LeomaLog LogTracing:nil withTitle:[NSString stringWithFormat:@"视图更新 %@", NSStringFromClass(self.navigateConfig.presentingVC.class)]];
    
    [self releaseConfig];
    self.status = LeomaNaviStatusWaiting;
    [self fireTask];
}
-(void)cancelInstruction{
    if(self.status > LeomaNaviStatusPreparing){
        if(self.navigateConfig.present) [self dismissViewController:LeomaNavigationOptionNone completion:nil];
        return;
    }
    [self.navigateConfig.presentingVC.view removeFromSuperview];
    if(self.navigateConfig.completion) self.navigateConfig.completion(NO);
    
    [self releaseConfig];
    self.status = LeomaNaviStatusWaiting;
    [self fireTask];
}

-(void)releaseConfig{
    self.navigateConfig.presentingVC = nil;
    self.navigateConfig.dismissingVC = nil;
    self.navigateConfig.completion = nil;
    self.navigateConfig = nil;
}
-(void)updateLeftGuide:(NSString *)guide{
    if(self.status == LeomaNaviStatusWaiting){
        [self.navigateBar updateLeftGuide:guide];
    }
}
#pragma mark 蒙版操作
-(void)presentMask:(UIView *)contentView silent:(BOOL)silent{
    if(!contentView) return;
    leoma_dispatch_main(^{
        [self presentMask:contentView];
        if(!silent)[contentView transInWithOption:contentView.maskEffectP];
    });
}
-(void)presentMask:(UIView *)contentView{
    if(!contentView) return;
    LeomaMaskView * maskView = [[LeomaMaskView alloc] initWithFrame:self.view.frame withContentView:contentView];
    
    NSEnumerator<LeomaMaskView *> * enumerator = self.naviMask.subviews.reverseObjectEnumerator;
    LeomaMaskView * subView; BOOL inserted = NO;
    while ((subView = enumerator.nextObject)){
        if(![subView isKindOfClass:[LeomaMaskView class]]) continue;
        if(subView.maskLayer <= maskView.maskLayer){
            [self.naviMask insertSubview:maskView aboveSubview:subView];
            inserted = YES;
        }
    }
    if(!inserted){
        [self.naviMask insertSubview:maskView atIndex:0];
    }
    [self.naviMask setHidden:NO];
}

-(void)dismissMask:(UIView *)contentView silent:(BOOL)silent{
    if(!contentView) return;
    leoma_dispatch_main(^{
        if(silent){
            [self dismissMask:contentView];
        }else{
            [contentView transOutWithOption:contentView.maskEffectD delay:0 completion:^(BOOL finish) {
                [self dismissMask:contentView];
            }];
        }
    });
}
-(void)dismissMask:(UIView *)contentView{
    if(!contentView) return;
    LeomaMaskView * maskView = contentView.superview;
    [maskView removeFromSuperview];
    [contentView removeFromSuperview];
    [self.naviMask setHidden:self.naviMask.subviews.count == 0];
}

- (IBAction)testBtn:(id)sender {
}
#pragma mark 工具方法
-(LeomaNavigationConfig *)gengerateConfig:(UIViewController*)viewController
                                  options:(LeomaNavigationOption)flag
                                  present:(BOOL)present
                             shouldAccept:(BOOL)accept
                               completion:(void(^)(BOOL))completion
{
    completion = completion ?: ^(BOOL finish){};
    if(!accept){
        completion(NO);
        return nil;
    }
    LeomaNavigationConfig * config = [LeomaNavigationConfig configFromOptions:flag];
    config.present = present;
    config.presentingVC = viewController;
    config.dismissingVC = self.currentViewController;
    config.action = config.present ? config.presentingVC.action : config.dismissingVC.action;
    config.completion = completion;
    return config;
}
-(BOOL)shouldRejectNavigation:(LeomaNavigationConfig*)config{
    NSUInteger index = [self.controllerStack indexOfObject:config.presentingVC];
    return      self.status == LeomaNaviStatusPresenting//已经进入动画状态（Presenting）不可取消与接受新导航
    ||  !config//配置为空不导航
    ||  !config.presentingVC//viewController为nil，参数错误不接受新导航
    ||  config.presentingVC == config.dismissingVC//toview与fromview相同时，不进行导航
    ||  (config.present && self.modal)//已处于modal后状态，不接受新PushIn导航
    ||  (!config.present && index == NSNotFound)//dismiss时，presentview不在栈内
    ;
    
}
#pragma mark Navigation Bar Bridge
-(void)navigationBarAreaModified:(LeomaNavigationBarArea)area WithBridge:(LeomaNavigationBarBridge *)bridge{
    if(self.status != LeomaNaviStatusWaiting || self.currentViewController.bridge != bridge) return;
    [self.navigateBar updateNavigationBarArea:area WithBridge:bridge];
}
-(BOOL)onNavigationBarItemClicked:(NSUInteger)index withStyle:(LeomaBarItemStyle)style withContent:(NSString *)content{
    return [self.currentViewController onNavigationBarItemClicked:index withStyle:style withContent:content];
}
@end


