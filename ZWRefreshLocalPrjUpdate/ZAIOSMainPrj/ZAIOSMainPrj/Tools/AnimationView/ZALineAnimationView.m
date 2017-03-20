//
//  ZALineAnimationView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/27.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZALineAnimationView.h"

@interface ZALineAnimationView()
{
    
}
@property (nonatomic, readwrite) BOOL isAnimating;
@property (nonatomic, strong) UIView * coverView;
@end

@implementation ZALineAnimationView

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
        rect.size.width = 10;
        UIView * aView = [[UIView alloc] initWithFrame:rect];
        aView.backgroundColor = [DZUtils colorWithHex:@"68CBFF"];
        self.coverView = aView;
    }
    return _coverView;
}

-(void)createSubViews
{
    [self addSubview:self.coverView];
    self.coverView.center = CGPointMake(self.bounds.size.width/2.0,self.bounds.size.height/2.0);
}
-(void)startLineAnimation
{
//    if(self.isAnimating) return;
    
    CAAnimation * animation = [self.coverView.layer animationForKey:@"scaleAnimation"];
    
    //    CGFloat lineHeight = FLoatChange(6);
    //    CGRect oldImageFrame = CGRectMake(SCREEN_WIDTH/2.0, 0, 10, lineHeight);
    //    CGRect newFrame = CGRectMake(0, 0, SCREEN_WIDTH, lineHeight);
    
    if(!animation)
    {
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:0];
        scaleAnimation.toValue = [NSNumber numberWithFloat:SCREEN_WIDTH/10.0];
        scaleAnimation.autoreverses = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.repeatCount = MAXFLOAT;
        scaleAnimation.duration = 1;
        
        animation = scaleAnimation;
    }
    self.isAnimating = YES;
    [self.coverView.layer addAnimation:animation forKey:@"scaleAnimation"];
    
}
-(void)stopPointAnimation
{
    self.isAnimating = NO;
    [self.coverView.layer removeAnimationForKey:@"scaleAnimation"];
    
}

- (void)resetAnimations
{
    // If the app goes to the background, returning it to the foreground causes the animation to stop (even though it's not explicitly stopped by our code). Resetting the animation seems to kick it back into gear.
    if (self.isAnimating)
    {
        [self stopPointAnimation];
        [self startLineAnimation];
    }
}





@end
