//
//  ZWPanicRefreshController.h
//  WebConnectPrj
//
//  Created by Apple on 2017/5/15.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWBaseRefreshController.h"
//列表刷新，详情刷新  并列进行
//列表刷新，负责筛选最近需要加入队列的数据
//详情刷新或web页面刷新，负责刷新最近的改价信息
//需要进行价格比对，增加库表比对，以降低列表请求频次低的问题

@interface ZWPanicRefreshController : ZWBaseRefreshController

@property (nonatomic, assign) BOOL ingoreFirst;//屏蔽库表操作
@property (nonatomic, assign) NSInteger requestNum;

@end
