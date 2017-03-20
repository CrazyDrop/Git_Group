//
//  ZAWarnCancelController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/9/18.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"
#import "CircleStateView.h"
#import "ZAMMMaterialDesignSpinner.h"
//取消预警界面，因点击立即求助、10秒未输入密码进入的页面
@interface ZAWarnCancelController : DPViewController
{
    UIButton * telBtn;
    UIButton * messageBtn;
    UILabel * centerNumLbl;

    ZAMMMaterialDesignSpinner * _smallLoadingHUD;
}

@property (nonatomic,assign) BOOL startRecorder;//默认为NO，录音是否需要启动

@property (nonatomic,assign) BOOL showRedTop;   //默认为NO，当为YES时，需要展示红条   为NO展示蓝条

@property (nonatomic,assign) BOOL showNoticeLbl;//默认startRecorder为YES时无效 此时为YES，startRecorder为NO时，默认为NO

@property (nonatomic,assign) BOOL recorderUnable;//默认为NO

//用户点击取消预警后的事件
@property (nonatomic,copy) void (^TapedCancelWarnBlock) ();
-(void)startCircleAnimation;

-(void)retryUpload;

-(void)tapedOnTelBtn:(id)sender;
-(void)tapedOnMessageBtn:(id)sender;
-(void)tapedOnCancelBtn:(id)sender;

-(void)startAutoRecorderAndTimer;
-(void)startRecorderAndTimerWithRecorderAuth:(BOOL)enable;

-(void)refreshStateViewForState:(CircleStateViewStateType)type;
@end
