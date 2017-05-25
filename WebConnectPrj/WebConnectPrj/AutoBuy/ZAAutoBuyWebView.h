//
//  ZAAutoBuyWebView.h
//  WebConnectPrj
//
//  Created by Apple on 2017/5/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBGDetailWebView.h"
//自动购买  web页面，如果多页面缓存，基础单位也是此种类型

//自动购买设置   当前金额、

typedef enum : NSUInteger {
    ZAAutoBuyStep_None,         //无操作
    ZAAutoBuyStep_Login,        //登陆
    
    ZAAutoBuyStep_TapedCollect,     //点击收藏
    ZAAutoBuyStep_CancelCollect,    //取消收藏
    
    ZAAutoBuyStep_TapedList,    //点击事件、防退出
    ZAAutoBuyStep_TapedBack,    //点击事件、返回

    ZAAutoBuyStep_MakeOrder,    //下单
    ZAAutoBuyStep_CancelOrder,  //取消下单

    ZAAutoBuyStep_PayInScan,           //扫码支付
    
    ZAAutoBuyStep_PayCBG,               //短信验证码余额支付
    ZAAutoBuyStep_PayMessage,           //短信验证码支付
    ZAAutoBuyStep_SendMessage,          //发送短信验证码
    
    ZAAutoBuyStep_IngoreRemain,      //选择不使用余额
    ZAAutoBuyStep_SelectRemain,      //选择使用余额
    
    ZAAutoBuyStep_PayPassword,       //密码支付
    ZAAutoBuyStep_EditPassword,      //填写密码
    ZAAutoBuyStep_FinishPassword,    //密码支付
    
    ZAAutoBuyStep_PayFinish,        //密码确认
    
    ZAAutoBuyStep_CBGMsgTotal,
    ZAAutoBuyStep_MessageTotal,
    ZAAutoBuyStep_PasswordTotal,
    ZAAutoBuyStep_PrepareTotal,
    
} ZAAutoBuyStep;

//希望应用内，支持多账号顺序自动购买

@interface ZAAutoBuyWebView : CBGDetailWebView

@property (nonatomic, assign) ZAAutoBuyStep autoStyle;//针对两个total的，进行全部流程顺序调用
-(void)checkAndFinishLatestJSFunction;


@end
