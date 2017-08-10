//
//  ZWRefreshListController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/7.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWBaseRefreshShowListVC.h"


//监控最新的列表数据，以获得最新数据为主
@interface ZWRefreshListController : ZWBaseRefreshShowListVC
//10页或3页，均为并发执行

//开启仅进行列表数据请求，筛选，且进行库表存储(等后续补全)
//不进行字符串详细解析，和后台时长无关
@property (nonatomic,assign) BOOL onlyList;

//屏蔽提醒
@property (nonatomic,assign) BOOL ingoreDB;

@property (nonatomic,assign) BOOL maxRefresh;


@end
