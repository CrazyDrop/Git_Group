//
//  ZWSortListController.h
//  ZAIOSMainPrj
//
//  Created by Apple on 16/4/26.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"

@interface ZWSortListController : DPWhiteTopController
@property (nonatomic,copy) NSArray * sortArr;
@property (nonatomic,strong,readonly) UITableView * listTable;


@end
