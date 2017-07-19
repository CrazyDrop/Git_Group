//
//  CBGNearHistoryVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/21.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGNearHistoryVC.h"
#import "MSAlertController.h"
#import "ZALocationLocalModel.h"
#import "CBGStatisticsDetailHistoryVC.h"
#import "RefreshListCell.h"
@interface CBGNearHistoryVC ()
@property (nonatomic, strong) NSString * roleId;
@property (nonatomic, strong) NSString * orderSN;
@property (nonatomic, strong) NSString * serverID;
@property (nonatomic, strong) NSString * schoolId;
@end

@implementation CBGNearHistoryVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.showLeftBtn = YES;
        self.showRightBtn = YES;
        self.rightTitle = @"筛选";
        self.viewTtle = @"相关历史";
        self.orderStyle = CBGStaticOrderShowStyle_Create;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //展示相关历史数据
    [self refreshLatestSelectedRoleIdAndRefreshLocalId];
    [self startLocalZWCompareAndSellListDataWithTotal:NO];
}
-(void)refreshLatestSelectedRoleIdAndRefreshLocalId
{
    NSString *order_sn = self.cbgList.game_ordersn;
    NSString *role_id = self.cbgList.owner_roleid;
    NSString *server_id = [NSString stringWithFormat:@"%ld",self.cbgList.server_id];
    NSString *school_id = [NSString stringWithFormat:@"%ld",self.cbgList.equip_school];
    
    if(!order_sn)
    {
        role_id = self.detailModel.owner_roleid;
        order_sn = self.detailModel.game_ordersn;
        server_id = [NSString stringWithFormat:@"%ld",[self.detailModel.serverid integerValue]];
        
        NSInteger school = [CBGListModel schoolNumberFromSchoolName:self.detailModel.equip_name];
        school_id = [NSString stringWithFormat:@"%ld",school];
    }
    
    //库表查询，通过 order_sn  补全roleid
    if(!role_id)
    {
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        NSArray * dbArr = [dbManager localSaveEquipHistoryModelListForOrderSN:order_sn];
        
        CBGListModel * dbModel = nil;
        if([dbArr count] >0){
            dbModel = [dbArr lastObject];
        }
        role_id = dbModel.owner_roleid;
    }
    
    self.roleId = role_id;
    self.orderSN = order_sn;
    self.serverID = server_id;
    self.schoolId = school_id;
    
    self.selectedRoleId = [role_id intValue];
    self.selectedOrderSN = order_sn;
}

-(void)startLocalListWithSchool:(NSString *)school andServer:(NSString *)server
{
    
    //历史数据读取，本次交易相关
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * roleArr = [dbManager localSaveEquipHistoryModelListForServerId:server andSchool:school];

    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.dataArr = roleArr;
                       [self refreshLatestShowTableView];
                   });
}

-(void)startLocalZWCompareAndSellListDataWithTotal:(BOOL)showTotal
{
    
    CBGListModel * compareObj = self.cbgList;
    
    //历史数据读取，本次交易相关
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * compareArr = [dbManager localSaveEquipHistoryModelListForCompareCBGModel:compareObj];
    NSArray * historyArr = [dbManager localSaveEquipHistoryModelListForRoleId:_roleId];
    NSArray * sellArr = [dbManager localSaveUserChangeHistoryListForOrderSN:_orderSN];
    

    NSMutableArray * roleArr = [NSMutableArray array];
    if([historyArr count] > 1)
    {//有交易历史
        
        [roleArr addObjectsFromArray:historyArr];
        if(!showTotal && [compareArr count] > 0)
        {
            [roleArr addObject:[compareArr firstObject]];
        }else{
            [roleArr addObjectsFromArray:compareArr];
        }
        [roleArr addObjectsFromArray:sellArr];

    }else
    {
        if(!showTotal && [compareArr count] > 0)
        {
            [roleArr addObject:[compareArr firstObject]];
        }else{
            [roleArr addObjectsFromArray:compareArr];
        }
        [roleArr addObjectsFromArray:historyArr];
        [roleArr addObjectsFromArray:sellArr];

    }

    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.dataArr = roleArr;
                       [self refreshLatestShowTableView];
                   });
}

-(void)startLocalZWOrderSNListData
{
    
    //历史数据读取，本次交易相关
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * orderArr = [dbManager localSaveMakeOrderHistoryListForOrderSN:_orderSN];
    NSArray * sellArr = [dbManager localSaveUserChangeHistoryListForOrderSN:_orderSN];
    NSArray * historyArr = [dbManager localSaveEquipHistoryModelListForOrderSN:_orderSN];
    
    NSMutableArray * roleArr = [NSMutableArray array];
    [roleArr addObjectsFromArray:historyArr];
    [roleArr addObjectsFromArray:sellArr];
    [roleArr addObjectsFromArray:orderArr];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.dataArr = roleArr;
                       [self refreshLatestShowTableView];
                   });;
}

-(void)startLocalZWRoleIDListData
{
    //历史数据读取，本次交易相关
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
//    NSArray * orderArr = [dbManager localSaveMakeOrderHistoryListForRoleId:_roleId];
    NSArray * sellArr = [dbManager localSaveUserChangeHistoryListForRoleId:_roleId];
    NSArray * historyArr = [dbManager localSaveEquipHistoryModelListForRoleId:_roleId];
    
    NSMutableArray * roleArr = [NSMutableArray array];
    [roleArr addObjectsFromArray:historyArr];
    [roleArr addObjectsFromArray:sellArr];
//    [roleArr addObjectsFromArray:orderArr];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.dataArr = roleArr;
                       [self refreshLatestShowTableView];
                   });;
}

-(void)showNearHistoryShowDetailStaticsListVC
{
    NSString * dateStr = @"门派";
    NSArray * dbArray = [self latestTotalShowedHistoryList];
    
    CBGStatisticsDetailHistoryVC * history = [[CBGStatisticsDetailHistoryVC alloc] init];
    history.dbHistoryArr = dbArray;
    history.selectedDate = dateStr;
    [history refreshLatestShowedDBArrayWithNotice:NO];
    [[self rootNavigationController] pushViewController:history animated:YES];
}


-(void)submit
{
    //提供选择
    NSString * log = [NSString stringWithFormat:@"对历史数据筛选？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"空号相近记录" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf startLocalZWCompareAndSellListDataWithTotal:YES];
                             }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"此次交易记录" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLocalZWOrderSNListData];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"账号相关记录" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                 [weakSelf startLocalZWRoleIDListData];
              }];
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"服务器记录" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLocalListWithSchool:nil andServer:_serverID];
              }];
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"门派记录" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLocalListWithSchool:_schoolId andServer:nil];
              }];
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"server+门派" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLocalListWithSchool:_schoolId andServer:_serverID];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"统计历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showNearHistoryShowDetailStaticsListVC];
              }];
    [alertController addAction:action];

    
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    NSArray * subArr = [self.showSortArr objectAtIndex:secNum];
    CBGListModel * contact = [subArr objectAtIndex:rowNum];
    
    static NSString *cellIdentifier = @"RefreshListCellIdentifier_CBG";
    RefreshListCell *cell = (RefreshListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        //            cell = [[ZAContactListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andTableView:tableView];
        //            cell.delegate = self;
        
        
        RefreshListCell * swipeCell = [[[NSBundle mainBundle] loadNibNamed:@"RefreshListCell"
                                                                     owner:nil
                                                                   options:nil] lastObject];
        
        //        [[RefreshListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [swipeCell setValue:cellIdentifier forKey:@"reuseIdentifier"];
        
        cell = swipeCell;
    }
    
    //用来标识是否最新一波数据
    
    CBGEquipRoleState state = contact.latestEquipListStatus;
    NSInteger startPrice = contact.equip_start_price;
    
    NSString * centerDetailTxt = contact.plan_des;
    UIColor * numcolor = [UIColor lightGrayColor];
    UIColor * color = [UIColor lightGrayColor];
    NSString * leftRateTxt = nil;
    //[NSString stringWithFormat:@"%@-%@",contact.area_name,contact.server_name];
    NSString * equipName = [NSString stringWithFormat:@"%@ %ld",contact.equip_school_name,contact.equip_level];
    NSString * leftPriceTxt = [NSString stringWithFormat:@"%.2f",contact.equip_price/100.0];
    NSNumber * serId = [NSNumber numberWithInteger:contact.server_id];
    NSString * serverName = [self.serNameDic objectForKey:serId];
    
    if(!contact)
    {
        leftRateTxt = nil;
        equipName = nil;
        centerDetailTxt = nil;
    }
    
    cell.latestMoneyLbl.textColor = color;
    
    //列表剩余时间
    //    @"dd天HH小时mm分钟"
    NSString * rightTimeTxt =  nil;
    NSString * rightStatusTxt = nil;
    UIColor * rightStatusColor = [UIColor lightGrayColor];
    UIColor * earnColor = [UIColor lightGrayColor];
    UIColor * equipBuyColor = [UIColor lightGrayColor];
    UIColor * leftRateColor = [UIColor lightGrayColor];
    UIColor * leftPriceColor = [UIColor redColor];
    
    //区分状态，
    if( startPrice == 0)
    {//主要展示上下架时间
        NSDate * date = [NSDate fromString:contact.sell_start_time];
        rightTimeTxt =  [date toString:@"(MM-dd)HH:mm"];
        leftRateTxt  = @"上架";
        leftRateColor = [UIColor orangeColor];
        equipName =  [NSString stringWithFormat:@"ID:%@",contact.owner_roleid];
        centerDetailTxt = [contact.game_ordersn substringToIndex:15];

    }
    else if(startPrice > 0)
    {//主要展示  账号基础信息
        NSDate * startDate = [NSDate fromString:contact.sell_create_time];
        rightTimeTxt =  [startDate toString:@"MM-dd HH点"];
        
        rightStatusColor = [UIColor redColor];
        NSString * finishTime = contact.sell_sold_time;
        if([finishTime length] == 0)
        {//取消时间
            finishTime = contact.sell_back_time;
            rightStatusColor = [UIColor grayColor];
        }
        
        if([finishTime length] > 0)
        {
            NSDate *  finishDate = [NSDate fromString:finishTime];
            NSTimeInterval count = [finishDate timeIntervalSinceDate:startDate];
            
            if(count < 0)
            {
                count = 0;
            }
            
            BOOL showSpace = NO;
            NSInteger space = contact.sell_space;
            if(space > 0 && space < 10*MINUTE)
            {
                showSpace = YES;
                earnColor = [UIColor blueColor];
            }
            
            //时差秒数
            NSTimeInterval minuteNum = count/60;
            int minute = ((int)minuteNum)%60;
            NSTimeInterval hour = minuteNum/60;
            if(hour > 1){
                rightStatusTxt =  [NSString stringWithFormat:@"隔%02d:%02d",(int)hour,minute];
                if(showSpace){
                    rightStatusTxt =  [NSString stringWithFormat:@"%02d:%02d(%ld)",(int)hour,minute,space/60];
                }
            }else{
                rightStatusTxt =  [NSString stringWithFormat:@"隔%02d分",minute];
                if(showSpace){
                    rightStatusTxt =  [NSString stringWithFormat:@"%02d分(%ld)",minute,space/60];
                }
            }
            
        }else{
            startDate = [NSDate fromString:finishTime];
            rightStatusTxt =  [startDate toString:@"dd HH:mm"];
            
        }
        
        //计算时间差
        
        {
            centerDetailTxt = [NSString stringWithFormat:@"%ld(%ld)号:%d",contact.plan_total_price,contact.plan_zhuangbei_price + contact.plan_zhaohuanshou_price,(int)contact.price_base_equip];
        }
        
        
        if(serverName){
            leftRateTxt = serverName;
        }else{
            leftRateTxt = [NSString stringWithFormat:@"%@:%ld",contact.equip_name,contact.server_id];
        }
        
        NSInteger priceChange = contact.equip_start_price - contact.equip_price/100;
        
        if(priceChange != 0)
        {//价格有变更
            if(priceChange >0)
            {
                leftRateColor = [UIColor orangeColor];
            }
            
            //价格不同，认为是还价购买的，展示还价前价格
            if(contact.equip_price_common != contact.equip_price/100.0)
            {
                leftRateColor = Custom_Blue_Button_BGColor;
                if(contact.equip_start_price == contact.equip_price_common){
                    //初始价格和外部价格一致
                    leftRateTxt = [NSString stringWithFormat:@"%ld %@",contact.equip_price_common,leftRateTxt];
                }else
                {
                    leftRateTxt = [NSString stringWithFormat:@"%ld %ld %@",contact.equip_start_price,contact.equip_price_common,leftRateTxt];
                }
            }else
            {
                leftRateTxt = [NSString stringWithFormat:@"%ld%@",contact.equip_start_price,leftRateTxt];
            }
        }
        
        NSInteger rate = contact.price_rate_latest_plan;
        if(rate > 0 && contact.server_id != 45)
        {
            equipName = [NSString stringWithFormat:@"%@ %ld",contact.equip_school_name,contact.equip_level];
            equipName = [NSString stringWithFormat:@"%ld%% %@",rate,equipName];
            equipBuyColor = [UIColor greenColor];
        }
        //leftPriceTxt = [NSString stringWithFormat:@"%@",leftPriceTxt];
        
        if(contact.planMore_zhaohuan || contact.planMore_Equip)
        {
            numcolor = [UIColor redColor];
        }
    }
    
    if(contact.equip_accept > 0)
    {
        leftPriceTxt = [NSString stringWithFormat:@"%@*",leftPriceTxt];
    }
    if(contact.errored){
        leftPriceTxt = [NSString stringWithFormat:@"!%@",leftPriceTxt];
    }
    if(contact.appointed)
    {
        leftPriceColor = Custom_Blue_Button_BGColor;
    }
    
    
    cell.totalNumLbl.textColor = numcolor;//文本信息展示，区分是否最新一波数据
    cell.totalNumLbl.text = centerDetailTxt;
    cell.rateLbl.text = leftPriceTxt;
    cell.rateLbl.textColor = leftPriceColor;
    
    cell.sellTimeLbl.text = rightStatusTxt;
    cell.sellTimeLbl.textColor = rightStatusColor;
    
    cell.timeLbl.text = rightTimeTxt;
    cell.timeLbl.textColor = earnColor;
    
    UIFont * font = cell.totalNumLbl.font;
    cell.latestMoneyLbl.text = leftRateTxt;
    cell.latestMoneyLbl.textColor = leftRateColor;
    cell.latestMoneyLbl.font = font;
    
    cell.sellRateLbl.font = font;
    cell.sellRateLbl.text = equipName;
    cell.sellRateLbl.textColor = equipBuyColor;
    cell.sellDateLbl.hidden = YES;
    
    return cell;
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
