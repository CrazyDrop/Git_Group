//
//  KMStatis.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

//事件定义，事件统计封装

//1、使用类方法封装
//2、使用枚举定义事件名称

//功能页面类型
typedef enum {
    StaticControllerPageViewType_Main = 0,  //主页
    StaticControllerPageViewType_Menu,      //列表页
    StaticControllerPageViewType_Login,     //登录页
    StaticControllerPageViewType_Forget,    //忘记密码页
    StaticControllerPageViewType_Register,  //注册页
    StaticControllerPageViewType_Service,   //服务条款页
    
    StaticControllerPageViewType_AboutUS,   //关于我们页
    StaticControllerPageViewType_FeedBack,  //意见反馈页
    StaticControllerPageViewType_InfoComplete,   //信息完善页
    
}StaticControllerPageViewType;


//第三方登录相关事件统计
typedef enum {
    StaticShareEventType_QQ_Success = 0,  //QQ分享成功
    StaticShareEventType_QQ_Fail,         //QQ分享失败
    StaticShareEventType_WX_Sucess,       //WX分享成功
    StaticShareEventType_WX_Fail,         //WX分享成功

    StaticShareEventType_QQLogin_Success, //QQ登录成功
    StaticShareEventType_QQLogin_Fail,    //QQ登录失败
    StaticShareEventType_WXLogin_Success, //WX登录成功
    StaticShareEventType_WXLogin_Fail,    //WX登录失败
}StaticShareEventType;

//路径分享相关事件统计
typedef enum {
    StaticSharePathViewEventType_Show = 0,      //页面展示
    StaticSharePathViewEventType_QQ,            //QQ分享
    StaticSharePathViewEventType_WX,            //WX分享
    StaticSharePathViewEventType_MESSAGE,       //短信分享
    StaticSharePathViewEventType_TOTAL,         //一键发送
    StaticSharePathViewEventType_CANCEL,        //分享取消
}StaticSharePathViewEventType;

//路径分享相关事件统计
typedef enum {
    StaticQuickCancelEventType_Show = 0,      //页面展示
    StaticQuickCancelEventType_Cancel,            //QQ分享
    StaticQuickCancelEventType_Request,            //WX分享
    StaticQuickCancelEventType_Request_Success,       //短信分享
}StaticQuickCancelEventType;


//应用事件统计
typedef enum {
    StaticApplicationEventType_Start = 0,  //应用主动启动
    StaticApplicationEventType_URLOpen_QQ,    //QQ跳转回应用
    StaticApplicationEventType_URLOpen_WX,    //WX跳转回应用
    StaticApplicationEventType_ResignActive,    //应用进入后台
    StaticApplicationEventType_EnterForground,  //应用进入前台
}StaticApplicationEventType;


//预警启动事件次数统计
typedef enum {
//    StaticPaPaWarningStartType_Timing = 0,        //倒计时启动
    StaticPaPaWarningStartType_Timing_Success = 0,  //倒计时启动成功
    StaticPaPaWarningStartType_Timing_Fail,         //倒计时启动失败
    
    StaticPaPaWarningStartType_Quick_Success,       //应急模式启动成功
    StaticPaPaWarningStartType_Quick_Fail,          //应急模式启动失败
}StaticPaPaWarningStartType;

//倒计时界面事件次数统计
typedef enum {
    StaticPaPaTimingEventType_Safe = 0,     //安全按钮点击
    StaticPaPaTimingEventType_Help,         //需要帮助点击
    StaticPaPaTimingEventType_Show,         //展示次数
}StaticPaPaTimingEventType;

//倒计时界面时间设定事件次数统计
typedef enum {
    StaticPaPaTimingResetTimeEventType_Start = 0,     //时间设定 启动
    StaticPaPaTimingResetTimeEventType_Confirm,       //时间设定 确认
    StaticPaPaTimingResetTimeEventType_Cancel,        //时间设定 取消
}StaticPaPaTimingResetTimeEventType;

//通讯录相关事件次数统计
typedef enum {
    StaticPaPaLocalContactsEventType_Start = 0,     //通讯录 点击
    StaticPaPaLocalContactsEventType_Confirm,       //通讯录 确认
    StaticPaPaLocalContactsEventType_Cancel,        //通讯录 取消
    
    StaticPaPaLocalContactsEventType_Show,          //通讯录 展示次数
}StaticPaPaLocalContactsEventType;


//注册相关事件次数统计
typedef enum {
    StaticPaPaRegisterEventType_Start = 0,     //引导页面的按钮点击事件
    
    StaticPaPaRegisterEventType_Login ,     //开始使用按钮事件
    StaticPaPaRegisterEventType_Next ,      //设置个人信息 下一步的按钮点击事件，可认为注册成功的用户数
    StaticPaPaRegisterEventType_Another ,      //再设一个 按钮事件
    StaticPaPaRegisterEventType_Finish ,      //完成按钮事件
    StaticPaPaRegisterEventType_AddressList ,      //通讯录按钮事件
    
    StaticPaPaRegisterEventType_Login_Success ,     //开始使用按钮事件
    StaticPaPaRegisterEventType_Next_Success ,      //设置个人信息 下一步的按钮点击事件，可认为注册成功的用户数
    StaticPaPaRegisterEventType_Another_Success ,      //再设一个 按钮事件
    StaticPaPaRegisterEventType_Finish_Success ,      //完成按钮事件
    StaticPaPaRegisterEventType_AddressList_Success ,      //通讯录按钮事件
 
}StaticPaPaRegisterEventType;

//watch手表相关事件次数统计
typedef enum {
    StaticPaPaWKWarningEventType_StartTimer = 0,     //启动倒计时事件
    
    StaticPaPaWKWarningEventType_WarningTimer ,     //需要援助事件
    StaticPaPaWKWarningEventType_QuickWarning ,     //紧急援助事件
    StaticPaPaWKWarningEventType_Cancel             //输入正确密码取消预警
}StaticPaPaWKWarningEventType;

//watch手表用户数统计
typedef enum {
    StaticPaPaWKApplicationStartEventType_Start = 0,     //启动倒计时事件

}StaticPaPaWKApplicationStartEventType;

typedef enum {
    StaticPaPaDoMenuEventType_Start = 0,        //启动倒计时事件
    StaticPaPaDoMenuEventType_Finish              //自定义
    
}StaticPaPaDoMenuEventType;

typedef enum {
    StaticPaPaSharePathEventType_Start = 0,     //启动倒计时事件
    StaticPaPaSharePathEventType_ShowShare,     //页面内分享按钮
    StaticPaPaSharePathEventType_TapedShare     //分享种类选择
}StaticPaPaSharePathEventType;

@interface KMStatis : NSObject

//页面统计
+(void)staticStartLogPageViewWithPageType:(StaticControllerPageViewType)type;
+(void)staticEndLogPageViewWithPageType:(StaticControllerPageViewType)type;

+(void)staticStartLogPageViewWithPageTitle:(NSString *)name;
+(void)staticEndLogPageViewWithPageTitle:(NSString *)name;


+(void)staticShareEvent:(StaticShareEventType)type andNoticeStr:(NSString *)str;
+(void)staticApplicationEvent:(StaticApplicationEventType)type;


+(void)staticWarningStartEvent:(StaticPaPaWarningStartType)type;
+(void)staticWarningStartEvent:(StaticPaPaWarningStartType)type andTimeLength:(NSString *)length;

+(void)staticTimingViewEvent:(StaticPaPaTimingEventType)type;
+(void)staticResetTimeEvent:(StaticPaPaTimingResetTimeEventType)type;
+(void)staticLocalContactsEvent:(StaticPaPaLocalContactsEventType)type;


+(void)staticRegisterEvent:(StaticPaPaRegisterEventType)type;
+(void)staticWKWarningStaticEvent:(StaticPaPaWKWarningEventType)type;
+(void)staticWKApplicationStartEvent:(StaticPaPaWKApplicationStartEventType)type;

//使用打点统计、统计controller、init方法
+(void)staticApplicationVCinitWithVCClassDes:(NSString *)des;

+(void)staticApplicationWillResignActiveForVCClassDes:(NSString *)des;
+(void)staticApplicationDidBecomeActiveVCClassDes:(NSString *)des;


+(void)staticSharePathStaticEvent:(StaticPaPaSharePathEventType)type;
+(void)staticDoMenuStartEvent:(StaticPaPaDoMenuEventType)type andText:(NSString *)txt;

+(void)staticSharePathViewEvent:(StaticSharePathViewEventType)type;
+(void)staticQuickCancelViewEvent:(StaticQuickCancelEventType)type;

@end
