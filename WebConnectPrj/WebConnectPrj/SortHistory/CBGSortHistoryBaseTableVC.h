//
//  CBGSortHistoryBaseTableVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/4/24.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
//基础table VC，进行基础列表展示
//进行数据展示基础控制   列表分组展示，列表全部展示(不进行具体排序)
//数据展示，统一基类
@interface CBGSortHistoryBaseTableVC : DPWhiteTopController


//基础数据传递
@property (nonatomic,strong) NSArray * dbHistoryArr;
@property (nonatomic,strong,readonly) UITableView * listTable;

//数据刷新
@property (nonatomic, strong)   NSArray * showSortArr;
@property (nonatomic, strong)   NSArray * showTagArr;

-(NSArray *)latestTotalShowedHistoryList;


@end

//UIDocumentInteractionController * documentController;
