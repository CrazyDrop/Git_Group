//
//  CBGCombinedHistoryHandleVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseDetailVC.h"
//整合后的分类处理vc，控制展示  CBGStatisticsDetailHistoryVC  CBGPlanSortHistoryVC
//进行库表查询，数据复制对应子控制器
//增加左右滑动数据

@class CBGCombinedHistoryHandleVC;
@protocol CBGHistoryExchangeDelegate <NSObject>

-(void)historyHandelExchangeHistoryShowWithPlanShow:(BOOL)show;

@end

@interface CBGCombinedHistoryHandleVC : CBGSortHistoryBaseDetailVC

@property (nonatomic, assign) BOOL showPlan;//是否展示plan界面
@property (nonatomic, strong) NSString * selectedDate;
//@property (nonatomic, strong) NSString * selectedDate;
-(void)refreshCombinedHistoryListWithTips:(BOOL)showTip;

@end
