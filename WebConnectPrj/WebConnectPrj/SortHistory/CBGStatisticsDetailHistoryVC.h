//
//  CBGStatisticsDetailHistoryVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseDetailVC.h"
#import "CBGCombinedHistoryHandleVC.h"

//统计历史  对应功能  大范围数据划分展示列表
//对应的统计列表的历史功能
typedef enum : NSUInteger {
    CBGStaticSortShowStyle_None = 0,
    CBGStaticSortShowStyle_School,  //门派 分组，价格排序
    CBGStaticSortShowStyle_Rate,    //利差 分组，价格排序
    CBGStaticSortShowStyle_Space,   //门派 分组，售出时间差排序
} CBGStaticSortShowStyle;

@interface CBGStatisticsDetailHistoryVC : CBGSortHistoryBaseDetailVC
//重新界面刷新

//数据仅创建时进行复制，后续变动不会自动响应，需重新调用刷新方法
@property (nonatomic, assign) id<CBGHistoryExchangeDelegate> exchangeDelegate;
@property (nonatomic, strong) NSString * selectedDate;
-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice;


@end
