//
//  ZWServerDetailListRefreshVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWServerDetailListRefreshVC.h"
#import "ServerDetailRefreshModel.h"
#import "MSAlertController.h"
#import "ZWServerRefreshReSelectVC.h"
#import "ServerDetailRefreshUpdateModel.h"
#import "ZWServerURLCheckVC.h"
@interface ZWServerDetailListRefreshVC ()<ServerDetailUpdateRefreshDelegate>
{
    
}
@property (nonatomic, assign) NSInteger countIndex;
@property (nonatomic, assign) BOOL detailProxy;
@property (nonatomic, assign) BOOL refreshStop;

@property (nonatomic, strong) NSArray * serverReqArray;
@property (nonatomic, strong) NSArray * serverIdArray;

@property (nonatomic, strong) NSDictionary * serNameDic;
@property (nonatomic, strong) NSDate * proxyRefreshDate;
@property (nonatomic, assign) NSInteger proxyNum;
@end

@implementation ZWServerDetailListRefreshVC


- (void)viewDidLoad
{
    ZALocalStateTotalModel * total  = [ZALocalStateTotalModel currentLocalStateModel];
    NSArray * arr = [total.serverIDCache componentsSeparatedByString:@","];
    self.serverIdArray = arr;
    NSDictionary * serDic = total.serverNameDic;
    self.serNameDic = serDic;
    
    self.rightTitle = @"更多";
    self.showRightBtn = YES;
    self.viewTtle = [NSString stringWithFormat:@"时间递增 %ld",[arr count]];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.detailProxy = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshEquipRequestWithWebRequestNeedRefreshError:)
                                                 name:NOTIFICATION_NEED_REFRESH_EQUIP_ERROR_STATE
                                               object:nil];


    [self prepareForServerRequestModel];
    
}
-(void)checkDetailErrorForTipsError
{
    ZWServerURLCheckVC * check = [[ZWServerURLCheckVC  alloc] init];
    [[self rootNavigationController] pushViewController:check animated:YES];
}
-(void)refreshEquipRequestWithWebRequestNeedRefreshError:(NSNotification *)noti
{
    BOOL webCheck = [noti.object boolValue];//屏蔽自身网络请求
    if(webCheck)
    {
        NSArray * reqArr = self.serverReqArray;
        for (NSInteger index = 0; index < [reqArr count]; index ++)
        {
            ServerDetailRefreshUpdateModel * reqModel = [reqArr objectAtIndex:index];
            reqModel.endRefresh = NO;
//            reqModel.equipEnable = YES;//暂不使用
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self finishAndStopBaseRequest];
}
-(void)finishAndStopBaseRequest
{
    NSArray * reqArr = self.serverReqArray;
    for (NSInteger index = 0; index < [reqArr count]; index ++)
    {
        ServerDetailRefreshUpdateModel * reqModel = [reqArr objectAtIndex:index];
        [reqModel stopRefreshRequestAndClearRequestModel];
    }
}
-(void)prepareForServerRequestModel
{
    NSMutableArray * reqArr = [NSMutableArray array];
    NSArray * numArr = self.serverIdArray;
    for (NSInteger index = 0; index < [numArr count]; index ++)
    {
        NSString * tag = [numArr objectAtIndex:index];
        ServerDetailRefreshUpdateModel * reqModel = [[ServerDetailRefreshUpdateModel alloc] init];
        reqModel.requestDelegate = self;
        reqModel.serverTag = tag;
        reqModel.serverName = [self.serNameDic objectForKey:[NSNumber numberWithInteger:[tag integerValue]]];
        
        
//        if(index == 0)
//        {
//            NSString * tag = @"159";
//            reqModel.serverTag = tag;
//            reqModel.serverName = [self.serNameDic objectForKey:[NSNumber numberWithInteger:[tag integerValue]]];
//            [reqModel prepareWebRequestParagramForListRequest];
//            [reqArr addObject:reqModel];
//        }
        
        [reqModel prepareWebRequestParagramForListRequest];
        [reqArr addObject:reqModel];

        
    }
    self.serverReqArray = reqArr;
}


-(void)startRefreshDataModelRequest
{
    self.countIndex ++;
    if(self.countIndex < 3)
    {
        return;
    }
    if(self.refreshStop){
        return;
    }
    
    if([self.proxyRefreshDate timeIntervalSinceNow] < 0 || !self.proxyRefreshDate)
    {
        [self refreshProxyCacheArrayAndCacheSubArray];
    }


    NSArray * reqArr = self.serverReqArray;
    for (NSInteger index = 0; index < [reqArr count]; index ++)
    {
        ServerDetailRefreshUpdateModel * reqModel = [reqArr objectAtIndex:index];
        reqModel.proxyEnable = self.detailProxy;
        [reqModel startRefreshDataModelRequest];
    }
}
-(void)refreshProxyCacheArrayAndCacheSubArray
{
    self.proxyRefreshDate = [NSDate dateWithTimeIntervalSinceNow:MINUTE * 1];
    self.proxyNum ++;
    
    //没2分钟，刷新一次vpn列表
    ZWProxyRefreshManager * manager =[ZWProxyRefreshManager sharedInstance];
    [manager clearProxySubCache];

}

-(void)showDetailServerSelectedArr
{
    ZWServerRefreshReSelectVC * list = [[ZWServerRefreshReSelectVC alloc] init];
    [[self rootNavigationController] pushViewController:list animated:YES];
}

-(void)refreshLocalServerDBWithLatestTotalDBList
{
    
}
-(void)refreshLocalTimerOrderSNRefreshState:(BOOL)enable
{
    self.refreshStop = !enable;
}

-(void)submit
{
    NSString * log = [NSString stringWithFormat:@"对刷新数据操作？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"停止刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf refreshLocalTimerOrderSNRefreshState:NO];
                             }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"选择服务器" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showDetailServerSelectedArr];
                  
              }];
    [alertController addAction:action];

    
    action = [MSAlertAction actionWithTitle:@"拆分历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLocalServerDBWithLatestTotalDBList];
                  
              }];
    [alertController addAction:action];
    
    
    action = [MSAlertAction actionWithTitle:@"开启代理" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.detailProxy = YES;
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"关闭代理" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.detailProxy = NO;
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
-(void)serverDetailUpdateRequestErroredWithUpdateModel:(ServerDetailRefreshModel *)model
{
    self.tipsView.hidden = NO;
}

-(void)serverDetailListUpdateRequestFinishWithUpdateModel:(ServerDetailRefreshUpdateModel *)model listArray:(NSArray *)array
{
    [self refreshTableViewWithInputLatestListArray:array replace:NO];
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
