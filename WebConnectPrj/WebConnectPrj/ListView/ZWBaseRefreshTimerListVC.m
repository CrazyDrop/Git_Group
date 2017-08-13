//
//  ZWBaseRefreshTimerListVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/12.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWBaseRefreshTimerListVC.h"
#import "RemoteNTFRefreshManager.h"
@interface ZWBaseRefreshTimerListVC ()

@end

@implementation ZWBaseRefreshTimerListVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startLocationDataRequest];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s disappear",__FUNCTION__);
    [super viewWillDisappear:animated];
    
    RemoteNTFRefreshManager * manager = [RemoteNTFRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [[ZALocation sharedInstance] stopUpdateLocation];
}

-(void)startLocationDataRequest
{
    //    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    //    self.latest = [manager latestLocationModel];
    
    ZALocation * locationInstance = [ZALocation sharedInstance];
    [locationInstance startLocationRequestUserAuthorization];
    __weak typeof(self) weakSelf = self;
    
    
    [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *location){
        [weakSelf backLocationDataWithString:location];
    }];
}
-(void)backLocationDataWithString:(id)obj
{
    //    NSLog(@"%s",__FUNCTION__);
    
    RemoteNTFRefreshManager * manager = [RemoteNTFRefreshManager sharedInstance];
    if(manager.isRefreshing) return;
    [self startOpenTimesRefreshTimer];
}

-(void)startOpenTimesRefreshTimer
{
    
    RemoteNTFRefreshManager * manager = [RemoteNTFRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    //    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger time = 3;
    //    if(total.refreshTime && [total.refreshTime intValue]>0){
    //        time = [total.refreshTime intValue];
    //    }
    manager.refreshInterval = time;
    manager.functionInterval = time;
    manager.funcBlock = ^()
    {
#if TARGET_IPHONE_SIMULATOR
        [weakSelf performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                                   withObject:nil
                                waitUntilDone:YES];
#else
        [weakSelf performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                                   withObject:nil
                                waitUntilDone:NO];
#endif
        
    };
    [manager saveCurrentAndStartAutoRefresh];
}

-(void)startRefreshDataModelRequest
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
