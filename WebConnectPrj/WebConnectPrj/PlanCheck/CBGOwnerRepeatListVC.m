//
//  CBGOwnerRepeatListVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGOwnerRepeatListVC.h"
#import "ZALocationLocalModel.h"
#import "ZACBGDetailWebVC.h"
@interface CBGOwnerRepeatListVC ()

@end

@implementation CBGOwnerRepeatListVC

- (void)viewDidLoad {
    self.viewTtle = @"自有记录";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortStyle = CBGStaticSortShowStyle_None;
    self.orderStyle = CBGStaticOrderShowStyle_None;
    

    NSArray * roleIdArr = @[
                             @"-10715981-20170321",
                             @"919656",
                             @"40869698",
                             @"25797283",
                             @"3322808",
                             @"27929001",
                             @"45403837",
                             @"16842315",
                             @"28189246",
                             @"46966316",
                             @"40826025",
                             @"964804",
                             @"31474637",
                             @"33748096",
                             @"31201989",
                             @"16837053",
                             @"36124790",
                             @"24860963",
                             @"32939703",
                             @"23020644",
                             @"38064578",
                             @"24516744",
                             @"31628872",
                             @"13776826",
                             @"4831983",
                             @"37998702",
                             @"6852935",
                             @"28358684",
                             @"15928817",
                             @"18799438",
                             @"29255762",
                             @"19502857",
                             @"32481480",
                             @"38477385",
                             @"31780420",
                             @"28508479",
                             @"13051880",
                             @"30911286",
                             @"18558132",
                             @"1862",
                             @""];
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray  * order = [dbManager localSaveEquipHistoryModelListOwnerList];
    
    //两部分均展示
    NSMutableArray * editArr = [NSMutableArray array];
    [editArr addObjectsFromArray:roleIdArr];
    
    for (NSInteger index = 0;index < [order count] ;index ++ )
    {
        CBGListModel * eve = [order objectAtIndex:index];
        NSString * eveRoleId = eve.owner_roleid;
        
        if(![editArr containsObject:eveRoleId]){
            [editArr addObject:eveRoleId];
        }
    }
    
    NSArray * listArr = [self localSaveListArrayFromRoleIdArray:editArr];
    self.dbHistoryArr = listArr;
    [self refreshLatestShowedDBArrayWithNotice:YES];
}
-(NSArray *)localSaveListArrayFromRoleIdArray:(NSArray *)roleIdArr
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSMutableArray * result = [NSMutableArray  array];
    for (NSInteger index = 0; index < [roleIdArr count]; index++)
    {
        NSInteger backIndex = [roleIdArr count] - index - 1;
        NSString * eveRoleId = [roleIdArr objectAtIndex:backIndex];
        NSArray * roleArr = [dbManager localSaveEquipHistoryModelListForRoleId:eveRoleId];
        for (NSInteger eveIndex = 0;eveIndex < [roleArr count] ;eveIndex ++ )
        {
            id eveObj = [roleArr objectAtIndex:[roleArr count] - 1 - eveIndex];
            [result addObject:eveObj];
        }
    }
    return result;
}

//-(NSArray *)localSaveListArrayFromOrderSNArray:(NSArray *)arr
//{
//    
//    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
//    NSMutableArray * result = [NSMutableArray  array];
//    for (NSInteger index = 0; index < [arr count]; index++)
//    {
//        NSString * eveSn = [arr objectAtIndex:index];
//        NSArray * subArr = [dbManager localSaveEquipHistoryModelListForOrderSN:eveSn];
//        if([subArr count] > 0 )
//        {
//            CBGListModel * eveList = [subArr firstObject];
//            [roleIdArr addObject:eveList.owner_roleid];
//            NSArray * roleArr = [dbManager localSaveEquipHistoryModelListForRoleId:eveList.owner_roleid];
//            [result addObjectsFromArray:roleArr];
//            
//        }
//    }
//    return result;
//}

-(void)outLatestShowDetailDBCSVFileForCompare
{//单独服务器compare使用
    NSString * fileName = @"ownerList.csv";
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




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    NSArray * subArr = [self.showSortArr objectAtIndex:secNum];
    CBGListModel * contact = [subArr objectAtIndex:rowNum];
    NSString * selectId = contact.owner_roleid;
    
    
    //    CBGEquipRoleState state = contact.latestEquipListStatus;
    //    NSMutableArray * showArr = [NSMutableArray array];
    
    ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
    detail.cbgList = contact;
    [[self rootNavigationController] pushViewController:detail animated:YES];
    
    
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
