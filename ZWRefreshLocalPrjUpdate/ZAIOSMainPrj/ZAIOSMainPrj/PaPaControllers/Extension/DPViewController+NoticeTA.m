//
//  DPViewController+NoticeTA.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/5.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController+NoticeTA.h"
#import "SharePopupView.h"
#import "DPViewController+Message.h"
#import "WeixinShare.h"

@implementation DPViewController (NoticeTA)
ADD_DYNAMIC_PROPERTY(NSArray *, OBJC_ASSOCIATION_RETAIN, taArr,setTaArr);

- (IBAction)sendSMS
{
    [self startActionForPostMessageWithContainString:NoticeMessage andListArr:self.taArr];
}
-(void)showPopDetailForType:(SharePopupViewEventType )type
{
    switch (type) {
        case SharePopupViewEventType_WXSession:
        {
            [[WeixinShare shareWeixin] zaNoticePostWeinxinType:WXSceneSession content:NoticeMessage];
        }
            break;
        case SharePopupViewEventType_Message:
        {
            [self sendSMS];
        }
            break;
        default:
            break;
    }
}
-(void)showShareStyleView
{
    __weak typeof(self)  weakSelf = self;
    SharePopupView *popupView=[[SharePopupView alloc]initWithType:SharePopupViewType_NoticeTA];
    [popupView setSharePopupViewEvent:^(SharePopupViewEventType eventType)
     {
         //进行展示
         [weakSelf showPopDetailForType:eventType];
     }];
    
    UIViewController * controller = self;
//    if(!controller) controller = self;
    [popupView showInView:controller.view animated:YES];
}
-(void)startActionForNoticeTA:(NSArray *)arr
{
    self.taArr = arr;
    BOOL WXHide = ![WXApi isWXAppInstalled];
    if(WXHide)
    {
        [self sendSMS];
        return;
    }
    [self showShareStyleView];
}

@end
