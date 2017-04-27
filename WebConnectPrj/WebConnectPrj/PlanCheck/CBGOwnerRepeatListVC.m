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
    
    self.sortStyle = CBGStaticSortShowStyle_None;
    self.orderStyle = CBGStaticOrderShowStyle_Create;
    
    NSArray * orderSnArr = @[
                          @"360_1487831304_361866251",
                          @"569_1491211672_570965016",
                          @"29_1491747748_30739765",
                          @"397_1491209246_398905319",
                          @"120_1491579089_121385506",
                          @"427_1491832600_428256893",
                          @"1249_1492038151_1249534037",
                          @"1112_1492225701_1114365136",
                          @"427_1492253794_428263268",
                          @"330_1492327843_331514508",
                          @"1235_1492744669_1236925322",
                          @"438_1492921083_439120347",
                          @"95_1492076146_95858756",
                          @"29_1493220900_30769142",
                          @""];
    
    
    
    NSArray * listArr = [self localSaveListArrayFromOrderSNArray:orderSnArr];
    self.dbHistoryArr = listArr;
    [self refreshLatestShowedDBArrayWithNotice:YES];
}
-(NSArray *)localSaveListArrayFromOrderSNArray:(NSArray *)arr
{
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSMutableArray * result = [NSMutableArray  array];
    for (NSInteger index = 0; index < [arr count]; index++)
    {
        NSString * eveSn = [arr objectAtIndex:index];
        NSArray * subArr = [dbManager localSaveEquipHistoryModelListForOrderSN:eveSn];
        if([subArr count] > 0 )
        {
            CBGListModel * eveList = [subArr firstObject];
            NSArray * roleArr = [dbManager localSaveEquipHistoryModelListForRoleId:eveList.owner_roleid];
            [result addObjectsFromArray:roleArr];
        }
    }
    return result;
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
