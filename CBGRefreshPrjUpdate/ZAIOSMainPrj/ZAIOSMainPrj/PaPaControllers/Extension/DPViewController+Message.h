//
//  DPViewController+Message.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/5.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"

//短信功能扩展
//实现功能，短信界面调用，短信发送回调的实现，短信回调代理的调用
@interface DPViewController (Message)<MFMessageComposeViewControllerDelegate>

@property (nonatomic,strong) UIViewController * smsVC;


//是否可以发送短信
+(BOOL)canPostMessage;


//展示发送短信界面文本
-(void)startActionForPostMessageWithContainString:(NSString *)message  andListArr:(NSArray *)list;

//关闭页面，取消，回收
-(void)hideActionForPostMessageView;


@end
