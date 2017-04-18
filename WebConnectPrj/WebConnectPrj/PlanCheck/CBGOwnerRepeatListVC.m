//
//  CBGOwnerRepeatListVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGOwnerRepeatListVC.h"
#import "ZALocationLocalModel.h"
@interface CBGOwnerRepeatListVC ()

@end

@implementation CBGOwnerRepeatListVC

- (void)viewDidLoad {
    self.viewTtle = @"自有记录";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    self.dbHistoryArr = [dbManager localSaveEquipHistoryModelListOwnerList];
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
