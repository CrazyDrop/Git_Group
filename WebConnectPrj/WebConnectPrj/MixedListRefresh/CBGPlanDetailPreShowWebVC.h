//
//  CBGPlanDetailPreShowWebVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/4/7.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZACBGDetailWebVC.h"
//单利vc，处理 推荐购买的视图展示
//包含webview，当时使用时，进行视图替换
@interface CBGPlanDetailPreShowWebVC : ZACBGDetailWebVC

@property (nonatomic, strong) UIWebView * planWebView;


@end
