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
typedef enum : NSUInteger {
    CBGCombinedHandleVCStyle_Plan = 0,
    CBGCombinedHandleVCStyle_Statist,
    CBGCombinedHandleVCStyle_Study,
} CBGCombinedHandleVCStyle;

@class CBGCombinedHistoryHandleVC;
@protocol CBGHistoryExchangeDelegate <NSObject>

-(void)historyHandelExchangeHistoryShowWithPlanShow:(CBGCombinedHandleVCStyle)style;

@end

@interface CBGCombinedHistoryHandleVC : CBGSortHistoryBaseDetailVC

@property (nonatomic, assign) CBGCombinedHandleVCStyle showStyle;
@property (nonatomic, strong) NSString * selectedDate;

//传入内涵参数无效，使用showStyle为准
-(void)refreshCombinedHistoryListWithShowStyle:(CBGCombinedHandleVCStyle)style;

@end
