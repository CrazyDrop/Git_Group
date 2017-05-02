//
//  CBGLatestDetailCheckVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/2.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGLatestDetailCheckVC.h"
#import "ZALocationLocalModel.h"
@interface CBGLatestDetailCheckVC ()

@end

@implementation CBGLatestDetailCheckVC

- (void)viewDidLoad {
    self.viewTtle = @"当前检查";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortStyle = CBGStaticSortShowStyle_None;
    self.orderStyle = CBGStaticOrderShowStyle_Create;
    
    NSArray * orderSnArr = @[
                             @"1154_1489910891_1156558427",
                             @"466_1493617902_466887482",
                             @"127_1490595127_128505053",
                             @"50_1488193982_51609202",
                             @"29_1487560861_30654989",
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
//        if([subArr count] > 0 )
//        {
//            CBGListModel * eveList = [subArr firstObject];
//            NSArray * roleArr = [dbManager localSaveEquipHistoryModelListForRoleId:eveList.owner_roleid];
//            [result addObjectsFromArray:roleArr];
//        }
        [result addObjectsFromArray:subArr];
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
