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
    
    action = [MSAlertAction actionWithTitle:@"数据导出" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf outLatestShowDetailDBCSVFileForOthersCompare];
              }];
    [arr addObject:action];



    return arr;
    return nil;
}
-(void)outLatestShowDetailDBCSVFileForOthersCompare
{//单独服务器compare使用
    NSString * fileName = @"othersCompareList.csv";
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"Files"];
    [self createFilePath:path];
    
    NSString *databasePath=[path stringByAppendingPathComponent:fileName];
    
    
    __weak typeof(self) weakSelf = self;
    [self writeLocalCSVWithFileName:databasePath
                        headerNames:@"购买时间,售出时间,服务器,门派,估价,购买价格,售出价格,收益,间隔天数,买入链接,卖出链接\n"
                         modelArray:[self latestTotalShowedHistoryList]
                     andStringBlock:^NSString *(CBGListModel * model1, CBGListModel * model2)
     {
         NSString * subStr = [weakSelf inputModelDetailStringForFirstModel:model1
                                                               secondModel:model2];
         return subStr;
     }];
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
    
    
    NSString *input = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
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
