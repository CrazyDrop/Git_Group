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
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithSoldOut];
    
    NSMutableArray * showArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        NSInteger space = eveModel.sell_space;
        //30分钟内售出
        if(space > 0 && space < 30 * MINUTE){
            [showArr addObject:eveModel];
        }
    }
    
    
    [showArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CBGListModel * eve1 = (CBGListModel *)obj1;
        CBGListModel * eve2 = (CBGListModel *)obj2;
        
        NSComparisonResult result = NSOrderedSame;
        //结束时间
        result = [[NSNumber numberWithInteger:eve1.sell_space] compare:[NSNumber numberWithInteger:eve2.sell_space]];
        
        return result;
    }];

    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[showArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = showArr;
        [self.listTable reloadData];
    });;
}


-(void)refreshLatestDatabaseListDataForUnFinished
{
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithUnFinished];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
}
-(void)refreshLatestDatabaseListDataForPriceError
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListEquipPriceError];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });
}
-(void)refreshLatestDatabaseListDataForEarnPriceIsNull
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithPlanFail];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
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
    
    action = [MSAlertAction actionWithTitle:@"估价失败列表" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForEarnPriceIsNull];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"未完成列表" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForUnFinished];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"抢购列表" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForQuickSold];
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

-(void)showTotalHistorySortListWithPlayStyle:(BOOL)plan
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * dbArr = [dbManager localSaveEquipHistoryModelListTotal];
    if(plan)
    {
        CBGPlanSortHistoryVC * plan = [[CBGPlanSortHistoryVC alloc] init];
        plan.dbHistoryArr = dbArr;
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
        
        [[self rootNavigationController] pushViewController:plan animated:YES];

    }
}

-(void)submit
{
    //    [self showDialogForNoContactsError];
    [self showDetailChooseForHistory];
}

- (void)viewDidLoad {
    self.viewTtle = @"全部历史";
    self.rightTitle = @"筛选";
    self.showRightBtn = YES;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
