//
//  DPViewController+Message.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/5.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController+Message.h"

@interface DPViewController ()

@end


@implementation DPViewController (Message)

ADD_DYNAMIC_PROPERTY(DPViewController*, OBJC_ASSOCIATION_RETAIN, smsVC, setSmsVC);

//是否可以发送短信
+(BOOL)canPostMessage
{
    return [MFMessageComposeViewController canSendText];
}


//展示发送短信界面文本
-(void)startActionForPostMessageWithContainString:(NSString *)message  andListArr:(NSArray *)list
{
    BOOL canSendSMS = [[self class] canPostMessage];
    
    if (canSendSMS)
    {
        
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        self.smsVC = picker;
        picker.messageComposeDelegate = self;
        
        picker.navigationBar.tintColor = [UIColor blackColor];
        
        picker.body = message;
        
        picker.recipients = list;
        
        [self presentViewController:picker animated:YES
                         completion:^{
                             
                         }];
    }else
    {
        [DZUtils noticeCustomerWithShowText:@"设备启动短信功能失败"];
    }

}
-(void)hideActionForPostMessageView
{
    if(self.CloseMessageViewFinishBlock)
    {
        self.CloseMessageViewFinishBlock(MessageComposeResultCancelled);
    }
    
    [self.smsVC dismissViewControllerAnimated:YES completion:nil];
}


//短信回收时的回调功能

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self hideActionForPostMessageView];
}


@end
