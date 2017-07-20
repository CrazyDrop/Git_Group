//
//  ZWAutoRefreshListController.h
//  WebConnectPrj
//
//  Created by Apple on 2017/7/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"

@interface ZWAutoRefreshListController : DPWhiteTopController
@property (nonatomic,assign) BOOL onlyList;

//屏蔽提醒
@property (nonatomic,assign) BOOL ingoreDB;

@property (nonatomic,assign) BOOL maxRefresh;

@end
