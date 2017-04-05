//
//  CBGCombinedHistoryHandleVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGCombinedHistoryHandleVC.h"
#import "CBGStatisticsDetailHistoryVC.h"
#import "CBGPlanSortHistoryVC.h"
#import "ZALocationLocalModel.h"
@interface CBGCombinedHistoryHandleVC ()<CBGHistoryExchangeDelegate>
@property (nonatomic, strong) CBGStatisticsDetailHistoryVC * staticHistory;
@property (nonatomic, strong) CBGPlanSortHistoryVC * planHistory;
@end

@implementation CBGCombinedHistoryHandleVC

-(void)setSelectedDate:(NSString *)selectedDate
{
    _selectedDate = selectedDate;
    
    //后续刷新使用
//    [self refreshCombinedHistoryList];
}
-(void)refreshCombinedHistoryListWithTips:(BOOL)showTip
{
    [self refreshCombineHistoryWithPlanShow:self.showPlan];
    
    NSString * dateStr = self.selectedDate;
    NSArray * dbArray = [self localDBHistoryArrayFromSelectedDate:dateStr];
    
    self.staticHistory.selectedDate = dateStr;
    self.staticHistory.dbHistoryArr = dbArray;
    
    self.planHistory.selectedDate = dateStr;
    self.planHistory.dbHistoryArr = dbArray;
    
    if(self.showPlan){
        [self.planHistory refreshLatestShowedDBArrayWithNotice:showTip];
    }else{
        [self.staticHistory refreshLatestShowedDBArrayWithNotice:showTip];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * bgView = self.view;
    [bgView addSubview:self.staticHistory.view];
    [bgView addSubview:self.planHistory.view];
    
    [self refreshCombineHistoryWithPlanShow:self.showPlan];
    
}
-(void)refreshCombineHistoryWithPlanShow:(BOOL)show
{
    self.staticHistory.view.hidden = show;
    self.planHistory.view.hidden = !show;
    
}

-(void)historyHandelExchangeHistoryShowWithPlanShow:(BOOL)show
{
    [self refreshCombineHistoryWithPlanShow:show];
    
    if(show){
        [self.planHistory refreshLatestShowedDBArrayWithNotice:YES];
    }else{
        [self.staticHistory refreshLatestShowedDBArrayWithNotice:YES];
    }
}
-(NSArray *)localDBHistoryArrayFromSelectedDate:(NSString *)dateStr
{
    if(!dateStr) return nil;
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListForTime:dateStr];
    return sortArr;
}


-(CBGStatisticsDetailHistoryVC *)staticHistory
{
    if(!_staticHistory){
        CBGStatisticsDetailHistoryVC * his = [[CBGStatisticsDetailHistoryVC alloc] init];
        his.dbHistoryArr = [self localDBHistoryArrayFromSelectedDate:self.selectedDate];
        his.selectedDate = self.selectedDate;
        his.exchangeDelegate = self;
        [self addChildViewController:his];
        _staticHistory = his;
    }
    return _staticHistory;
}

-(CBGPlanSortHistoryVC *)planHistory
{
    if(!_planHistory){
        CBGPlanSortHistoryVC * his = [[CBGPlanSortHistoryVC alloc] init];
        his.dbHistoryArr = [self localDBHistoryArrayFromSelectedDate:self.selectedDate];
        his.exchangeDelegate = self;
        his.selectedDate = self.selectedDate;
        [self addChildViewController:his];
        _planHistory = his;
    }
    return _planHistory;
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
