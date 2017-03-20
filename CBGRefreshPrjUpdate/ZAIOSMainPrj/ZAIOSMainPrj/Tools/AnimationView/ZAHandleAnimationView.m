//
//  ZAHandleAnimationView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/28.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHandleAnimationView.h"

@interface  ZAHandleAnimationView()
{
    
}
@property (nonatomic, readwrite) BOOL isAnimating;
@property (nonatomic,strong) UIImageView * topImg;
@property (nonatomic, strong) NSArray * telLines;
@property (nonatomic, strong) NSArray * messageLines;
@property (nonatomic, strong) NSArray * locationLines;
@end


@implementation ZAHandleAnimationView

-(void)setShowPerson:(BOOL)showPerson
{
    NSString * imgName = showPerson?@"warn_cancel_person":@"recorder_success";
    self.topImg.image = [UIImage imageNamed:imgName];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        self.backgroundColor = [UIColor clearColor];
        [self createSubViews];
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)createSubViews
{
    CGRect rect = self.bounds;
    
    UIView * bgView = self;
    

    CGFloat topWidth = FLoatChange(65);
    CGPoint centerPt = CGPointMake(rect.size.width/2.0, topWidth/2.0);
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, topWidth, topWidth)];
    img.image = [UIImage imageNamed:@"recorder_success"];
    self.topImg = img;
//    img.backgroundColor = [UIColor redColor];
    [bgView addSubview:img];
    img.center = centerPt;

    
    CGFloat startX = FLoatChange(35);
    CGFloat bottomY = FLoatChange(25);
    CGPoint pt = CGPointMake(rect.size.width/2.0, rect.size.height - bottomY);
    
    
    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_message"]];
    [bgView addSubview:img];
//    img.backgroundColor = [UIColor redColor];
    img.center = pt;
    UIView * msgView = img;
    
    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_telphone"]];
    [bgView addSubview:img];
    pt.x = startX;
    pt.y = rect.size.height - FLoatChange(55);
    img.center = pt;

    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_location"]];
    [bgView addSubview:img];
    pt.x = rect.size.width - startX;
    img.center = pt;
    
    
    self.telLines = [self animatedLineArrayForOneLineWithDegree:M_PI_2];
    self.messageLines = [self animatedLineArrayForOneLineWithDegree:M_PI_4];
    self.locationLines = [self animatedLineArrayForOneLineWithDegree:0];
    
    UIView * aView = (UIView *)[self.telLines lastObject];
    CGFloat eveWidth = aView.bounds.size.width;
    CGFloat eveHeight = sqrtf(2) * eveWidth;
    
    CGFloat spaceHeight =( CGRectGetMinY(msgView.frame) - CGRectGetMaxY(self.topImg.frame) - eveHeight*[self.telLines count])/2.0;

    CGPoint startPt = CGPointMake(rect.size.width/2.0,CGRectGetMaxY(self.topImg.frame) + spaceHeight + (eveHeight) * (0 +0.5));
    
    for (NSInteger i=0; i<3; i++)
    {
        UIView * eveView = [self.messageLines objectAtIndex:i];
        [bgView addSubview:eveView];
        pt.x = startPt.x;
        pt.y = startPt.y + eveHeight * i;
        eveView.center = pt;
    }
    
    CGFloat moveSpaceX = FLoatChange(36);
    CGFloat moveSpaceY = FLoatChange(8);
    
    startPt.x -= moveSpaceX;
    startPt.y -= moveSpaceY;
    
    eveHeight = eveWidth;
    for (NSInteger i=0; i<3; i++)
    {
        UIView * eveView = [self.telLines objectAtIndex:i];
        [bgView addSubview:eveView];
        pt.x = startPt.x - eveWidth * i;
        pt.y = startPt.y + eveHeight * i;
        eveView.center = pt;
    }
    
    startPt.x += 2*moveSpaceX;
    
    for (NSInteger i=0; i<3; i++)
    {
        UIView * eveView = [self.locationLines objectAtIndex:i];
        [bgView addSubview:eveView];
        pt.x = startPt.x + eveWidth * i;
        pt.y = startPt.y + eveHeight * i;
        eveView.center = pt;
    }
    
    pt = msgView.center;
    pt.y -= FLoatChange(10);
    msgView.center = pt;
    
}




-(NSArray *)animatedLineArrayForOneLineWithDegree:(CGFloat)degree
{
    NSMutableArray * arr = [NSMutableArray array];
    for (NSInteger i=0; i<3; i++)
    {
        UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cancel_line_icon"]];
        img.transform = CGAffineTransformMakeRotation(degree);
        [arr addObject:img];
    }
    return arr;
}

//start   取值  012  number 取值 0123
-(CAAnimation *)lineAnimationWithHiddenFirstTimeIndex:(NSTimeInterval)start andHiddenLastLengthNum:(NSTimeInterval)number;
{
    CGFloat eveTimeCount = 1.0;
    CGFloat eveTimesTotal = 4 * eveTimeCount;
    CGFloat totalTime = 3 * eveTimesTotal;
    NSTimeInterval showTimeInterval = 0.1;
    
    CGFloat animationHiddenStart = start * eveTimesTotal;
    CGFloat animationShowStart = animationHiddenStart + (number +1) * eveTimeCount;

    
//    CGFloat centerInterval = 0.2;
//    CGFloat maxCenterScale = 1.3;
    CGFloat repeatNum = MAXFLOAT;
    
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.repeatCount = repeatNum;
    group.removedOnCompletion=NO;
    group.duration = totalTime;
    
    CABasicAnimation *hideAnimation = [[self class] opacityForever_Animation_ForHidden:showTimeInterval];
    hideAnimation.beginTime = animationHiddenStart;
//    hideAnimation.beginTime = 2;
    
    CABasicAnimation *showAnimation = [[self class] opacityForever_Animation_ForShow:showTimeInterval];
    showAnimation.beginTime = animationShowStart - showTimeInterval;
//    showAnimation.beginTime = 4;
    
    group.animations = @[hideAnimation,showAnimation];
    
    return group;
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



-(void)startAnimation
{
    NSArray * array = self.telLines;
    
    NSString * line_animation_key = @"handleAnimation";
    for (NSInteger i=0;i<[array count];i++ )
    {
        UIView * aView = [array objectAtIndex:i];
        CAAnimation * animation = [aView.layer animationForKey:line_animation_key];
        if(!animation)
        {
            animation = [self lineAnimationWithHiddenFirstTimeIndex:0 andHiddenLastLengthNum:i];
        }
        [aView.layer addAnimation:animation forKey:line_animation_key];
    }
    
    array = self.messageLines;
    for (NSInteger i=0;i<[array count];i++ )
    {
        UIView * aView = [array objectAtIndex:i];
        CAAnimation * animation = [aView.layer animationForKey:line_animation_key];
        if(!animation)
        {
            animation = [self lineAnimationWithHiddenFirstTimeIndex:1 andHiddenLastLengthNum:i];
        }
        [aView.layer addAnimation:animation forKey:line_animation_key];
    }
    
    array = self.locationLines;
    for (NSInteger i=0;i<[array count];i++ )
    {
        UIView * aView = [array objectAtIndex:i];
        CAAnimation * animation = [aView.layer animationForKey:line_animation_key];
        if(!animation)
        {
            animation = [self lineAnimationWithHiddenFirstTimeIndex:2 andHiddenLastLengthNum:i];
        }
        [aView.layer addAnimation:animation forKey:line_animation_key];
    }
    
    
    
    self.isAnimating = YES;
    
    
}
-(void)stopAnimation
{
    self.isAnimating = NO;
    
    NSString * line_animation_key = @"handleAnimation";

    NSArray * array = self.telLines;
    for (NSInteger i=0;i<[array count];i++ )
    {
        UIView * aView = [array objectAtIndex:i];
        [aView.layer removeAnimationForKey:line_animation_key];
    }
    
    array = self.messageLines;
    for (NSInteger i=0;i<[array count];i++ )
    {
        UIView * aView = [array objectAtIndex:i];
        [aView.layer removeAnimationForKey:line_animation_key];
    }
    
    array = self.locationLines;
    for (NSInteger i=0;i<[array count];i++ )
    {
        UIView * aView = [array objectAtIndex:i];
        [aView.layer removeAnimationForKey:line_animation_key];
    }
    
    
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
