//
//  CBGHistoryMianListVC.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"

typedef enum : NSUInteger
{
    CBGHistoryMianFunctionStyle_None = 0,
    CBGHistoryMianFunctionStyle_PartHistory,
    CBGHistoryMianFunctionStyle_TotalHistory,
    CBGHistoryMianFunctionStyle_UpdateTotal,
    CBGHistoryMianFunctionStyle_TodayHistory,
    CBGHistoryMianFunctionStyle_MonthHistory,
    
    CBGHistoryMianFunctionStyle_LatestPlan,
    CBGHistoryMianFunctionStyle_HistoryMonthPlan,

    CBGHistoryMianFunctionStyle_RepeatHistory,
    
} CBGHistoryMianFunctionStyle;

@interface CBGHistoryMianListVC : DPWhiteTopController




@end
