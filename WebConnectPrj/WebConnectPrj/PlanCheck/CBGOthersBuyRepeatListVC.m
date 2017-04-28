//
//  CBGOthersBuyRepeatListVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGOthersBuyRepeatListVC.h"
#import "ZALocationLocalModel.h"
@interface CBGOthersBuyRepeatListVC ()

@end

@implementation CBGOthersBuyRepeatListVC

- (void)viewDidLoad {
    self.viewTtle = @"倒卖记录";
    self.showRightBtn = YES;
    self.rightTitle = @"筛选";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    self.dbHistoryArr = [dbManager localSaveEquipHistoryModelListRepeatSoldTimesMore:NO];
//    self.selectedDate = @"2017";
    [self refreshLatestShowedDBArrayWithNotice:YES];

}

-(void)refreshLocalDbWithMoreRepeat
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    self.dbHistoryArr = [dbManager localSaveEquipHistoryModelListRepeatSoldTimesMore:YES];
    [self refreshLatestShowTableView];
}


-(NSArray *)moreFunctionsForDetailSubVC
{
    NSMutableArray * arr = [NSMutableArray array];
    MSAlertAction * action = nil;
    __weak typeof(self) weakSelf = self;
    
    
    action = [MSAlertAction actionWithTitle:@"时差排序" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.orderStyle = CBGStaticSortShowStyle_Space;
                  [weakSelf refreshLatestShowTableView];
              }];
    [arr addObject:action];
    
    //刷新数据
    action = [MSAlertAction actionWithTitle:@"重复3次" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLocalDbWithMoreRepeat];
              }];
    [arr addObject:action];


    return arr;
    return nil;
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
