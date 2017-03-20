//
//  ZAShakingAnimationView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/29.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAShakingAnimationView.h"

@interface ZAShakingAnimationView()
@property (nonatomic,assign) BOOL isAnimating;
@property (nonatomic,strong) UIView * coverView;

@end

@implementation ZAShakingAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [self createSubViews];
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(UIView *)coverView
{
    if(!_coverView)
    {
        CGRect rect = self.bounds;
        UIView * aView = [[UIView alloc] initWithFrame:rect];
        self.coverView = aView;
    }
    return _coverView;
}

-(void)createSubViews
{
    [self addSubview:self.coverView];
    self.coverView.center = CGPointMake(self.bounds.size.width/2.0,self.bounds.size.height/2.0);
}
-(void)startAnimation
{
    CAAnimation *animation=[self shakeAnimation:self.coverView.layer.frame];
    animation = [self circleAnimationForKeyFrame];
    [self.layer addAnimation:animation forKey:kCATransition];
    
    self.isAnimating = YES;
}

-(CAAnimation *)circleAnimationForKeyFrame
{
    CAKeyframeAnimation *keyAnima=[CAKeyframeAnimation animation];
    keyAnima.keyPath=@"transform.scale";
    //设置动画时间
    keyAnima.duration= 1.0;
    //设置图标抖动弧度
    //把度数转换为弧度  度数/180*M_PI
    CGFloat scaleTime = 0.3;
    CGFloat quickTime = (1.0-scaleTime*2)/4.0;

    keyAnima.values=@[@(1.0),@(1.3),@(0.9),@(1.0),@(0.8),@(0.9),@(0.6)];
    keyAnima.keyTimes=@[@(0),@(scaleTime),@(scaleTime*2),@(scaleTime*2 + quickTime),@(scaleTime*2 + quickTime * 2),@(scaleTime*2 + quickTime*3),@(scaleTime*2 + quickTime*4)];
    
    //设置动画的重复次数(设置为最大值)
    keyAnima.repeatCount=MAXFLOAT;
    keyAnima.fillMode=kCAFillModeForwards;
    keyAnima.removedOnCompletion=NO;
    
    return keyAnima;
}

-(CAAnimation *)circleAnimationForShaking
{
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimation.duration=8;
    theAnimation.removedOnCompletion = YES;
    theAnimation.fromValue = [NSNumber numberWithFloat:1];
    theAnimation.toValue = [NSNumber numberWithFloat:0.5];
    
    return theAnimation;
}


static int numberOfShakes = 10000;//震动次数
static float durationOfShake = 1000.5f;//震动时间
static float vigourOfShake = 0.102f;//震动幅度

- (CAKeyframeAnimation *)shakeAnimation:(CGRect)frame
{
    return nil;
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, CGRectGetMidX(frame), CGRectGetMidY(frame) );
    for (int index = 0; index < numberOfShakes; ++index)
    {
        CGPathAddLineToPoint(shakePath, NULL, CGRectGetMidX(frame) - frame.size.width * vigourOfShake,CGRectGetMidY(frame));
        CGPathAddLineToPoint(shakePath, NULL,  CGRectGetMidX(frame) + frame.size.width * vigourOfShake,CGRectGetMidY(frame));
    }
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    CFRelease(shakePath);
    
    return shakeAnimation;
}

-(void)stopAnimation
{
    self.isAnimating = NO;
    [self.layer removeAnimationForKey:@"scaleAnimation"];
    
}

- (void)resetAnimations
{
    // If the app goes to the background, returning it to the foreground causes the animation to stop (even though it's not explicitly stopped by our code). Resetting the animation seems to kick it back into gear.
    if (self.isAnimating)
    {
        [self stopAnimation];
        [self startAnimation];
    }
}


@end
