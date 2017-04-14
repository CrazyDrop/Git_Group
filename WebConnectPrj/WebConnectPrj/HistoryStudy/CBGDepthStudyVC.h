//
//  CBGDepthStudyVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/4/13.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
#import "CBGSortHistoryBaseDetailVC.h"
#import "CBGCombinedHistoryHandleVC.h"
//数据分析展示VC
//计划，外部导入数组，时间戳   图标绘制
//数据分析，
@interface CBGDepthStudyVC : CBGSortHistoryBaseDetailVC

//需要分析的数组
@property (nonatomic, assign) id<CBGHistoryExchangeDelegate> exchangeDelegate;

//对应的相关时间
@property (nonatomic, strong) NSString * selectedDate;


-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice;



@end
