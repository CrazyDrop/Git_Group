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
#import "CBGDepthStudyVC.h"
#import "ZALocationLocalModel.h"
@interface CBGCombinedHistoryHandleVC ()<CBGHistoryExchangeDelegate>
@property (nonatomic, strong) CBGStatisticsDetailHistoryVC * staticHistory;
@property (nonatomic, strong) CBGPlanSortHistoryVC * planHistory;
@property (nonatomic, strong) CBGDepthStudyVC * deepStudy;
@end

@implementation CBGCombinedHistoryHandleVC

-(void)refreshCombinedHistoryListWithShowStyle:(CBGCombinedHandleVCStyle)style
{
    style = self.showStyle;
    
    //隐藏其他全部
    _planHistory.view.hidden = YES;
    _staticHistory.view.hidden = YES;
    _deepStudy.view.hidden = YES;
    
    //选出当前对应vc，不存在则创建
    NSString * dateStr = self.selectedDate;
    NSArray * dbArray = [self localDBHistoryArrayFromSelectedDate:dateStr];
    
    switch (style) {
        case CBGCombinedHandleVCStyle_Plan:
        {
            CBGPlanSortHistoryVC * plan = self.planHistory;
            plan.dbHistoryArr = dbArray;
            plan.selectedDate = dateStr;
            [plan refreshLatestShowedDBArrayWithNotice:NO];
            plan.view.hidden = NO;
        }
            break;
        case CBGCombinedHandleVCStyle_Statist:
        {
            CBGStatisticsDetailHistoryVC * plan = self.staticHistory;
            plan.dbHistoryArr = dbArray;
            plan.selectedDate = dateStr;
            [plan refreshLatestShowedDBArrayWithNotice:NO];
            plan.view.hidden = NO;
        }
            break;
        case CBGCombinedHandleVCStyle_Study:
        {
            //进行数组筛选，筛选起始时间对应的数据
            NSMutableArray * startArr = [NSMutableArray array];
            for (NSInteger index = 0; index < [dbArray count]; index ++) {
                CBGListModel * eve = [dbArray objectAtIndex:index];
                if([eve.sell_create_time hasPrefix:dateStr])
                {
                    [startArr addObject:eve];
                }
            }
            
            CBGDepthStudyVC * plan = self.deepStudy;
            plan.dbHistoryArr = startArr;
            plan.selectedDate = dateStr;
            [plan refreshLatestShowedDBArrayWithNotice:NO];
            plan.view.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UIView * bgView = self.view;
    [self refreshCombinedHistoryListWithShowStyle:self.showStyle];
    
}


-(void)historyHandelExchangeHistoryShowWithPlanShow:(CBGCombinedHandleVCStyle)style
{
    self.showStyle = style;
    [self refreshCombinedHistoryListWithShowStyle:style];
}
-(NSArray *)localDBHistoryArrayFromSelectedDate:(NSString *)dateStr
{
    if(self.dbHistoryArr)
    {
        return self.dbHistoryArr;
    }
    
    if(!dateStr) return nil;
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListForTime:dateStr];
    return sortArr;
}


-(CBGStatisticsDetailHistoryVC *)staticHistory
{
    if(!_staticHistory){
        CBGStatisticsDetailHistoryVC * his = [[CBGStatisticsDetailHistoryVC alloc] init];
//        his.dbHistoryArr = [self localDBHistoryArrayFromSelectedDate:self.selectedDate];
//        his.selectedDate = self.selectedDate;
        his.exchangeDelegate = self;
        [self addChildViewController:his];
        [self.view addSubview:his.view];
        _staticHistory = his;
    }
    return _staticHistory;
}

-(CBGPlanSortHistoryVC *)planHistory
{
    if(!_planHistory){
        CBGPlanSortHistoryVC * his = [[CBGPlanSortHistoryVC alloc] init];
        his.exchangeDelegate = self;
//        his.dbHistoryArr = [self localDBHistoryArrayFromSelectedDate:self.selectedDate];
//        his.selectedDate = self.selectedDate;
        [self addChildViewController:his];
        [self.view addSubview:his.view];
        _planHistory = his;
    }
    return _planHistory;
}

-(CBGDepthStudyVC *)deepStudy
{
    if(!_deepStudy){
        CBGDepthStudyVC * his = [[CBGDepthStudyVC alloc] init];
        his.exchangeDelegate = self;
//        his.dbHistoryArr = [self localDBHistoryArrayFromSelectedDate:self.selectedDate];
//        his.selectedDate = self.selectedDate;
        [self addChildViewController:his];
        [self.view addSubview:his.view];
        _deepStudy = his;
    }
    return _deepStudy;
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
