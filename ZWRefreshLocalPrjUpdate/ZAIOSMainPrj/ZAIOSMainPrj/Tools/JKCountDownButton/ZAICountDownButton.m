//
//  ZAICountDownButton.m
//  ZAIOSMainPrj
//
//  Created by Joe on 15/6/30.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAICountDownButton.h"

#define DefaultDuration 60

@interface ZAICountDownButton()
{
    NSInteger duration;
    NSInteger defaultDuration;
    NSTimer *countDownTimer;
}
@property (nonatomic, copy) NSString *defaultTitle;
@end

@implementation ZAICountDownButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        defaultDuration = DefaultDuration;
        duration = DefaultDuration;
    }
    return self;
}
-(void)dealloc
{
    [countDownTimer invalidate];
    countDownTimer = nil;
}

- (void)setDuration:(NSInteger)interval
{
    duration = interval;
    defaultDuration = interval;
}

- (void)countDown
{
    duration--;
    if(duration == 0)
    {
        [self stopCountDown];
        return;
    }
//    NSString *title = [NSString stringWithFormat:ZAViewLocalizedStringForKey(@"ZAViewLocal_CountDown_Title"),duration];
    NSString * title = [NSString stringWithFormat:@"%lds",duration];
    [self setTitle:title forState:UIControlStateDisabled];
}

- (void)startCountDown
{
//    NSString *title = [NSString stringWithFormat:ZAViewLocalizedStringForKey(@"ZAViewLocal_CountDown_Title"),duration];
    NSString * title = [NSString stringWithFormat:@"%lds",duration];
    [self setTitle:title forState:UIControlStateDisabled];
    [self setEnabled:NO];
    [self performSelector:@selector(countDown)
               withObject:nil
               afterDelay:1.0];
    if(countDownTimer)
    {
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(countDown)
                                                    userInfo:nil
                                                     repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:countDownTimer forMode:NSRunLoopCommonModes];

}

- (void)stopCountDown
{
    duration = defaultDuration;
    if(countDownTimer)
    {
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
    [self setTitle:self.defaultTitle forState:UIControlStateNormal];
    [self setEnabled:YES];
    
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    if(state == UIControlStateNormal)
    {
        self.defaultTitle = title;
    }
}

@end
