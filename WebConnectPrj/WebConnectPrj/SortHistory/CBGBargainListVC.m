//
//  CBGBargainListVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/6.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGBargainListVC.h"
#import "ZALocationLocalModel.h"
@interface CBGBargainListVC ()

@end

@implementation CBGBargainListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.viewTtle = @"还价列表";
    self.rightTitle = @"刷新";
    self.showRightBtn = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.orderStyle = CBGStaticOrderShowStyle_Create;
    self.sortStyle = CBGStaticSortShowStyle_Rate;
    
    
    NSString * todayDate = [NSDate unixDate];
    if(todayDate)
    {
        todayDate = [todayDate substringToIndex:[@"2017" length]];
    }
    
    //    列表选择时，从当前列表选取
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * dbArray = [manager localSaveEquipHistoryModelListForTime:todayDate];
    self.dbHistoryArr = dbArray;
    
    //展示售出  有利
    [self selectHistoryForPlanStartedLoad];
}

-(void)finishDetailListRequestWithFinishedCBGListArray:(NSArray *)array
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self selectHistoryForPlanStartedLoad];
    });
}

-(void)finishDetailListRequestWithErrorCBGListArray:(NSArray *)array
{
    for(NSInteger index = 0 ;index < [array count]; index ++)
    {
        CBGListModel * list = [array objectAtIndex:index];
        NSLog(@"%ld %@",list.server_id,list.detailWebUrl);
    }
}



-(void)submit
{
    NSArray * list = [self latestTotalShowedHistoryList];
    [self startLatestDetailListRequestForShowedCBGListArr:list];
}



-(void)selectHistoryForPlanStartedLoad
{
    NSArray * sortArr = [NSArray arrayWithArray:self.dbHistoryArr];
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //视已取回和售出一样
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if(eveModel.equip_accept && eveModel.plan_total_price > (eveModel.equip_price/100.0 * 0.7) && eveModel.plan_total_price > 12000 && eveModel.server_check == 1)
        {
            [resultArr addObject:eveModel];
        }
    }
    
    self.dbHistoryArr = resultArr;
    self.finishStyle = CBGSortShowFinishStyle_UnFinish;
    [self refreshLatestShowTableView];
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
