//
//  CBGPlanCheckSpecialListVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/4/28.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanCheckSpecialListVC.h"
#import "ZALocationLocalModel.h"

@interface CBGPlanCheckSpecialListVC ()
@property (nonatomic, strong) NSArray * preArr;
@end

@implementation CBGPlanCheckSpecialListVC

- (void)viewDidLoad {
    self.viewTtle = @"急速售出";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortStyle = CBGStaticSortShowStyle_School;
    self.orderStyle = CBGStaticOrderShowStyle_Space;
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * soldArr = [dbManager localSaveEquipHistoryModelListTotalWithSoldOut];
    NSMutableArray * showArr = [NSMutableArray array];
    for (NSInteger index = 0 ; index < [soldArr count];index ++ )
    {
        CBGListModel * eveList = [soldArr objectAtIndex:index];
        if(eveList.sell_space < MINUTE * 3 && eveList.sell_space > 0){
            [showArr addObject:eveList];
        }
    }
    
    self.dbHistoryArr = showArr;
    
    [self refreshLatestShowedDBArrayWithNotice:NO];
}
-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice
{
    if(!self.dbHistoryArr) return;
    
    self.preArr = [NSArray arrayWithArray:self.dbHistoryArr];
    [self refreshLatestShowTableView];
}
-(NSArray *)moreFunctionsForDetailSubVC
{
    NSMutableArray * arr = [NSMutableArray array];
    MSAlertAction * action = nil;
    __weak typeof(self) weakSelf = self;
    
    
    action = [MSAlertAction actionWithTitle:@"数据导出" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf outLatestShowDetailDBCSVFile];
              }];
    
    [arr addObject:action];
    
    action = [MSAlertAction actionWithTitle:@"价格筛选" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf selectDBHistoryWithLatestPriceLine];
              }];
    
    [arr addObject:action];
    
    return arr;
}
-(void)selectDBHistoryWithLatestPriceLine
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * soldArr = [dbManager localSaveEquipHistoryModelListTotalWithSoldOut];
    NSMutableArray * showArr = [NSMutableArray array];
    for (NSInteger index = 0 ; index < [soldArr count];index ++ )
    {
        CBGListModel * eveList = [soldArr objectAtIndex:index];
        if(eveList.sell_space < MINUTE * 3 && eveList.sell_space > 0 && eveList.equip_price/100 > self.startLinePrice){
            [showArr addObject:eveList];
        }
    }
    
    self.dbHistoryArr = showArr;
    [self refreshLatestShowedDBArrayWithNotice:NO];

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
