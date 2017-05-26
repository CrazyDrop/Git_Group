//
//  ZAPanicPayHistoryVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/25.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZAPanicPayHistoryVC.h"
#import "ZAAutoBuyHomeVC.h"

@interface ZAPanicPayHistoryVC ()

@end

@implementation ZAPanicPayHistoryVC

- (void)viewDidLoad
{
    self.showRightBtn = YES;
    self.rightTitle = @"刷新";
    self.viewTtle = @"历史推荐";
    [super viewDidLoad];

    [self refreshLatestShowListWithLocalSaveUrls];
}
-(void)refreshLatestShowListWithLocalSaveUrls
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSArray * sortArr =  total.panicOrderHistory;
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        NSString * url = [sortArr objectAtIndex:index];
        NSDictionary * eveDic = [self paramDicFromLatestUrlString:url];
        CBGListModel * list = [self createCBGListModelObjFromLatestParamDic:eveDic];
        [resultArr addObject:list];
    }
    
    self.dbHistoryArr = resultArr;
    [self refreshLatestShowTableView];
    
}
-(CBGListModel *)createCBGListModelObjFromLatestParamDic:(NSDictionary *)dic
{
    CBGListModel * list = [[CBGListModel alloc] init];
    list.game_ordersn = [dic objectForKey:@"ordersn"];
    list.server_id = [[dic objectForKey:@"serverid"] integerValue];
    
    return list;
}

-(NSDictionary *)paramDicFromLatestUrlString:(NSString *)totalStr
{
//    http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=127&ordersn=280_1495769630_281972057&equip_refer=1
    //以？分段，参数
    
    NSMutableDictionary * resultDic = [NSMutableDictionary dictionary];

    NSArray * totalArr = [totalStr componentsSeparatedByString:@"?"];
    if([totalArr count] > 1)
    {
        NSString * paramStr = [totalArr objectAtIndex:1];
        NSArray * subArr = [paramStr componentsSeparatedByString:@"&"];
        for (NSInteger index = 0;index < [subArr count];index ++ )
        {
            NSString * eveStr = [subArr objectAtIndex:index];
            NSArray * eveArr = [eveStr componentsSeparatedByString:@"="];
            if([eveArr count] >= 2)
            {
                NSString * keyStr = [eveArr objectAtIndex:0];
                NSString * valueStr = [eveStr substringFromIndex:[keyStr length] + 1];
                [resultDic setObject:valueStr forKey:keyStr];
            }
        }
    }
    
    return resultDic;
}


-(void)submit
{
      [self startLatestDetailListRequestForShowedCBGListArr:[self latestTotalShowedHistoryList]];
}
-(void)finishDetailListRequestWithFinishedCBGListArray:(NSArray *)array
{
    [DZUtils noticeCustomerWithShowText:@"退出重新刷新"];
    //    [self refreshLatestShowTableView];
    [[self rootNavigationController] popViewControllerAnimated:YES];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    NSArray * subArr = [self.showSortArr objectAtIndex:secNum];
    CBGListModel * contact = [subArr objectAtIndex:rowNum];
    
    
//    NSDictionary * eveDic = [self.hisArr objectAtIndex:indexPath.section];
//    
//    NSString * rate = [eveDic objectForKey:@"rate"];
//    NSString * price = [eveDic objectForKey:@"price"];
//    NSString * webUrl = [eveDic objectForKey:@"weburl"];
    
    ZAAutoBuyHomeVC * home = [[ZAAutoBuyHomeVC alloc] init];
    home.webUrl = contact.detailWebUrl;
    //历史记录查看，不再进行自动购买，屏蔽利差
//    home.rate = [rate integerValue];
//    home.price = [price integerValue];
    [[self rootNavigationController] pushViewController:home animated:YES];
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
