//
//  LeomaMaskView.m
//  LeomaFramework
//
//  Created by CorpDev on 2017/10/15.
//

#import "LeomaMaskView.h"
#import "UIKit+LeomaNavigation.h"

@implementation LeomaMaskView{
    LeomaMaskAction _maskAction;
    LeomaMaskLayer _maskLayer;
}

-(instancetype)initWithFrame:(CGRect)frame withContentView:(UIView *)contentView{
    self = [self initWithFrame:frame];
    if(self){
        [self addSubview:contentView];
        [self maskAcceptStyle:contentView.maskStyle Action:contentView.maskAction Layer:contentView.maskLayer];
    }
    return self;
}

-(LeomaMaskLayer)maskLayer{
    return _maskLayer;
}

-(void)maskAcceptStyle:(LeomaMaskStyle)style Action:(LeomaMaskAction)action Layer:(LeomaMaskLayer)layer{
    _maskAction = action;
    _maskLayer = layer;
    switch (style) {
        case LeomaMaskStyleGray:
            self.backgroundColor = UIColorFromRGBA(0x999999, 0.6);
            break;
        case LeomaMaskStyleBlack:
            self.backgroundColor = UIColorFromRGBA(0x000000, 0.6);
            break;
        case LeomaMaskStyleBlank:
            self.backgroundColor = [UIColor clearColor];
            break;
    }
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView * view = [super hitTest:point withEvent:event];
    if(_maskAction == LeomaMaskActionNone && view == self) return nil;
    return view;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(_maskAction != LeomaMaskActionClose) return;
    CGPoint location = [touches.anyObject locationInView:self.subviews.lastObject];
    if(![self.subviews.lastObject pointInside:location withEvent:nil]){
        [self.subviews.lastObject maskOut:NO];
    }
}
@end
