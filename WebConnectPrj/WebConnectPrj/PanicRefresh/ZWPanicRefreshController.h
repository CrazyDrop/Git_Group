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
//定位，只刷新首次上架和改价
@interface ZWPanicRefreshController : ZWBaseRefreshController


@end
