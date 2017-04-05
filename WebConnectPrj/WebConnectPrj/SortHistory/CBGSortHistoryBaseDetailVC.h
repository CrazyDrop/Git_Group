//
//  CBGSortHistoryBaseDetailVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
#import "MSAlertController.h"
#import "CBGListModel.h"
#import "EquipDetailArrayRequestModel.h"
//完成网络请求，列表详情请求

@interface CBGSortHistoryBaseDetailVC : DPWhiteTopController
{
    EquipDetailArrayRequestModel * _detailModel;
}
//基础数据传递
@property (nonatomic,strong) NSArray * dbHistoryArr;

//创建基础table，不进行数据填充
@property (nonatomic,strong) NSArray * dataArr;
@property (nonatomic,strong,readonly) UITableView * listTable;

-(void)refreshNumberLblWithLatestNum:(NSInteger)number;

//封装统一的网络请求，触发，结束
//中断处理
-(void)startLatestDetailListRequestForShowedCBGListArr:(NSArray *)array;

-(void)finishDetailListRequestWithFinishedCBGListArray:(NSArray *)array;
-(void)finishDetailListRequestWithErrorCBGListArray:(NSArray *)array;



@end
