//
//  ViewController.h
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPWhiteTopController.h"

//功能分组 对应名称和功能编号，方便后续调整顺序
typedef enum : NSUInteger
{
    CBGDetailTestFunctionStyle_None = 0, 
    CBGDetailTestFunctionStyle_Notice,   
    CBGDetailTestFunctionStyle_CopyData,
    CBGDetailTestFunctionStyle_MobileMax,
    CBGDetailTestFunctionStyle_MobileMin,
    CBGDetailTestFunctionStyle_WebRefresh,
    CBGDetailTestFunctionStyle_MixedRefresh,
    CBGDetailTestFunctionStyle_HistoryTotal,
    CBGDetailTestFunctionStyle_HistoryUpdate,
    CBGDetailTestFunctionStyle_HistoryMonthPlan,
    CBGDetailTestFunctionStyle_HistoryToday,
    CBGDetailTestFunctionStyle_HistoryPart,
    CBGDetailTestFunctionStyle_URLCheck,
    CBGDetailTestFunctionStyle_WEBCheck,
    CBGDetailTestFunctionStyle_StudyMonth,
    CBGDetailTestFunctionStyle_RepeatList,
    CBGDetailTestFunctionStyle_LatestPlan,
    CBGDetailTestFunctionStyle_PayStyle,
    CBGDetailTestFunctionStyle_EditCheck,
    CBGDetailTestFunctionStyle_PanicRefresh,
    CBGDetailTestFunctionStyle_ClearCache,
    CBGDetailTestFunctionStyle_PanicMixed,
    CBGDetailTestFunctionStyle_NightMixed,
    CBGDetailTestFunctionStyle_AutoSetting,
    CBGDetailTestFunctionStyle_MaxPanic,
    CBGDetailTestFunctionStyle_SpecialList,
    CBGDetailTestFunctionStyle_BargainList,
    CBGDetailTestFunctionStyle_MobileAndUpdate,
    CBGDetailTestFunctionStyle_MobileLimit,
    CBGDetailTestFunctionStyle_MobileServer,
    CBGDetailTestFunctionStyle_MixedServer,
    CBGDetailTestFunctionStyle_EquipServer,
    CBGDetailTestFunctionStyle_EquipPage,
    CBGDetailTestFunctionStyle_MixedEquip,
    CBGDetailTestFunctionStyle_MobilePage,
    CBGDetailTestFunctionStyle_VPNList,//vpn列表
    CBGDetailTestFunctionStyle_MainHistory,
    CBGDetailTestFunctionStyle_DetailProxy,
} CBGDetailTestFunctionStyle;


@interface ViewController : DPWhiteTopController


@end

