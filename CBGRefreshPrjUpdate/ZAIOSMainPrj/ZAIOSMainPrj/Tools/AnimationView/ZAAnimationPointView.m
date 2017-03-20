//
//  ZAAnimationPointView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/27.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAAnimationPointView.h"

@interface ZAAnimationPointView()

@property (nonatomic,strong) UIImageView * img1;
@property (nonatomic,strong) UIImageView * img2;
@property (nonatomic,strong) UIImageView * img3;

@property (nonatomic, readwrite) BOOL isAnimating;

@end

@implementation ZAAnimationPointView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];

        
        self.ptSepX = FLoatChange(6);
        self.ptWidth = FLoatChange(6);
        
        [self createSubViews];
    }
    return self;
}
- (void)resetAnimations
{
    // If the app goes to the background, returning it to the foreground causes the animation to stop (even though it's not explicitly stopped by our code). Resetting the animation seems to kick it back into gear.
    if (self.isAnimating) {
        [self stopPointAnimation];
        [self startPointAnimation];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
-(void)createSubViews
{
    CGFloat width = self.ptWidth;
    CGRect rect = CGRectMake(0, 0, width, width);
    
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:rect];
    imgView.image = [UIImage imageNamed:@"icon_wait_dot_1"];
    [self addSubview:imgView];
    imgView.alpha = 0.0;
    self.img1 = imgView;

    imgView = [[UIImageView alloc] initWithFrame:rect];
    imgView.image = [UIImage imageNamed:@"icon_wait_dot_2"];
    imgView.alpha = 0.0;
    [self addSubview:imgView];
    self.img2 = imgView;
    
    imgView = [[UIImageView alloc] initWithFrame:rect];
    imgView.image = [UIImage imageNamed:@"icon_wait_dot_3"];
    imgView.alpha = 0.0;
    
    [self addSubview:imgView];
    self.img3 = imgView;

    CGFloat sepX = self.ptSepX;
    CGFloat totalWidth = width * 3 + sepX * 2;
    rect = self.bounds;
    CGFloat centerY = CGRectGetMidY(rect);
    CGFloat startX = (rect.size.width - totalWidth)/2.0;

    
    startX += (width/2.0);
    self.img1.center = CGPointMake(startX, centerY);
    
    startX += (width + sepX);
    self.img2.center = CGPointMake(startX, centerY);
    
    startX += (width + sepX);
    self.img3.center = CGPointMake(startX, centerY);
}

-(void)startPointAnimation
{
//    if (self.isAnimating)
//        return;
    
    CAAnimation * animation1 =[self.img1.layer animationForKey:@"group1"];
    CAAnimation * animation2 =[self.img2.layer animationForKey:@"group2"];
    CAAnimation * animation3 =[self.img3.layer animationForKey:@"group3"];
    if(animation1 && animation2 && animation3)
    {
        [self.img1.layer addAnimation:animation1 forKey:@"group1"];
        [self.img2.layer addAnimation:animation2 forKey:@"group2"];
        [self.img3.layer addAnimation:animation3 forKey:@"group3"];
        return;
    }
    
    NSTimeInterval totalTime = 2;
    NSTimeInterval eveTimeInterval = totalTime/4.0;
    NSTimeInterval showTimeInterval = 0.1;
    CGFloat repeatNum = MAXFLOAT;

    
//    针对每个点，单独动画group
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.repeatCount = repeatNum;
    group.removedOnCompletion=NO;
    group.duration = totalTime;
    
    CABasicAnimation *showAnimation = [[self class] opacityForever_Animation_ForShow:showTimeInterval];
    showAnimation.beginTime = eveTimeInterval;
    CABasicAnimation *hideAnimation = [[self class] opacityForever_Animation_ForHidden:showTimeInterval];
    hideAnimation.beginTime = totalTime - showTimeInterval;
    group.animations = @[showAnimation,hideAnimation];
    [self.img1.layer addAnimation:group forKey:@"group1"];
    
    
    CAAnimationGroup * group2 = [CAAnimationGroup animation];
    group2.duration = totalTime;
    group2.repeatCount = repeatNum;
    
    CABasicAnimation *showAnimation2 = [[self class] opacityForever_Animation_ForShow:showTimeInterval];
    showAnimation2.beginTime = eveTimeInterval*2;
    CABasicAnimation *hideAnimation2 = [[self class] opacityForever_Animation_ForHidden:showTimeInterval];
    hideAnimation2.beginTime = totalTime - showTimeInterval;;
    group2.animations = @[showAnimation2,hideAnimation2];
    [self.img2.layer addAnimation:group2 forKey:@"group2"];

    CAAnimationGroup * group3 = [CAAnimationGroup animation];
    group3.duration = totalTime;
    group3.repeatCount = repeatNum;
    
    CABasicAnimation *showAnimation3 = [[self class] opacityForever_Animation_ForShow:showTimeInterval];
    showAnimation3.beginTime = eveTimeInterval*3;
    CABasicAnimation *hideAnimation3 = [[self class] opacityForever_Animation_ForHidden:showTimeInterval];
    hideAnimation3.beginTime = totalTime - showTimeInterval;;
    group3.animations = @[showAnimation3,hideAnimation3];
    [self.img3.layer addAnimation:group3 forKey:@"group3"];
    
    self.isAnimating = true;
}

+(CABasicAnimation *)opacityForever_Animation_ForHidden:(float)time //永久闪烁的动画
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue=[NSNumber numberWithFloat:1.0];
    animation.toValue=[NSNumber numberWithFloat:0.0];
    animation.duration=time;
    animation.repeatCount=0;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}
+(CABasicAnimation *)opacityForever_Animation_ForShow:(float)time //永久闪烁的动画
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue=[NSNumber numberWithFloat:0.0];
    animation.toValue=[NSNumber numberWithFloat:1.0];
    animation.autoreverses=NO;
    animation.duration=time;
    animation.repeatCount=0;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}


-(void)stopPointAnimation
{
    if (!self.isAnimating)
        return;
    
    [self.img1.layer removeAllAnimations];
    [self.img2.layer removeAllAnimations];
    [self.img3.layer removeAllAnimations];
    
    self.isAnimating = NO;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/





@end
