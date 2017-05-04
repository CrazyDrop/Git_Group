//
//  CBGPlanSortHistoryVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseStyleVC.h"
#import "CBGCombinedHistoryHandleVC.h"

//完成 估价历史功能，估价历史相关功能
//估价历史  对应功能
//主要看估价相关数据
@interface CBGPlanSortHistoryVC : CBGSortHistoryBaseStyleVC

//数据仅创建时进行复制，后续变动不会自动响应，需重新调用刷新方法
@property (nonatomic, assign) id<CBGHistoryExchangeDelegate> exchangeDelegate;
@property (nonatomic, strong) NSString * selectedDate;

-(void)selectHistoryForPlanStartedLoad;
-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice;

@end
