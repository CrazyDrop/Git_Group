//
//  ZAWebStateController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/9/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController+WebState.h"

@interface DPViewController (Private)
-(void)refreshWebStateViewWithConnectEnable:(BOOL)enable;
@end

@implementation DPViewController (WebState)

-(void)createTopErrorView
{
    CGFloat viewHeight = FLoatChange(58);
    CGFloat btnWidth = FLoatChange(30);
    CGFloat startWidth = FLoatChange(10);
    CGRect rect = CGRectMake(0,kTop , SCREEN_WIDTH, viewHeight);
    
    UIView * aView = [[UIView alloc] initWithFrame:rect];
    aView.backgroundColor = [UIColor orangeColor];
    aView.hidden = YES;
    
    UIButton * endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    endBtn.frame = CGRectMake(0, 0 , btnWidth, btnWidth);
    [endBtn addTarget:self action:@selector(hideTopErrorView) forControlEvents:UIControlEventTouchUpInside];
    [aView addSubview:endBtn];
    [endBtn setImage:[UIImage imageNamed:@"notice_stop"] forState:UIControlStateNormal];
    endBtn.backgroundColor = [UIColor clearColor];
//    [endBtn setBackgroundImage:[UIImage imageNamed:@"notice_stop"] forState:UIControlStateNormal];
    endBtn.center = CGPointMake(SCREEN_WIDTH - btnWidth/2.0, viewHeight/2.0);

    rect = aView.bounds;
    rect.origin.x = startWidth;
    rect.size.width = (SCREEN_WIDTH - startWidth - btnWidth);
    UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
    [aView addSubview:lbl];
    lbl.numberOfLines = 0;
    lbl.text = @"无法连接到您的网络，请您检查网络以便我们能随时随地的对您进行安全防护。";
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
    
    self.topErrorView = aView;
    
    [self.view addSubview:aView];
}

-(void)hideTopErrorView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WEBCHECK_NOTICE_SHOW_STATE
                                                        object:[NSNumber numberWithBool:YES]];
}

#pragma mark - Public Methods
-(void)startWebStateNotificationListen
{
    if(!self.topErrorView)
    {
        [self createTopErrorView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webStateChanged:)
                                                 name:NOTIFICATION_WEBCHECK_NOTICE_SHOW_STATE
                                               object:nil];
    
    //延迟，刷新界面，针对刚展示的界面展示无网络提示
    [self performSelector:@selector(showWebStateNoticeViewForController) withObject:nil afterDelay:1];
}
-(void)showWebStateNoticeViewForController
{
    [self refreshWebStateViewWithConnectEnable:[DZUtils deviceWebConnectEnableCheck]];
}

-(void)webStateChanged:(NSNotification *)noti
{
    NSNumber * num = noti.object;
    [self refreshWebStateViewWithConnectEnable:[num boolValue]];
}

-(void)refreshWebStateViewWithConnectEnable:(BOOL)enable
{
    NSLog(@"errorView Hidden %d",enable);
    self.topErrorView.hidden = enable;
}
#pragma mark ----

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}


@end
