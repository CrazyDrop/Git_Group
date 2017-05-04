//
//  ZACBGListDetailShowVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/3/21.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
#import "CBGSortHistoryBaseStyleVC.h"

@interface ZACBGListDetailShowVC : CBGSortHistoryBaseStyleVC

@property (nonatomic,assign) NSInteger selectedRoleId;
@property (nonatomic,strong) NSString * selectedOrderSN;
@property (nonatomic,copy) NSArray * dataArr;
@property (nonatomic,strong,readonly) UITableView * listTable;



@end
