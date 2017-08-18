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
@interface ZWServerDetailListRefreshVC ()<ServerDetailRefreshDelegate>
{
    
}
@property (nonatomic, assign) NSInteger countIndex;
@property (nonatomic, assign) BOOL detailProxy;
@property (nonatomic, assign) BOOL refreshStop;

@property (nonatomic, strong) NSArray * serverReqArray;
@property (nonatomic, strong) NSArray * serverIdArray;


@end

@implementation ZWServerDetailListRefreshVC


- (void)viewDidLoad
{
    ZALocalStateTotalModel * total  = [ZALocalStateTotalModel currentLocalStateModel];
    NSArray * arr = [total.serverIDCache componentsSeparatedByString:@","];
    self.serverIdArray = arr;
    
    self.rightTitle = @"更多";
    self.showRightBtn = YES;
    self.viewTtle = [NSString stringWithFormat:@"时间递增 %ld",[arr count]];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareForServerRequestModel];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
-(void)prepareForServerRequestModel
{
    NSMutableArray * reqArr = [NSMutableArray array];
    NSArray * numArr = self.serverIdArray;
    for (NSInteger index = 0; index < [numArr count]; index ++)
    {
        NSString * tag = [numArr objectAtIndex:index];
        ServerDetailRefreshModel * reqModel = [[ServerDetailRefreshModel alloc] init];
        reqModel.requestDelegate = self;
        reqModel.serverTag = tag;
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

    NSArray * reqArr = self.serverReqArray;
    for (NSInteger index = 0; index < [reqArr count]; index ++)
    {
        ServerDetailRefreshModel * reqModel = [reqArr objectAtIndex:index];
        reqModel.proxyEnable = self.detailProxy;
        [reqModel startRefreshDataModelRequest];
    }
    
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


-(void)serverDetailListRequestFinishWithUpdateModel:(ServerDetailRefreshModel *)model listArray:(NSArray *)array
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
