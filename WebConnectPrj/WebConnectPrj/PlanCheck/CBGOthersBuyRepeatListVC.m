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
    self.dbHistoryArr = [dbManager localSaveEquipHistoryModelListRepeatSold];
//    self.selectedDate = @"2017";
    [self refreshLatestShowedDBArrayWithNotice:YES];

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
