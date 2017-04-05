//
//  ZWDetailOthersClearListVC.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/31.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDetailOthersClearListVC.h"
#import "ZWSellOthersListClearModel.h"
#import "RefreshListCell.h"
#import "RemoteNTFRefreshManager.h"
@interface ZWDetailOthersClearListVC ()
{
    ZWSellOthersListClearModel * _sysRequestModel;
}
@property (nonatomic,strong) NSArray * dataArr;

@end

@implementation ZWDetailOthersClearListVC

-(void)viewDidLoad
{
    self.viewTtle = @"清除变现区数据";
//    self.showRightBtn = YES;
//    self.rightTitle = @"编辑";
    [super viewDidLoad];
    [self startOpenTimesRefreshTimer];
    
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    RemoteNTFRefreshManager * manager = [RemoteNTFRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    ZWSellOthersListClearModel * refresh = (ZWSellOthersListClearModel *)_dpModel;
    [refresh removeSignalResponder:self];
    _sysRequestModel = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

-(void)startOpenTimesRefreshTimer
{
    RemoteNTFRefreshManager * manager = [RemoteNTFRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    NSInteger time = 60*1;
//    if(total.refreshTime && [total.refreshTime intValue]>0){
//        time = [total.refreshTime intValue];
//    }
    manager.refreshInterval = time;
    manager.functionInterval = time;
    manager.funcBlock = ^()
    {
        [weakSelf startWebListClearRequest:nil];
    };
    [manager saveCurrentAndStartAutoRefresh];
}

-(void)startWebListClearRequest:(NSTimer *)timer
{
    ZWSellOthersListClearModel * model = (ZWSellOthersListClearModel *) _sysRequestModel;
    if(!model){
        model = [[ZWSellOthersListClearModel alloc] init];
        [model addSignalResponder:self];
        _sysRequestModel = model;
    }
    [model sendRequest];
}

#pragma mark ZWSellOthersListClearModel
handleSignal( ZWSellOthersListClearModel, requestError )
{
    
}
handleSignal( ZWSellOthersListClearModel, requestLoading )
{
    
}
handleSignal( ZWSellOthersListClearModel, requestLoaded )
{
    
    ZWSellOthersListClearModel * model = (ZWSellOthersListClearModel *) _sysRequestModel;
    NSArray * arr = model.sysArr;
    
    self.dataArr = arr;
    [self.listTable reloadData];
    //
    //    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    //    for (ZWSysSellModel * eve in arr)
    //    {
    //        [manager localSaveSystemSellModel:eve];
    //    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secNum = indexPath.row;
    NSString * contact = [self.dataArr objectAtIndex:secNum];
    
    static NSString *cellIdentifier = @"RefreshListCellIdentifier_Sell";
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
    
    cell.sellRateLbl.text =  contact;

    
    return cell;
}


@end
