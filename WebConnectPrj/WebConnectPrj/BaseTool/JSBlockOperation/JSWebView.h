//
//  JSWebView.h
//  WebConnectPrj
//
//  Created by Apple on 14-11-20.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>

//实现读取图片地址功能
@interface JSWebView : UIWebView

-(void)loadWebHtml:(NSString *)str;

@property (nonatomic,strong) void(^endJSOperationBlcok)(NSArray *arr);


@end
