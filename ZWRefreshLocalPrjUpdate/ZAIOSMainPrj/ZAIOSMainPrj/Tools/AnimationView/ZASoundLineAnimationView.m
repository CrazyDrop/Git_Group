//
//  ZASoundLineAnimationView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/29.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZASoundLineAnimationView.h"

@interface ZASoundLineAnimationView()
{
    
}
@property (nonatomic, readwrite) BOOL isAnimating;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic, assign) CGFloat needWidth;
@end

@implementation ZASoundLineAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        self.userInteractionEnabled = NO;
        self.clipsToBounds = YES;
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
//    CGRect rect = self.bounds;
    
    [self addSubview:self.coverView];
//    self.coverView.center = CGPointMake(rect.size.width/2.0,self.bounds.size.height/2.0);
    
    NSInteger count = 3;
    [self createLineViewsArrayForShowWithCountNumber:count];

}
-(void)refreshSoundViewSize
{
    //重新刷新大小
    CGPoint pt = self.center;
    CGRect rect = self.bounds;
    rect.size.width = self.needWidth;
    self.frame = rect;
    self.center = pt;
}

-(void)createLineViewsArrayForShowWithCountNumber:(NSInteger )num
{
    CGRect rect = self.bounds;
    
    
    NSInteger repeatNumber = num - 1;
    
    rect = self.bounds;
    NSInteger showNumber = 40;
    
    CGFloat lineWidth = (2);
    CGFloat spaceWidth = (int)(rect.size.width - showNumber * lineWidth)/(showNumber - 1.0);
    
    CGFloat length = lineWidth * showNumber + (showNumber - 1) * spaceWidth;
    self.needWidth = length;
    
    
    NSInteger lineNumbers = showNumber * num;
    UIView * bgView = self.coverView;
    rect = bgView.bounds;
    rect.size.width = lineWidth * lineNumbers + (lineNumbers - 1) * spaceWidth;;
//    rect.origin.x = self.bounds.size.width - rect.size.width;
    bgView.frame = rect;
    
    self.contentSize = bgView.bounds.size;
    
    
    CGFloat centerY = rect.size.height/2.0;
    NSMutableArray * copyArr = [NSMutableArray array];
//    NSMutableArray * totalArr = [NSMutableArray array];
    
    CGFloat maxHeight = FLoatChange(40);
    CGFloat minHeight = FLoatChange(5);
    UIColor *lineColor = [UIColor redColor];
    
    for (NSInteger count = 0; count<repeatNumber; count++)
    {
        for (NSInteger i=0;i<showNumber;i++)
        {
            int rand = arc4random() % 100;
            CGFloat height = rand/100.0 * (maxHeight - minHeight) + minHeight;
            
            UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lineWidth, height)];
//            if(count == 0) {
//                lineColor = [UIColor greenColor];
//            }else{
//                lineColor = [UIColor redColor];
//            }
            aView.backgroundColor = lineColor;
            [bgView addSubview:aView];
            aView.center = CGPointMake(lineWidth/2.0 + (i + count * showNumber + 0.0) * (lineWidth + spaceWidth), centerY);

            if(count == 0)
            {
                [copyArr addObject:[NSNumber numberWithFloat:height]];
            }
        }
    }
    
    for (NSInteger i=0;i<showNumber;i++)
    {
        NSNumber * heightNum = [copyArr objectAtIndex:i];
        CGFloat height = [heightNum floatValue];
        
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lineWidth, height)];
//        lineColor = [UIColor blackColor];
        aView.backgroundColor = lineColor;
        [bgView addSubview:aView];
        aView.center = CGPointMake(lineWidth/2.0 + (i + repeatNumber * showNumber+0.0) * (lineWidth + spaceWidth), centerY);
    }
    
}



-(void)startAnimation
{
    
    //使用位移动画，确定重复的个数
    CAAnimation * animation = [self.coverView.layer animationForKey:@"soundScaleAnimation"];
    
    //    CGFloat lineHeight = FLoatChange(6);
    //    CGRect oldImageFrame = CGRectMake(SCREEN_WIDTH/2.0, 0, 10, lineHeight);
    //    CGRect newFrame = CGRectMake(0, 0, SCREEN_WIDTH, lineHeight);
    
    if(!animation)
    {
        
        CGFloat totalWidth = self.coverView.bounds.size.width;
        CGFloat halfWidth = totalWidth/2.0;
        CGPoint pt = self.coverView.layer.position;
        pt.x = halfWidth - (totalWidth - self.bounds.size.width);
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        scaleAnimation.fromValue =  [NSValue valueWithCGPoint: pt];
        
        CGPoint toPoint = self.coverView.layer.position;
        toPoint.x = halfWidth;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:toPoint];
        
        scaleAnimation.autoreverses = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.repeatCount = MAXFLOAT;
        scaleAnimation.duration = 5;
        
        animation = scaleAnimation;
    }
    self.isAnimating = YES;
    [self.coverView.layer addAnimation:animation forKey:@"soundScaleAnimation"];
    
    
}
-(void)stopAnimation
{
    self.isAnimating = NO;
    [self.coverView.layer removeAnimationForKey:@"soundScaleAnimation"];
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
