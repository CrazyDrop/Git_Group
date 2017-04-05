//
//  ZWDetailBuyVC.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/10.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDetailBuyVC.h"
#import "ZWSystemRequestModel.h"
#import "ZWSystemSellListVC.h"
#import "RemoteNTFRefreshManager.h"
#import "MSAlertController.h"
#import "ZWSellOthersListClearModel.h"
#import "ZWDetailOthersClearListVC.h"
#import "ZALocationLocalModel.h"
@interface ZWDetailBuyVC()
{
    BaseRequestModel * _sysRequestModel;
}
@end

@implementation ZWDetailBuyVC

- (void)viewDidLoad
{
    self.ownerNumber = 0;
    NSString * today = [NSDate unixDate];
    NSDate * localDate = [NSDate fromString:today];
    today = [localDate  toString:@"MM-dd"];
    NSString * str = [NSString stringWithFormat:@"系统标的(%@)",today];
    self.viewTtle = str;
    self.showRightBtn = YES;
    self.rightTitle = @"编辑";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);
    rect.origin.y = aHeight;
    rect.size.height -= aHeight;
    
    [self startRefreshDataModelRequest];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    RemoteNTFRefreshManager * manager = [RemoteNTFRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    ZWSystemRequestModel * refresh = (ZWSystemRequestModel *)_dpModel;
    [refresh removeSignalResponder:self];
    _dpModel = nil;
    
}
-(void)submit
{
    [self showDetailChooseForHistory];

}
-(void)showDetailChooseForHistory
{
    NSString * log = [NSString stringWithFormat:@"对系统数据如何处理？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"开始刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf stopTimerRefresh];
                             }];
    [alertController addAction:action];
    
    
    action = [MSAlertAction actionWithTitle:@"切换账号" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf exchangeWebRequestStringForOwerChange];
              }];
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"历史(名称排序)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showLatestHistoryVCWithName:YES];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"历史(时间排序)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showLatestHistoryVCWithName:NO];
              }];
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"开启屏蔽" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startOthersListDataClearRequest];
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
-(void)startOthersListDataClearRequest
{
    ZWDetailOthersClearListVC * list = [[ZWDetailOthersClearListVC alloc] init];
    [[self rootNavigationController] pushViewController:list animated:YES];
}

-(void)stopTimerRefresh
{
    [self startOpenTimesRefreshTimer];
}
-(void)exchangeWebRequestStringForOwerChange
{
    self.ownerNumber ++;
}
-(void)showLatestHistoryVCWithName:(BOOL)inName
{
    ZWSystemSellListVC * system = [[ZWSystemSellListVC alloc] init];
    system.showListForName = inName;
    [self.navigationController pushViewController:system animated:YES];
}

-(void)startOpenTimesRefreshTimer
{
    RemoteNTFRefreshManager * manager = [RemoteNTFRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger time = 2;
    if(total.refreshTime && [total.refreshTime intValue]>0){
        time = [total.refreshTime intValue];
    }
    manager.refreshInterval = time;
    manager.functionInterval = time;
    manager.funcBlock = ^()
    {
        [weakSelf startRefreshDataModelRequest];
    };
    [manager saveCurrentAndStartAutoRefresh];
}



-(void)tapedOnTestBtn
{
//    NSString * path = [[NSBundle mainBundle] pathForResource:@"zw_md5_check.plist" ofType:nil];
//    NSArray * arr = [[NSArray alloc] initWithContentsOfFile:path];
    
}
-(void)startRefreshDataModelRequest
{
    NSInteger number = self.ownerNumber;
    //数据上传，通知解除
    ZWSystemRequestModel * model = (ZWSystemRequestModel *) _dpModel;
    if(!model){
        model = [[ZWSystemRequestModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    
    NSString * webStr =  nil;
    switch (number)
    {
        case 0:
            //默认值
            webStr =  @"https://www.91zhiwang.com/api/product/list?device_guid=47590D3D-FDD5-49EB-A292-8FE733282562&device_model=iPhone6%2C2&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&session_id=dbb2b4c4759da891b302357a51e1fb8920341501a07e2f45784b9ab70d5f772168fc7293c7b0794d5badf672fcaae28c584a1fc40b3d8543&sn=66fc77708967cdd756b5e6e2f8373185&timestamp=1471228775365.419&user_id=10990659";
            break;
        case 1:
            //178号
            webStr = @"https://www.91zhiwang.com/api/product/list?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&session_id=9423adb5802b75acb70f331a8eadb96fb48df88b2de240fd8b582c25f9a663e0191e07cb9f8af82f3574364b275cf1d937d8b7d8779c9cf7&sn=23b73bf9501dc47939fab69b3a29eeb5&timestamp=1471396096950.982&user_id=11105593";
            break;
        default:
            //无登录号
            webStr = @"https://www.91zhiwang.com/api/product/list?device_guid=8E570B31-07F8-4FA6-8A56-5D24D7905585&device_model=iPhone7%2C1&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&sn=dcf1556dfb8c7c7a2597a8685c28a456&timestamp=1470984959685.582&user_id=0";
            break;
    }
    model.listUrl = webStr;
    [model sendRequest];
}

#pragma mark ZWSystemRequestModel
handleSignal( ZWSystemRequestModel, requestError )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}
handleSignal( ZWSystemRequestModel, requestLoading )
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}


handleSignal( ZWSystemRequestModel, requestLoaded )
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    ZWSystemRequestModel * model = (ZWSystemRequestModel *) _dpModel;
    NSArray * arr = model.sysArr;
    
    self.dataArr = arr;
    [self.listTable reloadData];
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    for (ZWSysSellModel * eve in arr)
    {
//        [manager localSaveSystemSellModel:eve];
    }
}




@end
