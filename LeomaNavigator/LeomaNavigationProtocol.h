//
//  LeomaNavigationProtocol.h
//  Pods
//
//  Created by CorpDev on 3/5/17.
//
//

#ifndef LeomaNavigationProtocol_h
#define LeomaNavigationProtocol_h

typedef NS_ENUM(NSInteger, LeomaNavigationAction){
    LeomaNavigationActionPush,//压栈动作，a->b->c->d...
    LeomaNavigationActionModal,//分支动作，a->b|
    LeomaNavigationActionTab,//替换动作，b(a)
};
typedef NS_ENUM(NSInteger, LeomaNavigationPolicy){
    LeomaNavigationPolicyWaitPrev,//压入等待栈，依次处理。
    LeomaNavigationPolicyWaitCancel,//已有进行中task或队列中有其他项，则不处理
    LeomaNavigationPolicyShufflePrev//取消进行中task，清空队列直接执行
};
typedef NS_ENUM(NSInteger, LeomaNavigationBarArea){
    LeomaNavigationBarAreaLeft,
    LeomaNavigationBarAreaCenter,
    LeomaNavigationBarAreaRight
};
typedef NS_ENUM(NSInteger, LeomaNavigationBarStyle){
    LeomaNavigationBarHidden,//bar不显示
    LeomaNavigationBarOverlay,//bar在z轴上是上下关系
    LeomaNavigationBarLinear,//bar为在y轴上是上下关系
    LeomaNavigationBarTransparent//bar背景为透明
};
typedef NS_ENUM(NSInteger, LeomaBarItemStyle){
    LeomaBarItemStyleNavi,//箭头
    LeomaBarItemStyleClose,//关闭
    LeomaBarItemStyleHome,//主页
    LeomaBarItemStyleMore,//更多
    LeomaBarItemStyleEnd = LeomaBarItemStyleMore
};

typedef NS_OPTIONS(NSInteger, LeomaNavigationOption){
    LeomaNavigationOptionNone           =   0x0,
    
    LeomaNavigationOptionNow            =   LeomaNavigationOptionNone,//使用通知跳转的开关
    LeomaNavigationOptionNotify         =   0x1,
    
    LeomaNavigationOptionNormal         =   LeomaNavigationOptionNone,//反向执行动画的开关
    LeomaNavigationOptionReverse        =   0x1 << 1,

};

typedef NS_ENUM(NSInteger, LeomaMaskLayer){
    LeomaMaskLayerView      = 0, // 底层，view型
    LeomaMaskLayerOverlay   = 1, // 次顶层，mask型
    LeomaMaskLayerConfirm   = 2, // 最顶层，confrim型
};

typedef NS_ENUM(NSInteger, LeomaMaskStyle){
    LeomaMaskStyleBlank,    //透明色
    LeomaMaskStyleGray,     //灰色透明
    LeomaMaskStyleBlack     //黑色透明
};
typedef NS_ENUM(NSInteger, LeomaMaskAction){
    LeomaMaskActionNone,    //不处理事件
    LeomaMaskActionClose,   //点击关闭蒙版
    LeomaMaskActionBlock    //拦截点击事件
};

typedef NS_OPTIONS(NSUInteger, LeomaTransformOption){
    LeomaTransformOptionNone                    = 0x0,
    
    LeomaTransformOptionDirectionBottom         = 0x0,
    LeomaTransformOptionDirectionStay           = 0x1,
    LeomaTransformOptionDirectionTop            = 0x2,
    LeomaTransformOptionDirectionLeading        = 0x3,
    LeomaTransformOptionDirectionTrailing       = 0x4,
    
    LeomaTransformOptionDurationDefault         = 0x0 << 4,  //0.2s
    LeomaTransformOptionDurationExtraShort      = 0x0 << 4,  //0.2s
    LeomaTransformOptionDurationLittleShort     = 0x1 << 4,  //0.3s
    LeomaTransformOptionDurationShort           = 0x2 << 4,  //0.5s
    LeomaTransformOptionDurationNormal          = 0x3 << 4,  //1s
    LeomaTransformOptionDurationLong            = 0x4 << 4,  //1.5s
    LeomaTransformOptionDurationExtraLong       = 0x5 << 4,  //2s
    
    //动画在superview中的位置，起（讫）位置高（低）于superview对应的边界
    LeomaTransformOptionOutBox                  = 0x0 << 8,
    LeomaTransformOptionInBox                   = 0x1 << 8,
    //view是否要淡入（淡出）
    LeomaTransformOptionFade                    = 0x0 << 12,
    LeomaTransformOptionBloom                   = 0x1 << 12,
    //动画是否有弹性
    LeomaTransformOptionSteel                   = 0x0 << 16,
    LeomaTransformOptionSpring                  = 0x1 << 16,
};

@protocol LeomaNavigationSceneDelegate

/**
 点击bar item的回调事件

 @param index 0，代表左侧item，从1开始为右侧按钮从左至右递增
 @param style 点击的item的LeomaBarItemStyle
 @param content 点击的item的文字content，无则为nil
 @return YES表示此事件被消费，不需要底层再去处理，NO则代表事件按照缺省逻辑处理。
 */
-(BOOL)onNavigationBarItemClicked:(NSUInteger)index withStyle:(LeomaBarItemStyle)style withContent:(NSString*)content;

@end

#endif /* LeomaNavigationProtocol_h */
