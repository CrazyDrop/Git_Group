//
//  ZATipsCoverView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/30.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZATipsCoverView.h"
@interface ZATipsCoverView()
{
    UIView * grayView;
}
@end
@implementation ZATipsCoverView

-(void)createSubViews
{
    self.backgroundColor = [UIColor clearColor];
    
    UIView * aView =  [[UIView alloc] initWithFrame:self.bounds];
    aView.backgroundColor = [UIColor blackColor];
    aView.alpha = 0.8;
    [self addSubview:aView];
    aView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    grayView = aView;

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnCoverView)];
    [aView addGestureRecognizer:tap];
}
-(void)tapedOnCoverView
{
    [self hideCoverView];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.tipsIdentifier = USERDEFAULT_CoverView_Tips_Main_Show;
        [self createSubViews];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


//进行数据保存
-(void)hideCoverView
{
    if(!self.tipsIdentifier) return;
    
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * tipsIdentifier = self.tipsIdentifier;
    if([tipsIdentifier isEqualToString:USERDEFAULT_CoverView_Tips_Main_Show])
    {
        local.main_Tips_Showed = YES;
    }else if([tipsIdentifier isEqualToString:USERDEFAULT_CoverView_Tips_Start_Show])
    {
        local.start_Tips_Showed = YES;
    }else if([tipsIdentifier isEqualToString:USERDEFAULT_CoverView_Tips_Timer_Show])
    {
        local.timer_Tips_Showed = YES;
    }
    [local localSave];
    [self removeFromSuperview];
}


@end
