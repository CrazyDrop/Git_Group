//
//  ZAQuickCancelController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/21.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"
//完成5s倒计时页面，界面功能   倒计时结束后发起新预警，点击不需要求助关闭页面
//5s倒计时
//紧急模式，或 立即求助
@interface ZAQuickCancelController : DPViewController


//用户点击取消预警后的事件
@property (nonatomic,copy) void (^TapedCancelWarnBlock) ();


@end
