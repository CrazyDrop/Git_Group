//
//  CBGStatisticsDetailHistoryVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGStatisticsDetailHistoryVC.h"

@interface CBGStatisticsDetailHistoryVC ()

@end

@implementation CBGStatisticsDetailHistoryVC

-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice
{
    NSString * title = [NSString stringWithFormat:@"统计(%@)",self.selectedDate];
    self.titleV.text = title;
    [self selectDBHistoryListWithDataSelectedStyle:YES withNotice:notice];
}

- (void)viewDidLoad {
    self.viewTtle = @"统计历史";
    self.rightTitle = @"筛选";
    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    [self selectDBHistoryListWithDataSelectedStyle:YES];
}
-(void)selectDBHistoryListWithDataSelectedStyle:(BOOL)finish withNotice:(BOOL)notice
{
    NSArray * sortArr = [NSArray arrayWithArray:self.dbHistoryArr];
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //视已取回和售出一样
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if(finish && [eveModel.sell_create_time hasPrefix:self.selectedDate]){
            [resultArr addObject:eveModel];
        }else if(!finish && ([eveModel.sell_sold_time hasPrefix:self.selectedDate] || [eveModel.sell_back_time hasPrefix:self.selectedDate])){
            [resultArr addObject:eveModel];
        }
    }
    
//    if(notice)
//    {
//        NSString * noticeStr = [NSString stringWithFormat:@"%lu",[resultArr count]];
//        [DZUtils noticeCustomerWithShowText:noticeStr];
//    }
    [self refreshNumberLblWithLatestNum:[resultArr count]];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = resultArr;
        [self.listTable reloadData];
    });
}


//筛选被选中的时间
-(void)selectDBHistoryListWithDataSelectedStyle:(BOOL)finish
{
    [self selectDBHistoryListWithDataSelectedStyle:finish withNotice:YES];
}

//结束与否筛选
-(void)detailSortSelectedForLatestShowHistoryListWithFinish:(BOOL)finish
{
    NSArray * sortArr = [NSArray arrayWithArray:self.dataArr];
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //筛选有结束时间的
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if(finish && ([eveModel.sell_sold_time length]>0 || [eveModel.sell_back_time length] > 0))
        {
            [resultArr addObject:eveModel];
        }else if(!finish && ([eveModel.sell_sold_time length]==0 && [eveModel.sell_back_time length] == 0)){
            [resultArr addObject:eveModel];
        }
    }
    
//    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[resultArr count]];
//    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    [self refreshNumberLblWithLatestNum:[resultArr count]];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = resultArr;
        [self.listTable reloadData];
    });

}


-(void)showDetailChooseForHistory
{//纵横两个维度看
    //    1、通过进入数据，控制数据的相关程度
    //    2、估价情况  1、有利  2、值得  3、不值  4、全部
    //    3、列表筛选  筛选  已售出  未售出 全部
    NSString * log = [NSString stringWithFormat:@"对统计数据如何处理？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = nil;
    
    if(self.exchangeDelegate)
    {
        action =[MSAlertAction actionWithTitle:@"切换估价历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                 {
                     if(weakSelf.exchangeDelegate && [weakSelf.exchangeDelegate respondsToSelector:@selector(historyHandelExchangeHistoryShowWithPlanShow:)]){
                         [weakSelf.exchangeDelegate historyHandelExchangeHistoryShowWithPlanShow:YES];
                     }
                 }];
        [alertController addAction:action];
    }
    
    action = [MSAlertAction actionWithTitle:@"全部相关" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  NSArray * arr = [NSArray arrayWithArray:weakSelf.dbHistoryArr];
                  
//                  NSString * noticeStr = [NSString stringWithFormat:@"%lu",[arr count]];
//                  [DZUtils noticeCustomerWithShowText:noticeStr];
                  [weakSelf refreshNumberLblWithLatestNum:[arr count]];
                  
                  weakSelf.dataArr = arr;
                  [weakSelf.listTable reloadData];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"仅起售时间" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf selectDBHistoryListWithDataSelectedStyle:NO];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"仅结束时间" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf selectDBHistoryListWithDataSelectedStyle:YES];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"筛选已结束" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf detailSortSelectedForLatestShowHistoryListWithFinish:YES];
              }];
    
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"筛选未结束" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf detailSortSelectedForLatestShowHistoryListWithFinish:NO];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"WEB刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLatestDetailListRequestForShowedCBGListArr:weakSelf.dataArr];
              }];
    [alertController addAction:action];
    
    
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

-(void)finishDetailListRequestWithFinishedCBGListArray:(NSArray *)array
{
    self.dataArr = array;
    [self.listTable reloadData];
}


-(void)submit
{
    //    [self showDialogForNoContactsError];
    [self showDetailChooseForHistory];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
