//
//  CBGDetailWebView.h
//  WebConnectPrj
//
//  Created by Apple on 17/3/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>

//当delegate不存在时进行
//webview，通用缓存webview，用于数据展示
//能够监听消息，优先进行web页面加载
//
@interface CBGDetailWebView : UIWebView


//详情数据
@property (nonatomic, strong) NSString * detaiUrl;






@end
