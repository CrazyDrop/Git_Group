//
//  KMStatis.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "KMStatis.h"
#import "MobClick.h"

@implementation KMStatis

+(NSString *)pageNameFromPageType:(StaticControllerPageViewType)type{
    NSString * name = @"未知";
    switch (type)
    {

        case StaticControllerPageViewType_Main:
            name = @"主页";
            break;
        case StaticControllerPageViewType_Menu:
            name = @"列表页";
            break;
        case StaticControllerPageViewType_Login:
            name = @"登录页";
            break;
        case StaticControllerPageViewType_Forget:
            name = @"忘记密码页";
            break;
        case StaticControllerPageViewType_Register:
            name = @"注册页";
            break;
        case StaticControllerPageViewType_Service:
            name = @"服务条款页";
            break;
        case StaticControllerPageViewType_AboutUS:
            name = @"关于我们页";
            break;
        case StaticControllerPageViewType_FeedBack:
            name = @"意见反馈";
            break;
        default:
            break;
    }
    return name;
}

+(void)staticStartLogPageViewWithPageTitle:(NSString *)name
{
    NSString * staticName = name;
    if(!staticName) staticName = @"未知页面";
    [MobClick beginLogPageView:staticName];
}
+(void)staticEndLogPageViewWithPageTitle:(NSString *)name
{
    NSString * staticName = name;
    if(!staticName) staticName = @"未知页面";
    [MobClick beginLogPageView:staticName];
}


//页面统计
+(void)staticStartLogPageViewWithPageType:(StaticControllerPageViewType)type
{
    NSString * staticName = [[self class] pageNameFromPageType:type];
    [MobClick beginLogPageView:staticName];
}
+(void)staticEndLogPageViewWithPageType:(StaticControllerPageViewType)type{
    NSString * staticName = [[self class] pageNameFromPageType:type];
    [MobClick beginLogPageView:staticName];
}

+(NSMutableDictionary * )APPChannelDic
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
//    [dic setObject:kAPP_PAPA_Channel_Identifier forKey:@"Channel"];
    return dic;
}

+(void)staticShareEvent:(StaticShareEventType)type andNoticeStr:(NSString *)str
{
    NSString * menuTap = nil;
    switch (type)
    {
        case  StaticShareEventType_QQ_Success://完成
            menuTap = @"QQ分享成功";
            break;
        case  StaticShareEventType_QQ_Fail:
            menuTap = @"QQ分享失败";
            break;
        case  StaticShareEventType_WX_Fail://完成
            menuTap = @"微信分享失败";
            break;
        case  StaticShareEventType_WX_Sucess:
            menuTap = @"微信分享成功";
            break;
        default:
            break;
    }
    
    if(menuTap)
    {
        if(str){
            menuTap = [menuTap stringByAppendingString:str];
        }
        NSMutableDictionary * dic = [[self class] APPChannelDic];
        [dic setObject:menuTap forKey:@"Event"];
        [MobClick event:@"ShareEventUpdate" attributes:dic];
        return;
    }
    menuTap = @"未知";
    
    switch (type)
    {
        case  StaticShareEventType_QQLogin_Success://完成
            menuTap = @"QQ登录成功";
            break;
        case  StaticShareEventType_QQLogin_Fail:
            menuTap = @"QQ登录失败";
            break;
        case  StaticShareEventType_WXLogin_Fail:
            menuTap = @"微信登录失败";
            break;
        case  StaticShareEventType_WXLogin_Success:
            menuTap = @"微信登录成功";
            break;
        default:
            break;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"OtherLoginEvent" attributes:dic];

}
+(void)staticApplicationEvent:(StaticApplicationEventType)type
{
    NSString * menuTap = @"未知";
    
    switch (type)
    {
        case  StaticApplicationEventType_Start://启动
            menuTap = @"应用启动";
            break;
        case  StaticApplicationEventType_URLOpen_QQ:
            menuTap = @"QQ回调打开";
            break;
        case  StaticApplicationEventType_URLOpen_WX:
            menuTap = @"微信回调打开";
            break;
        case  StaticApplicationEventType_EnterForground:
            menuTap = @"进入前台";
            break;
        case  StaticApplicationEventType_ResignActive:
            menuTap = @"进入后台";
            break;
        default:
            break;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];

    [MobClick event:@"ApplicationEvent" attributes:dic];

    if(type==StaticApplicationEventType_Start)
    {
        NSMutableDictionary * dic = [[self class] APPChannelDic];
        [dic setObject:menuTap forKey:@"Event"];
        [MobClick event:@"ApplicationStartEvnet" attributes:dic];
    }
}

+(void)staticWarningStartEvent:(StaticPaPaWarningStartType)type
{
    [[self class] staticWarningStartEvent:type andTimeLength:nil];
}

+(void)staticWarningStartEvent:(StaticPaPaWarningStartType)type andTimeLength:(NSString *)length{
    
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticPaPaWarningStartType_Timing_Success://启动
            menuTap = @"倒计时功能启动成功";
            break;
        case  StaticPaPaWarningStartType_Timing_Fail:
            menuTap = @"倒计时功能启动失败";
            break;
        case  StaticPaPaWarningStartType_Quick_Success:
            menuTap = @"一键求助功能启动成功";
            break;
        case  StaticPaPaWarningStartType_Quick_Fail:
            menuTap = @"一键求助功能启动失败";
            break;
        default:
            break;
    }
    
    if(length) menuTap = [length stringByAppendingFormat:@"_%@",menuTap];
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"WarningStartTypeUpate" attributes:dic];
    
    
}
+(void)staticTimingViewEvent:(StaticPaPaTimingEventType)type{
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticPaPaTimingEventType_Safe://启动
            menuTap = @"点击我已安全";
            break;
        case  StaticPaPaTimingEventType_Help:
            menuTap = @"点击需要求助";
            break;
        case  StaticPaPaTimingEventType_Show:
            menuTap = @"界面展示";
            break;
        default:
            break;
    }
 
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"TimingEventType" attributes:dic];
}
+(void)staticResetTimeEvent:(StaticPaPaTimingResetTimeEventType)type{
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticPaPaTimingResetTimeEventType_Start://启动
            menuTap = @"启动时间设定";
            break;
        case  StaticPaPaTimingResetTimeEventType_Confirm:
            menuTap = @"时间修改确定";
            break;
        case  StaticPaPaTimingResetTimeEventType_Cancel:
            menuTap = @"时间修改取消";
            break;
        default:
            break;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"ResetTimeEventType" attributes:dic];
    
}
+(void)staticLocalContactsEvent:(StaticPaPaLocalContactsEventType)type{
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticPaPaLocalContactsEventType_Start://启动
            menuTap = @"点击通讯录";
            break;
        case  StaticPaPaLocalContactsEventType_Confirm:
            menuTap = @"通讯录内选定";
            break;
        case  StaticPaPaLocalContactsEventType_Cancel:
            menuTap = @"通讯录内取消";
            break;
        case  StaticPaPaLocalContactsEventType_Show:
            menuTap = @"点击通讯录 按钮 展示次数";
            break;
        default:
            break;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"LocalContactsEventType" attributes:dic];
}

+(void)staticRegisterEvent:(StaticPaPaRegisterEventType)type
{
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticPaPaRegisterEventType_Start:
            menuTap = @"开始体验";
            break;
        case  StaticPaPaRegisterEventType_Login://启动
            menuTap = @"点击开始使用";
            break;
        case  StaticPaPaRegisterEventType_Next:
            menuTap = @"点击下一步";
            break;
        case  StaticPaPaRegisterEventType_Another://启动
            menuTap = @"点击再设一个";
            break;
        case  StaticPaPaRegisterEventType_Finish://启动
            menuTap = @"点击完成";
            break;
        case  StaticPaPaRegisterEventType_AddressList://启动
            menuTap = @"点击通讯录";
            break;
        case  StaticPaPaRegisterEventType_Login_Success://启动
            menuTap = @"点击开始使用_成功";
            break;
        case  StaticPaPaRegisterEventType_Next_Success:
            menuTap = @"点击下一步_成功";
            break;
        case  StaticPaPaRegisterEventType_Another_Success://启动
            menuTap = @"点击再设一个_成功";
            break;
        case  StaticPaPaRegisterEventType_Finish_Success://启动
            menuTap = @"点击完成_成功";
            break;
        case  StaticPaPaRegisterEventType_AddressList_Success://启动
            menuTap = @"点击通讯录_成功";
            break;
            
        default:
            break;
    }
    
    //开始体验，移动到新位置
    if(type == StaticPaPaRegisterEventType_Start)
    {
        NSMutableDictionary * dic = [[self class] APPChannelDic];
        [dic setObject:menuTap forKey:@"Event"];
        [MobClick event:@"TasteEventType" attributes:dic];
        return;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"RegisterEventType_New" attributes:dic];
}
+(void)staticWKWarningStaticEvent:(StaticPaPaWKWarningEventType)type
{
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticPaPaWKWarningEventType_StartTimer:
            menuTap = @"定时模式_开始防护";
            break;
        case  StaticPaPaWKWarningEventType_WarningTimer://启动
            menuTap = @"定时模式_需要援助";
            break;
        case  StaticPaPaWKWarningEventType_QuickWarning:
            menuTap = @"紧急模式_立即预警";
            break;
        case  StaticPaPaWKWarningEventType_Cancel://启动
            menuTap = @"取消预警";
            break;
        default:
            break;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"WKWarningEventType" attributes:dic];
}
+(void)staticWKApplicationStartEvent:(StaticPaPaWKApplicationStartEventType)type
{
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticPaPaWKApplicationStartEventType_Start:
            menuTap = @"手表应用启动";
            break;
            default:
            break;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"WKApplicationEventType" attributes:dic];
}

//使用打点统计、统计controller、init方法
+(void)staticApplicationVCinitWithVCClassDes:(NSString *)des
{
    NSString * menuTap = des;
    if(!des || [des length]==0)
    {
        menuTap = @"未知";
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"ApplicationInitNumAndType" attributes:dic];
    
}

+(void)staticApplicationWillResignActiveForVCClassDes:(NSString *)des
{
    NSString * menuTap = des;
    if(!des || [des length]==0)
    {
        menuTap = @"未知";
    }
    
    menuTap = [menuTap stringByAppendingString:@"_Resign"];
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"ApplicationActiveNumAndType" attributes:dic];
    
}
+(void)staticApplicationDidBecomeActiveVCClassDes:(NSString *)des
{
    NSString * menuTap = des;
    if(!des || [des length]==0)
    {
        menuTap = @"未知";
    }
    menuTap = [menuTap stringByAppendingString:@"_DidBecome"];

    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"ApplicationActiveNumAndType" attributes:dic];
    
}

+(void)staticSharePathStaticEvent:(StaticPaPaSharePathEventType)type
{
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticPaPaSharePathEventType_Start:
            menuTap = @"分享轨迹_开始";
            break;
        case  StaticPaPaSharePathEventType_ShowShare://启动
            menuTap = @"分享轨迹_分享按钮点击";
            break;
        case  StaticPaPaSharePathEventType_TapedShare:
            menuTap = @"分享轨_类型icon点击";
            break;
        default:
            break;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"SharePathEventType" attributes:dic];
    
}
+(void)staticDoMenuStartEvent:(StaticPaPaDoMenuEventType)type andText:(NSString *)txt
{
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticPaPaDoMenuEventType_Start:
            menuTap = @"去做什么_开始";
            break;
        case  StaticPaPaDoMenuEventType_Finish://启动
        {
            if(txt)
            {
                menuTap = @"去做什么_完成_";
                menuTap = [menuTap stringByAppendingString:txt];
            }else
            {
                menuTap = @"去做什么_取消";
            }
        }
            break;
        default:
            break;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"SharePathEventType" attributes:dic];
}

+(void)staticSharePathViewEvent:(StaticSharePathViewEventType)type
{
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticSharePathViewEventType_Show:
            menuTap = @"分享页面_展示";
            break;
        case  StaticSharePathViewEventType_QQ://QQ
            menuTap = @"点击QQ";
            break;
        case  StaticSharePathViewEventType_WX://WX
            menuTap = @"点击微信";
            break;
        case  StaticSharePathViewEventType_MESSAGE://短信
            menuTap = @"点击短信";
            break;
        case  StaticSharePathViewEventType_TOTAL://一键
            menuTap = @"点击一键发送";
            break;
        case  StaticSharePathViewEventType_CANCEL://取消
            menuTap = @"分享页面_取消";
            break;
        default:
            break;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"SharePathViewEventType" attributes:dic];
}

+(void)staticQuickCancelViewEvent:(StaticQuickCancelEventType)type{
    NSString * menuTap = @"未知";
    switch (type)
    {
        case  StaticQuickCancelEventType_Show:
            menuTap = @"5s倒计时页面_展示";
            break;
        case  StaticQuickCancelEventType_Cancel://QQ
            menuTap = @"5s倒计时页面_取消";
            break;
        case  StaticQuickCancelEventType_Request://WX
            menuTap = @"5s倒计时页面_发送请求";
            break;
        case  StaticQuickCancelEventType_Request_Success://短信
            menuTap = @"5s倒计时页面_发送成功";
        default:
            break;
    }
    
    NSMutableDictionary * dic = [[self class] APPChannelDic];
    [dic setObject:menuTap forKey:@"Event"];
    [MobClick event:@"QuickCancelEventType" attributes:dic];
}



@end
