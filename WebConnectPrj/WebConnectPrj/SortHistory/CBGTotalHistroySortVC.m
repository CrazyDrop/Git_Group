//
//  CBGTotalHistroySortVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGTotalHistroySortVC.h"
#import "CBGPlanSortHistoryVC.h"
#import "CBGStatisticsDetailHistoryVC.h"
#import "ZALocationLocalModel.h"
@interface CBGTotalHistroySortVC ()

@end

@implementation CBGTotalHistroySortVC

-(void)refreshLatestDatabaseListDataForQuickSold
{
    NSMutableArray * dataArr = [NSMutableArray array];
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithSoldOut];
    for (NSInteger index = 0;index < [sortArr count] ;index ++ )
    {
        CBGListModel * eveObj = [sortArr objectAtIndex:index];
        if(eveObj.sell_space > 0 && eveObj.sell_space < 10 * MINUTE)
        {
            [dataArr addObject:eveObj];
        }
    }
    self.dbHistoryArr = dataArr;
    [self refreshLatestShowTableView];
}

-(void)refreshLatestDatabaseListDataForQuickSoldWithPreUnbuy
{
    NSMutableArray * dataArr = [NSMutableArray array];
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithSoldOut];
    for (NSInteger index = 0;index < [sortArr count] ;index ++ )
    {
        CBGListModel * eveObj = [sortArr objectAtIndex:index];
        if(eveObj.sell_space > 0 && eveObj.sell_space < 3 * MINUTE && eveObj.plan_rate <= 1 )
        {
            //增加条件
//            if(eveObj.plan_zhaohuanshou_price < 300 && eveObj.plan_zhuangbei_price < 100 && eveObj.equip_price > 10000 * 100)
            {
                [dataArr addObject:eveObj];
            }
        }
    }
    self.dbHistoryArr = dataArr;
    [self refreshLatestShowTableView];
}



-(void)refreshLatestDatabaseListDataForUnFinished
{
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithUnFinished];
    
    self.dbHistoryArr = sortArr;
    [self refreshLatestShowTableView];
    
}

-(void)refreshLatestDatabaseListDataForPriceError
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListEquipPriceError];
    
    self.dbHistoryArr = sortArr;
    [self refreshLatestShowTableView];
    
}
-(void)refreshLatestDatabaseListDataForEarnPriceIsNull
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithPlanFail];
    
    self.dbHistoryArr = sortArr;
    [self refreshLatestShowTableView];
}
-(void)refreshLatestDatabaseListDataForLatestUnSell
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListEquipUnSell];
    
    self.dbHistoryArr = sortArr;
    [self refreshLatestShowTableView];
}

-(void)showDetailChooseForHistory
{
    NSString * log = [NSString stringWithFormat:@"对历史数据如何处理？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"价格异常" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf refreshLatestDatabaseListDataForPriceError];
                             }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"暂存列表" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForLatestUnSell];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"抢购列表" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForQuickSold];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"抢购非推荐" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForQuickSoldWithPreUnbuy];
              }];
    
    [alertController addAction:action];

    
    action = [MSAlertAction actionWithTitle:@"数据导出" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf outLatestShowDetailDBCSVFile];
              }];
    
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"估价历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showTotalHistorySortListWithPlayStyle:YES];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"统计历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showTotalHistorySortListWithPlayStyle:NO];
              }];
    
    [alertController addAction:action];
    
    
    action = [MSAlertAction actionWithTitle:@"WEB分段刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLatestDetailListRequestForShowedCBGListArr:[weakSelf latestTotalShowedHistoryList]];
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
    [DZUtils noticeCustomerWithShowText:@"退出重新刷新"];
    //    [self refreshLatestShowTableView];
    [[self rootNavigationController] popViewControllerAnimated:YES];
}

-(void)showTotalHistorySortListWithPlayStyle:(BOOL)plan
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * dbArr = [dbManager localSaveEquipHistoryModelListTotalWithUnFinished];
    if(plan)
    {
        CBGPlanSortHistoryVC * plan = [[CBGPlanSortHistoryVC alloc] init];
        plan.dbHistoryArr = dbArr;
        [plan refreshLatestShowedDBArrayWithNotice:NO];
        [[self rootNavigationController] pushViewController:plan animated:YES];
        
    }else{
        

        NSString * todayDate = [NSDate unixDate];
        if(todayDate)
        {
            todayDate = [todayDate substringToIndex:[@"2017" length]];
        }
        CBGStatisticsDetailHistoryVC * plan = [[CBGStatisticsDetailHistoryVC alloc] init];
        plan.dbHistoryArr = dbArr;
        plan.selectedDate = todayDate;//按年区分
        [plan refreshLatestShowedDBArrayWithNotice:NO];

        [[self rootNavigationController] pushViewController:plan animated:YES];
    }
}


-(void)submit
{
    //    [self showDialogForNoContactsError];
    [self showDetailChooseForHistory];
}

- (void)viewDidLoad {
    self.viewTtle = @"全部在售";
    self.rightTitle = @"筛选";
    self.showRightBtn = YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.orderStyle = CBGStaticOrderShowStyle_Rate;
    self.sortStyle = CBGStaticSortShowStyle_School;
    self.finishStyle = CBGSortShowFinishStyle_Total;
    
    [self refreshLatestDatabaseListDataForUnFinished];
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
