//
//  CBGLatestPlanBuyVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/24.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGLatestPlanBuyVC.h"
#import "ZALocationLocalModel.h"
@interface CBGLatestPlanBuyVC ()

@end

@implementation CBGLatestPlanBuyVC

- (void)viewDidLoad {
    
    self.viewTtle = @"近期估价";
//    self.rightTitle = @"筛选";
//    self.showRightBtn = YES;
    
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
-(void)selectHistoryForPlanStartedLoad
{
    NSArray * sortArr = [NSArray arrayWithArray:self.dbHistoryArr];
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //视已取回和售出一样
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if(CBGEquipPlanStyle_Worth == eveModel.style ||  CBGEquipPlanStyle_PlanBuy == eveModel.style){
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
