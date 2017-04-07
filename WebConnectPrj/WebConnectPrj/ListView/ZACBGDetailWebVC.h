//
//  ZACBGDetailWebVC.h
//  ZAIOSMainPrj
//
//  Created by Apple on 17/1/29.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"
#import "Equip_listModel.h"
#import "CBGListModel.h"
#import "CBGNearHistoryVC.h"

typedef enum : NSUInteger {
    CBGDetailWebFunction_None,
    CBGDetailWebFunction_Order,
    CBGDetailWebFunction_Cancel,
    CBGDetailWebFunction_PayOrder,
    CBGDetailWebFunction_PayInScan,
} CBGDetailWebFunction;
@interface ZACBGDetailWebVC : CBGNearHistoryVC
@property (nonatomic,strong) UIWebView * showWeb;


@end
