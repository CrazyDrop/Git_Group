//
//  CBGSpecialCompareListVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSpecialCompareListVC.h"
#import "ZALocationLocalModel.h"
@interface CBGSpecialCompareListVC ()

@end

@implementation CBGSpecialCompareListVC

- (void)viewDidLoad {
    self.viewTtle = @"关注列表";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortStyle = CBGStaticSortShowStyle_None;
    self.orderStyle = CBGStaticOrderShowStyle_None;
    
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * history = total.specialHistory;
    NSArray * orderSNArr = [history componentsSeparatedByString:@"|"];
    
    
    NSArray * listArr = [self localSaveListArrayFromOrderSNArray:orderSNArr];
    self.dbHistoryArr = listArr;
    [self refreshLatestShowedDBArrayWithNotice:YES];
}
-(NSArray *)localSaveListArrayFromOrderSNArray:(NSArray *)arr
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSMutableArray * result = [NSMutableArray  array];
    NSMutableArray * roleIdArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [arr count]; index++)
    {
        NSString * eveSn = [arr objectAtIndex:index];
        NSArray * subArr = [dbManager localSaveEquipHistoryModelListForOrderSN:eveSn];
        if([subArr count] > 0 )
        {
            CBGListModel * eveList = [subArr firstObject];
            [roleIdArr addObject:eveList.owner_roleid];
            
            NSArray * roleArr = [dbManager localSaveEquipHistoryModelListForRoleId:eveList.owner_roleid];
            [result addObjectsFromArray:roleArr];

        }
    }
    return result;
}

-(void)outLatestShowDetailDBCSVFileForCompare
{//单独服务器compare使用
    NSString * fileName = @"specialList.csv";
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"Files"];
    [self createFilePath:path];
    
    NSString *databasePath=[path stringByAppendingPathComponent:fileName];
    
    
    __weak typeof(self) weakSelf = self;
    [self writeLocalCSVWithFileName:databasePath
                        headerNames:@"统计时间,购买时间,售出时间,服务器,门派,估价,购买价格,售出价格,收益,间隔天数,买入链接,卖出链接\n"
                         modelArray:[self latestTotalShowedHistoryList]
                     andStringBlock:^NSString *(CBGListModel * model1, CBGListModel * model2)
     {
         NSString * subStr = [weakSelf inputModelDetailStringForFirstModel:model1
                                                               secondModel:model2];
         return subStr;
     }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startShowDetailLocalDBPlistWithFilePath:databasePath];
    });
}
-(NSString *)inputModelDetailStringForFirstModel:(CBGListModel *)model1 secondModel:(CBGListModel *)model2
{
    if(![model1.owner_roleid isEqualToString:model2.owner_roleid] || !model2)
    {
        return nil;
    }
    
    if([model1.sell_sold_time length] == 0 || [model2.sell_sold_time length] == 0)
    {
        return nil;
    }
    
    if(model1.server_id != model2.server_id)
    {
        return nil;
    }
    
    //model互换
    CBGListModel * soldModel = model1;
    CBGListModel * buyModel = model2;
    
    NSDate * finishDate1 = [NSDate fromString:model1.sell_sold_time];
    NSDate * finishDate2 = [NSDate fromString:model2.sell_sold_time];
    NSTimeInterval sepSecond = [finishDate1 timeIntervalSinceDate:finishDate2];
    if(sepSecond < 0)
    {
        soldModel = model2;
        buyModel = model1;
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSDictionary * serNameDic = total.serverNameDic;
    NSNumber * serId = [NSNumber numberWithInteger:soldModel.server_id];
    NSString * serverName = [serNameDic objectForKey:serId];
    
    NSString * soldTime = soldModel.sell_sold_time?:@"无";
    NSString * butTime = buyModel.sell_sold_time?:@"无";
    
    NSInteger evalPrice = MIN(soldModel.equip_price/100 * 0.05, 1000);
    NSInteger earnPrice = soldModel.equip_price/100 - evalPrice - buyModel.equip_price/100;
    
    //间隔天数
    NSDate * date1 = [NSDate fromString:soldModel.sell_sold_time];
    NSDate * date2 = [NSDate fromString:buyModel.sell_sold_time];
    NSInteger days = [date1 timeIntervalSinceDate:date2]/DAY;
    
    NSDate * soldDate = [NSDate fromString:soldTime];
    NSString * countTime = [soldDate toString:@"yyyy-MM"];
    
    NSString *input = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                       countTime,
                       butTime,
                       soldTime,
                       serverName,
                       soldModel.equip_school_name,
                       [NSString stringWithFormat:@"%ld",soldModel.plan_total_price],
                       [NSString stringWithFormat:@"%ld",buyModel.equip_price/100],
                       [NSString stringWithFormat:@"%ld",soldModel.equip_price/100],
                       [NSString stringWithFormat:@"%.0ld",earnPrice],
                       [NSString stringWithFormat:@"%.0ld",days],
                       buyModel.detailWebUrl,
                       soldModel.detailWebUrl,
                       nil];
    
    return input;
}


-(NSArray *)moreFunctionsForDetailSubVC
{
    NSMutableArray * arr = [NSMutableArray array];
    MSAlertAction * action = nil;
    __weak typeof(self) weakSelf = self;
    
    
    action = [MSAlertAction actionWithTitle:@"数据导出" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf outLatestShowDetailDBCSVFileForCompare];
              }];
    [arr addObject:action];
    
    
    return arr;
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
