//
//  CircleAnimationView.m
//  SimpleWebProject
//
//  Created by Apple on 14-8-13.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

#import "CircleAnimationView.h"
#define CircleAnimation_Time_Interval  2//两次动画调用间隔
#define CircleAnimation_Gray_Scale_Time_Interval  1//灰圈的动画时间
#define CircleAnimation_GrayScale_Delay_Time_Interval  0.3 //两个灰圈，调用时间间隔
#define Circle_White_Spot_Width     19/2.0
#define Circle_Gray_Spot_MAX_Width  58/2.0

@interface CircleAnimationView()
{
    //实现动画需要的素材
    
    BOOL needStopAnimation;
    
    UIView * bgGrayView1;
    UIView * bgGrayView2;
    UIView * centerCircle;
    
    
}
@property (nonatomic,strong) UIView * bgView;

@property (nonatomic,strong) UIImage * img1;
@property (nonatomic,strong) UIImage * img2;
@property (nonatomic,strong) UIImage * img3;

@property (nonatomic,strong) CAAnimationGroup * group1;
@property (nonatomic,strong) CAAnimationGroup * group2;
@property (nonatomic,strong) CAAnimationGroup * group3;

@end

@implementation CircleAnimationView

-(UIView *)bgView
{
    if(!_bgView)
    {
        UIView * aView = [[UIView alloc] initWithFrame:self.bounds];
        [self createTotalSubViews];
        [self initSubViews];
        [self addSubview:aView];
        aView.backgroundColor = [UIColor clearColor];
        _bgView = aView;
    }
    return _bgView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.startLength = Circle_White_Spot_Width;
        self.maxLength = Circle_Gray_Spot_MAX_Width;
        
    }
    return self;
}
-(void)createTotalSubViews
{
    needStopAnimation = NO;
    CGRect rect = self.bounds;
    
    float totalWidth = rect.size.width;
    float totalHeight = rect.size.height;
    
    centerCircle = [[UIView alloc] initWithFrame:CGRectMake((totalWidth-self.startLength)/2.0, (totalHeight-self.startLength)/2.0, self.startLength, self.startLength)];
    //        [self addSubview:centerCircle];
    centerCircle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    centerCircle.layer.cornerRadius = centerCircle.bounds.size.width/2;
    centerCircle.layer.masksToBounds = YES;
    //        centerCircle.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    //        [(UIImageView *)centerCircle setImage:[UIImage imageNamed:@"指示点.png"]];
    UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"标签指示点（上面）"]];
    [centerCircle addSubview:image];
    
    image.center = CGPointMake(self.startLength/2.0, self.startLength/2.0);
    
    
    bgGrayView1 = [[UIView alloc] initWithFrame:CGRectMake((totalWidth-self.maxLength)/2.0,(totalHeight - self.maxLength)/2.0 , self.maxLength, self.maxLength)];
    bgGrayView1.layer.backgroundColor = [self.shadowColor CGColor];
    bgGrayView1.layer.cornerRadius = bgGrayView1.bounds.size.width/2;
    bgGrayView1.layer.masksToBounds = YES;
    //        bgGrayView1.backgroundColor = [UIColor clearColor];
    
    bgGrayView2 = [[UIView alloc] initWithFrame:bgGrayView1.frame];
    bgGrayView2.layer.backgroundColor = [self.shadowColor CGColor];
    bgGrayView2.layer.cornerRadius = bgGrayView1.bounds.size.width/2;
    bgGrayView2.layer.masksToBounds = YES;
    //        bgGrayView2.backgroundColor = [UIColor clearColor];
    
    [self addSubview:bgGrayView1];
    [self addSubview:bgGrayView2];
    bgGrayView2.alpha = 0.0;
    bgGrayView1.alpha = 0.0;
    
    [self addSubview:centerCircle];
}


-(void)initSubViews
{
    if (!self.img1)
    {
        self.img1 = [self haloImageWithRadius:20];
        self.img2 = [self haloImageWithRadius:35];
        self.img3 = [self haloImageWithRadius:50];
    }
    
    CGFloat centerInterval = 0.2;
    CGFloat maxCenterScale = 1.3;
    CGFloat repeatNum = MAXFLOAT;
    
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    // 动画选项设定
    animation1.duration = centerInterval; // 动画持续时间
    animation1.repeatCount = 1; // 重复次数
    animation1.autoreverses = NO; // 动画结束时执行逆动画
    // 缩放倍数
    animation1.fromValue = [NSNumber numberWithFloat:1]; // 开始时的倍率
    animation1.toValue = [NSNumber numberWithFloat:0.8]; // 结束时的倍率
    
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    animation2.duration = centerInterval; // 动画持续时间
    animation2.repeatCount = 1; // 重复次数
    animation2.autoreverses = NO; // 动画结束时执行逆动画
    // 缩放倍数
    animation2.fromValue = [NSNumber numberWithFloat:0.8]; // 开始时的倍率
    animation2.toValue = [NSNumber numberWithFloat:maxCenterScale]; // 结束时的倍率
    animation2.beginTime = centerInterval;
    
    CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    animation3.duration = centerInterval; // 动画持续时间
    animation3.repeatCount = 1; // 重复次数
    animation3.autoreverses = NO; // 动画结束时执行逆动画
    // 缩放倍数
    animation3.fromValue = [NSNumber numberWithFloat:maxCenterScale]; // 开始时的倍率
    animation3.toValue = [NSNumber numberWithFloat:1.0]; // 结束时的倍率
    animation3.beginTime = centerInterval*2;
    
    
//    CABasicAnimation *animation4 = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
//    animation4.duration = CircleAnimation_Time_Interval - centerInterval*3; // 动画持续时间
//    animation4.repeatCount = 1; // 重复次数
//    animation4.autoreverses = NO; // 动画结束时执行逆动画
//    // 缩放倍数
//    animation4.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
//    animation4.toValue = [NSNumber numberWithFloat:1.0]; // 结束时的倍率
//    animation4.beginTime = centerInterval*3;
    
    CAAnimationGroup * centerGroup = [CAAnimationGroup animation];
    centerGroup.animations = [NSArray arrayWithObjects:animation1,animation2,animation3,nil];
    centerGroup.duration = CircleAnimation_Time_Interval;
    centerGroup.repeatCount = repeatNum;
//    [centerCircle.layer addAnimation:centerGroup forKey:nil];
    self.group1 = centerGroup;
    
    
    
    //阴影动画
    CAMediaTimingFunction *linear = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    CAMediaTimingFunction *easeIn = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = CircleAnimation_Time_Interval;
    animationGroup.repeatCount = repeatNum;
    animationGroup.timingFunction = linear;
    animationGroup.delegate = self;
    animationGroup.beginTime = centerInterval*3+CACurrentMediaTime();
    
    CAKeyframeAnimation *imageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    
    
    imageAnimation.values = @[
                              (id)[self.img1 CGImage],
                              (id)[self.img2 CGImage],
                              (id)[self.img3 CGImage]
                              ];
    imageAnimation.duration = CircleAnimation_Gray_Scale_Time_Interval;
    imageAnimation.calculationMode = kCAAnimationDiscrete;
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    pulseAnimation.fromValue = @(self.startLength/self.maxLength);
    pulseAnimation.toValue = @1.0;
    pulseAnimation.duration = CircleAnimation_Gray_Scale_Time_Interval;
    pulseAnimation.timingFunction = easeOut;
    
    CABasicAnimation *fadeOutAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnim.fromValue = @1.0;
    fadeOutAnim.toValue = @0.0;
    fadeOutAnim.duration = CircleAnimation_Gray_Scale_Time_Interval;
    fadeOutAnim.timingFunction = easeIn;
    fadeOutAnim.removedOnCompletion = NO;
    fadeOutAnim.autoreverses = NO;
    fadeOutAnim.fillMode = kCAFillModeForwards;
    
    animationGroup.animations = @[imageAnimation,pulseAnimation, fadeOutAnim];
//    [bgGrayView1.layer addAnimation:animationGroup forKey:@"pulse"];
    self.group2 = animationGroup;
    
//    [self performSelector:@selector(hideAnimationViewAfterAnimationEnd:) withObject:bgGrayView1 afterDelay:CircleAnimation_Gray_Scale_Time_Interval];
    
    
    
    
    CAAnimationGroup *animationGroup2 = [CAAnimationGroup animation];
    animationGroup2.duration = CircleAnimation_Time_Interval;
    animationGroup2.repeatCount = repeatNum;
    animationGroup2.timingFunction = linear;
    animationGroup2.beginTime = centerInterval*3+CACurrentMediaTime()+CircleAnimation_GrayScale_Delay_Time_Interval;
    animationGroup2.animations = @[imageAnimation,pulseAnimation, fadeOutAnim];
//    [bgGrayView2.layer addAnimation:animationGroup2 forKey:@"pulse-second"];
    self.group3 = animationGroup2;

}
- (UIImage*)haloImageWithRadius:(CGFloat)radius {
    CGFloat glowRadius = radius/6;
    CGFloat ringThickness = radius/24;
    CGPoint center = CGPointMake(glowRadius+radius, glowRadius+radius);
    CGRect imageBounds = CGRectMake(0, 0, center.x*2, center.y*2);
    CGRect ringFrame = CGRectMake(glowRadius, glowRadius, radius*2, radius*2);
    
    UIGraphicsBeginImageContextWithOptions(imageBounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor* ringColor = self.shadowColor;
    [ringColor setFill];
    
    UIBezierPath *ringPath = [UIBezierPath bezierPathWithOvalInRect:ringFrame];
    [ringPath appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectInset(ringFrame, ringThickness, ringThickness)]];
    ringPath.usesEvenOddFillRule = YES;
    
    for(float i=1.3; i>0.3; i-=0.18) {
        CGFloat blurRadius = MIN(1, i)*glowRadius;
        CGContextSetShadowWithColor(context, CGSizeZero, blurRadius, ringColor.CGColor);
        [ringPath fill];
    }
    
    UIImage *ringImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ringImage;
}

-(void)startCircleAnimation
{
    needStopAnimation = NO;
    //    NSTimer * timer = [NSTimer timerWithTimeInterval:CircleAnimationTimeInterval target:self selector:@selector(circleAnimationDidShow:) userInfo:nil repeats:NO];
    //    self.animationTimer = timer;
    //    [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:CircleAnimationTimeInterval]];
    [self addSubview:self.bgView];
    [self circleAnimationDidShow];
    
}




-(void)circleAnimationDidShow
{
    if (needStopAnimation)
    {
        return;
    }
    
//    //圆点动画
    [centerCircle.layer addAnimation:self.group1 forKey:@"center"];
    [bgGrayView1.layer addAnimation:self.group2 forKey:@"pulse"];
    [bgGrayView2.layer addAnimation:self.group3 forKey:@"pulse_second"];
    
    
//
//    animation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    // 动画选项设定
//    animation1.beginTime = CACurrentMediaTime() +sepCountInteval;
//    animation1.duration = CircleAnimation_Gray_Scale_Time_Interval; // 动画持续时间
//    animation1.repeatCount = 1; // 重复次数
//    animation1.autoreverses = NO; // 动画结束时执行逆动画
//    // 缩放倍数
//    animation1.fromValue = [NSNumber numberWithFloat:1]; // 开始时的倍率
//    animation1.toValue = [NSNumber numberWithFloat:maxScale]; // 结束时的倍率
//    animation1.removedOnCompletion = YES;
//    [bgGrayView2.layer addAnimation:animation1 forKey:nil];
//    
//    [UIView animateWithDuration:CircleAnimation_Gray_Scale_Time_Interval
//                     animations:^{
//                         bgGrayView1.alpha = 0.5;
//                     }
//                     completion:^(BOOL finished) {
//                         bgGrayView1.alpha = 1.0;
//                     }];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sepCountInteval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [UIView animateWithDuration:CircleAnimation_Gray_Scale_Time_Interval
//                         animations:^{
//                             bgGrayView2.alpha = 0.5;
//                         }
//                         completion:^(BOOL finished) {
//                             bgGrayView2.alpha = 1.0;
//                         }];
//    });
    
    
    
//    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
//    animGroup.animations = [NSArray arrayWithObjects:animation1, animationAlpha, nil];
//    animGroup.duration = CircleAnimation_Gray_Scale_Time_Interval;

    
    
    // 添加动画
//    [bgGrayLayer addAnimation:animation1 forKey:@"scale-layer"];
    

//    CABasicAnimation * animation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    // 动画选项设定
//    animation2.beginTime = CACurrentMediaTime()+CircleAnimation_Gray_Scale_Time_Interval;
//    animation2.duration = CircleAnimation_Gray_Scale_Time_Interval; // 动画持续时间
//    animation2.repeatCount = 1; // 重复次数
//    animation2.autoreverses = NO; // 动画结束时执行逆动画
//    // 缩放倍数
//    animation2.fromValue = [NSNumber numberWithFloat:0.5]; // 开始时的倍率
//    animation2.toValue = [NSNumber numberWithFloat:2.0]; // 结束时的倍率
    
    // 添加动画
//    [bgGrayLayer2 addAnimation:animation1 forKey:@"scale-layer-second"];
    
    //视图动画
    
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//    
//    // 动画选项设定
//    group.duration = 3.0;
//    group.repeatCount = 1;
//    
//    // 添加动画
//    group.animations = [NSArray arrayWithObjects:animation1, animation2, nil nil];
//    [myView.layer addAnimation:group forKey:@"move-rotate-layer"];
    
    
    
//    [self performSelector:@selector(circleAnimationDidShow) withObject:nil afterDelay:CircleAnimation_Time_Interval];
}


-(void)hideAnimationViewAfterAnimationEnd:(UIView *)aView
{
    aView.alpha = 0.0;
}


-(void)stopCircleAnimation
{
    needStopAnimation = YES;
    
    [centerCircle.layer removeAllAnimations];
    [bgGrayView1.layer removeAllAnimations];
    [bgGrayView2.layer removeAllAnimations];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
