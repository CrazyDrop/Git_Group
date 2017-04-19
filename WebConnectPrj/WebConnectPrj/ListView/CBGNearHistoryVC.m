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
                       [self.listTable reloadData];
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
    if(!showTotal && [compareArr count] > 0)
    {
        [roleArr addObject:[compareArr firstObject]];
        if([compareArr count] > 1)
        {
//            [roleArr addObject:[compareArr objectAtIndex:1]];
        }
    }else{
        [roleArr addObjectsFromArray:compareArr];
    }
    [roleArr addObjectsFromArray:historyArr];
    [roleArr addObjectsFromArray:sellArr];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.dataArr = roleArr;
                       [self.listTable reloadData];
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
                       [self.listTable reloadData];
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
                       [self.listTable reloadData];
                   });;
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
    
    
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}

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
