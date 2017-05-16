//
//  ZWPanicRefreshController.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/15.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicRefreshController.h"
#import "EquipDetailArrayRequestModel.h"
#import "EquipListRequestModel.h"
#import "Equip_listModel.h"
#import "CBGDetailWebView.h"
#import "PanicRefreshManager.h"
#import "ZALocationLocalModel.h"

@interface ZWPanicRefreshController ()
{
    NSMutableDictionary * cacheDic;//以时间为key  model为value
    //以时间排序，筛选需要进行刷新的
    
    NSMutableDictionary * appendDic;
    //新增的字典，以create时间排序  认为create时间不存在完全相同的
}


@end

@implementation ZWPanicRefreshController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        cacheDic = [[NSMutableDictionary alloc] init];
        appendDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)viewDidLoad
{
    self.viewTtle = @"近期改价";
    self.rightTitle = @"提交";
    self.showRightBtn = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
-(NSArray *)latestRefreshRequestDetailUrls
{
    NSMutableArray * urls = [NSMutableArray array];
    
    NSMutableDictionary * addDic = [NSMutableDictionary dictionary];
    @synchronized (appendDic)
    {
        [addDic addEntriesFromDictionary:appendDic];
    }
    
    @synchronized (cacheDic)
    {
        [cacheDic addEntriesFromDictionary:addDic];
        
        NSArray * keys = [cacheDic allKeys];
        keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
        {
//            CBGListModel * eve1 = (CBGListModel *)obj1;
//            CBGListModel * eve2 = (CBGListModel *)obj2;
            return [obj2 compare:obj1];
        }];
        
        if([keys count] > 20)
        {
            keys = [keys subarrayWithRange:NSMakeRange(0, 20)];
        }
        
        for (NSInteger index = 0;index < [keys count] ;index ++ )
        {
            NSString * modelKey = [keys objectAtIndex:index];
            Equip_listModel * eveObj = [cacheDic objectForKey:modelKey];
            NSString * url = eveObj.detailDataUrl;
            [urls addObject:url];
        }
    }
    return urls;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    _detailListReqModel = nil;
    _dpModel = nil;
    [self startLocationDataRequest];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s disappear",__FUNCTION__);
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    EquipDetailArrayRequestModel * detailRefresh = (EquipDetailArrayRequestModel *)_detailListReqModel;
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
    
    EquipListRequestModel * refresh = (EquipListRequestModel *)_dpModel;
    [refresh cancel];
    [refresh removeSignalResponder:self];
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    PanicRefreshManager * manager = [PanicRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [[ZALocation sharedInstance] stopUpdateLocation];
    
}
-(void)startLocationDataRequest
{
    ZALocation * locationInstance = [ZALocation sharedInstance];
    [locationInstance startLocationRequestUserAuthorization];
    __weak typeof(self) weakSelf = self;
    
    
    [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *location){
        [weakSelf backLocationDataWithString:location];
    }];
}
-(void)backLocationDataWithString:(id)obj
{
    PanicRefreshManager * manager = [PanicRefreshManager sharedInstance];
    if(manager.isRefreshing) return;
    [self startOpenTimesRefreshTimer];
}
-(void)startOpenTimesRefreshTimer
{
    
    PanicRefreshManager * manager = [PanicRefreshManager sharedInstance];
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
        [weakSelf performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                                   withObject:nil
                                waitUntilDone:NO];
        
        [weakSelf performSelectorOnMainThread:@selector(startRefreshLatestDetailModelRequest)
                                   withObject:nil
                                waitUntilDone:NO];

    };
    [manager saveCurrentAndStartAutoRefresh];
}
-(void)startRefreshLatestDetailModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    EquipDetailArrayRequestModel * listRequest = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(listRequest.executing) return;
    
    NSLog(@"%s",__FUNCTION__);

    NSArray * details = [self latestRefreshRequestDetailUrls];
    [self startEquipDetailAllRequestWithUrls:details];
}


-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    EquipListRequestModel * listRequest = (EquipListRequestModel *)_dpModel;
    if(listRequest.executing) return;
    
    [requestLock lock];
    
    NSLog(@"%s",__FUNCTION__);
    
    EquipListRequestModel * model = (EquipListRequestModel *)_dpModel;
    //仅做数据刷新，不做展示   详情数据请求中时，列表数据也需要刷新
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[EquipListRequestModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
        model.pageNum = 20;//刷新页数
    }
    
    [model sendRequest];
}
#pragma mark EquipListRequestModel
handleSignal( EquipListRequestModel, requestError )
{
    self.tipsView.hidden = NO;
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
}
handleSignal( EquipListRequestModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    [self showLoading];
}


handleSignal( EquipListRequestModel, requestLoaded )
{
    [self hideLoading];
    //    refreshLatestTotalArray
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%s",__FUNCTION__);
    
    EquipListRequestModel * model = (EquipListRequestModel *) _dpModel;
    NSArray * total  = model.listArray;
    
    //正常序列
    NSMutableArray * array = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]])
        {
            [array addObjectsFromArray:obj];
        }
    }
    self.tipsView.hidden = [array count] != 0;

    
    //检查得出未上架的数据
    //列表数据排重
    NSMutableDictionary * modelsDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0 ;index < [array count]; index ++ )
    {
        NSInteger backIndex = [array count] - index - 1;
        Equip_listModel * eveModel = [array objectAtIndex:backIndex];
        if(eveModel.equipState == CBGEquipRoleState_unSelling)
        {
            [modelsDic setObject:eveModel forKey:eveModel.game_ordersn];
        }
    }
    NSArray * backRefreshArr = [modelsDic allValues];
    if([backRefreshArr count] > 0)
    {
        //进行库表查询，取出创建时间
        NSMutableDictionary * currentDic = [NSMutableDictionary dictionary];
        NSArray * orderArr = [modelsDic allKeys];
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        for (NSInteger index = 0 ;index < [orderArr count]; index ++ )
        {
            NSString * eveSn = [orderArr objectAtIndex:index];
            NSArray * modelsArr = [dbManager localSaveMakeOrderHistoryListForOrderSN:eveSn];
            if([modelsArr count] > 0)
            {
                CBGListModel * eveCBG = [modelsArr firstObject];
                NSString * time = eveCBG.sell_create_time;
                [currentDic setObject:eveCBG forKey:time];
            }
        }
        
        @synchronized (appendDic)
        {
            [appendDic addEntriesFromDictionary:currentDic];
        }
    }
    
    [requestLock unlock];
}



-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
    NSLog(@"%s",__FUNCTION__);
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(!model){
        model = [[EquipDetailArrayRequestModel alloc] init];
        [model addSignalResponder:self];
        _detailListReqModel = model;
    }
    
    
    [model refreshWebRequestWithArray:array];
    [model sendRequest];
    
}

#pragma mark EquipDetailArrayRequestModel
handleSignal( EquipDetailArrayRequestModel, requestError )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
handleSignal( EquipDetailArrayRequestModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

handleSignal( EquipDetailArrayRequestModel, requestLoaded )
{
    NSLog(@"%s",__FUNCTION__);
    
    //进行存储操作、展示
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *) _detailListReqModel;
    NSArray * total  = model.listArray;
    
    NSMutableArray * detailModels = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            [detailModels addObject:[obj firstObject]];
        }else{
            [detailModels addObject:[NSNull null]];
        }
    }
    
    NSLog(@"EquipDetailArrayRequestModel %lu",(unsigned long)[detailModels count]);
    


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
