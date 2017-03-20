//
//  ZWConfigListController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/11.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"

@interface ZWConfigListController : DPWhiteTopController
@property (nonatomic,copy) NSArray * dataArr;
@property (nonatomic,strong,readonly) UITableView * listTable;


@end
