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
                             @""];
    
    
    
    NSArray * listArr = [self localSaveListArrayFromRoleIdArray:roleIdArr];
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

-(void)outHtmlPlanListWithLatestShowDetail
{
    //
    NSMutableString * listStr = [NSMutableString string];
    NSArray * listArr = [self latestTotalShowedHistoryList];
    
    [listStr appendString:@"<html content='text/html; charset=GBK'> <body>"];
    [listStr appendString:@"<title>自有数据</title>"];
    for (NSInteger index = 0; index < [listArr count] ;index ++ )
    {
        CBGListModel * eveModel = [listArr objectAtIndex:index];
        if(eveModel.plan_rate >= 10 && eveModel.plan_rate <= 40)
        {
            [listStr appendFormat:@"%ld %ld <a href='%@' target=''> %@ </a> </br>",index,eveModel.plan_total_price,eveModel.detailWebUrl,eveModel.detailWebUrl];
        }
    }
    [listStr appendString:@"</body></html>"];
    
    [self writeLatestDataToLocalPathWithDetailString:listStr];
}
-(void)writeLatestDataToLocalPathWithDetailString:(NSString *)detailString
{
    //    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSString * fileName = @"OwnerBuy.html";
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *databasePath=[path stringByAppendingPathComponent:fileName];
    NSError* error;
    //    if (![fm fileExistsAtPath:databasePath])
    {
        [detailString writeToFile:databasePath
                       atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:&error];
    }
}
-(NSArray *)moreFunctionsForDetailSubVC
{
    NSMutableArray * arr = [NSMutableArray array];
    MSAlertAction * action = nil;
    __weak typeof(self) weakSelf = self;
    
    
    action = [MSAlertAction actionWithTitle:@"数据导出" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf outHtmlPlanListWithLatestShowDetail];
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
