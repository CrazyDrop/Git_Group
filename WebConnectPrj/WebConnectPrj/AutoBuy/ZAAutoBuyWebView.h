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


typedef enum : NSUInteger {
    ZAAutoBuyStep_None,         //无操作
    ZAAutoBuyStep_Login,        //登陆
    ZAAutoBuyStep_TapedList,    //点击事件、防退出
    ZAAutoBuyStep_TapedBack,    //点击事件、返回
    ZAAutoBuyStep_MakeOrder,    //下单
    ZAAutoBuyStep_PayOrder,     //支付
    ZAAutoBuyStep_PayFinish,    //密码确认
} ZAAutoBuyStep;

@interface ZAAutoBuyWebView : CBGDetailWebView






@end
