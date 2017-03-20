//
//  InfoCompleteController.h
//  ZAIOSMainPrj
//
//  Created by zhangchaoqun on 15/5/12.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"
//完成信息补全功能
//此页面两处可能会调用
//1、注册成功后，
//2、用户手动点击补全信息
@interface InfoCompleteController : DPViewController


//右上角的跳过功能的后续操作
@property (nonatomic,copy) void (^TapedOnRightBtnBlock)(void);





@end
