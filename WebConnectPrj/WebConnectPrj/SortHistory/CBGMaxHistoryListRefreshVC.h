//
//  CBGMaxHistoryListRefreshVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/4/3.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseDetailVC.h"
//最大的网络数据请求，解决功能类内部，全库表数据刷新的中断问题
//自动进行数据请求
@interface CBGMaxHistoryListRefreshVC : CBGSortHistoryBaseDetailVC

@property (nonatomic, strong) NSArray * startArr;




@end
