//
//  ZAPasswordController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"

typedef enum {
    PWDCheckFinishType_PWD,   //正确密码
    PWDCheckFinishType_RESET, //错误密码  失败次数过多
    PWDCheckFinishType_FAKE,  //报警密码
}PWDCheckFinishType;//密码校验通过的类型

//密码输入界面
//本地优化:内部已经成功发送过runwarning，则后续不发送
@interface ZAPasswordController : DPViewController

@property (nonatomic,assign) BOOL showBack;//展示返回按钮

//针对倒计时结束进入的界面，不发送启动预警的网络请求
@property (nonatomic,assign) BOOL timeEndState;//是否为倒计时结束进入

//done check PWD后的事件
@property (nonatomic,copy) void (^PWDCheckSuccessBlock) (PWDCheckFinishType type);

//新增修改是否为紧急模式页面，默认为NO
@property (nonatomic,assign) BOOL needTimer;//是否为倒计时结束进入


-(void)restartPWDTimerRefresh;
-(void)stopPWDTimerAndHiddenLbl;



@end
