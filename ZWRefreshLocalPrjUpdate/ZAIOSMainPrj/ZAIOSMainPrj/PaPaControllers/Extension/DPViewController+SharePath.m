//
//  DPViewController+SharePath.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController+SharePath.h"
#import "DPViewController+Message.h"
#import "DPViewController+NoticeTA.h"
#import "QQSpaceShare.h"
#import "WeixinShare.h"
#import "SharePopupView.h"
@implementation DPViewController (SharePath)

-(void)showSharePathShareStyleView
{
    [KMStatis staticSharePathStaticEvent:StaticPaPaSharePathEventType_ShowShare];
    [KMStatis staticSharePathViewEvent:StaticSharePathViewEventType_Show];

    
    __weak typeof(self)  weakSelf = self;
    SharePopupView *popupView=[[SharePopupView alloc]initWithType:SharePopupViewType_SharePath];
    [popupView setSharePopupViewEvent:^(SharePopupViewEventType eventType)
     {
         [weakSelf shareInputTextForApplication:eventType];
     }];
    popupView.tag = 100;
    UIViewController * controller = self;
    if(!controller) controller = self;
    [popupView showInView:controller.view animated:YES];
}
-(void)hideSharePathShareView
{
    UIViewController * controller = self;
    UIView * view = controller.view;
    
    SharePopupView * pop = (SharePopupView *)[view viewWithTag:100];
    if([pop isKindOfClass:[SharePopupView class]]){
         [pop hide:YES];
    }
    
}
-(void)shareInputTextForApplication:(SharePopupViewEventType)type
{
    //根据shareType确定文本
    //    txt确定内容解释
    //进行分享
    [KMStatis staticSharePathStaticEvent:StaticPaPaSharePathEventType_TapedShare];

    NSString * txt = kShare_Default_Message;
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * numId = total.timeModel.timeId;
    
    NSArray * array = total.contacts;
    NSArray * list = nil;
    if(array && [array count]>0)
    {
        NSMutableArray * deleted = [NSMutableArray array];
        NSMutableArray * effective = [NSMutableArray array];
        
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ContactsModel * contact = (ContactsModel *)obj;
            NSString * tag = contact.isDeleted;
            if(tag && [tag boolValue])
            {
                [deleted addObject:obj];
            }else{
                [effective addObject:obj];
            }
        }];
        
        if([effective count]>0)
        {
            NSMutableArray * telArr = [NSMutableArray array];
            [effective enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                ContactsModel * obj = (ContactsModel * )obj1;
                NSString * tel = obj.contactMobile;
                if(tel && [tel length]>0)
                {
                    [telArr addObject:tel];
                }
            }];
            list = telArr;
        }
    }
    
    numId = [DZUtils DESEncryptAndURLEncodeWithWarningID:numId];
    if(!numId) return;
    
    NSString * home = @"http://10.139.104.74:6080/za-papa/static/share/share.html";
#if kAPP_Local_UAT_URL_Identifier_TAG
    home = @"http://120.55.172.37/za-papa/static/share/share.html";
#endif
#if kAPP_Local_Release_URL_Identifier_TAG
    home = @"http://papa.zhongan.com/za-papa/static/share/share.html";
#endif
    home = [home stringByAppendingFormat:@"?client_type=4&v=%@",[DZUtils currentAppBundleShortVersion]];
    home = [home stringByAppendingString:@"&warningId="];
    
    
    
    NSString * urlStr = [home stringByAppendingString:numId];
    
    switch (type) {
        case SharePopupViewEventType_ShareContacts:
        {
            [KMStatis staticSharePathViewEvent:StaticSharePathViewEventType_TOTAL];

            NSMutableString * message = [NSMutableString string];
            [message appendString:txt];
            [message appendFormat:@" 点击链接可查看我的位置%@",urlStr];
            
            [self startActionForPostMessageWithContainString:message andListArr:list];
        }
            break;
        case SharePopupViewEventType_Message:
        {
            [KMStatis staticSharePathViewEvent:StaticSharePathViewEventType_MESSAGE];

            NSMutableString * message = [NSMutableString string];
            [message appendString:txt];
            [message appendFormat:@" 点击链接可查看我的位置%@",urlStr];
            
            NSArray * arr = [NSArray arrayWithObject:[list firstObject]];
            [self startActionForPostMessageWithContainString:message andListArr:arr];
        }
            break;
        case SharePopupViewEventType_QQ:
        {
            [KMStatis staticSharePathViewEvent:StaticSharePathViewEventType_QQ];
            [QQSpaceShare shareQQSpace].type = OthersAppDetailShareType_SharePath;
            [[QQSpaceShare shareQQSpace] zaShareNewsToQQWithOnLine:YES
                                                           withUrl:urlStr
                                                        andContent:txt];
        }
            break;
        case SharePopupViewEventType_WXSession:
        {
            [KMStatis staticSharePathViewEvent:StaticSharePathViewEventType_WX];
            [WeixinShare shareWeixin].type = OthersAppDetailShareType_SharePath;
            [[WeixinShare shareWeixin] zaSharePathWeinxinType:WXSceneSession
                                                      content:txt
                                                   andPathUrl:urlStr];
        }
            break;
        default:
            break;
    }
    
    
}



@end
