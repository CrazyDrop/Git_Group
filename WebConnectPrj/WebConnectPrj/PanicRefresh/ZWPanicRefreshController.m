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
#import "ZWPanicRefreshManager.h"
@interface ZWPanicRefreshController ()
{
    NSMutableDictionary * cacheDic;//以时间为key  model为value
    //以时间排序，筛选需要进行刷新的
    
    NSMutableDictionary * appendDic;
    //新增的字典，以create时间排序  认为create时间不存在完全相同的
    
    NSInteger maxLength;
}
@property (nonatomic, strong) NSString * requestOrderList;
@property (nonatomic, strong) NSString * showOrderList;

@property (nonatomic, strong) NSArray * listReqArr;
@end

@implementation ZWPanicRefreshController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        cacheDic = [[NSMutableDictionary alloc] init];
        appendDic = [[NSMutableDictionary alloc] init];
        maxLength = 3000 * 100;
//        maxLength = 3000;
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
    
    ZWPanicRefreshManager * manager = [ZWPanicRefreshManager sharedInstance];
    self.requestOrderList = manager.cacheReqeustStr;
    self.showOrderList =  manager.cacheShowStr;
    if(manager.showArr)
    {
        [self refreshTableViewWithInputLatestListArray:manager.showArr replace:NO];
    }
    
}
-(NSArray *)latestRefreshRequestDetailUrls
{
    NSMutableArray * urls = [NSMutableArray array];
    
    NSMutableDictionary * addDic = [NSMutableDictionary dictionary];
    @synchronized (appendDic)
    {
        [addDic addEntriesFromDictionary:appendDic];
        [appendDic removeAllObjects];
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
        
        NSInteger maxRefresh = 50;
        if([keys count] > maxRefresh)
        {
            keys = [keys subarrayWithRange:NSMakeRange(0, maxRefresh)];
        }
        
        for (NSInteger index = 0;index < [keys count] ;index ++ )
        {
            NSString * modelKey = [keys objectAtIndex:index];
            Equip_listModel * eveObj = [cacheDic objectForKey:modelKey];
            [urls addObject:eveObj];
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
    
    
    ZWPanicRefreshManager * cache = [ZWPanicRefreshManager sharedInstance];
    cache.cacheShowStr = self.showOrderList;
    cache.cacheReqeustStr = self.requestOrderList;
    cache.showArr = self.showArray;
    
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
-(void)refreshCurrentTitleVLableWithFinishWithStartListNumber:(NSInteger)number
{
    self.titleV.text = [NSString stringWithFormat:@"近期改价 (%ld)",(long)number];
}

-(void)startRefreshLatestDetailModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    EquipDetailArrayRequestModel * listRequest = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(listRequest.executing) return;
    
//    NSLog(@"%s",__FUNCTION__);

    
    NSArray * details = [self latestRefreshRequestDetailUrls];
    [self refreshCurrentTitleVLableWithFinishWithStartListNumber:[details count]];
    
    if(!details || [details count] == 0)
    {
        return;
    }
    self.listReqArr = details;
    
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0; index < [details count] ;index ++ )
    {
        Equip_listModel * list = [details objectAtIndex:index];
        NSString * url = list.detailDataUrl;
        [urls addObject:url];
    }
    
    [self startEquipDetailAllRequestWithUrls:urls];
}


-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    EquipListRequestModel * listRequest = (EquipListRequestModel *)_dpModel;
    if(listRequest.executing) return;
    
//    [requestLock lock];
    
    NSLog(@"%s",__FUNCTION__);
    
    EquipListRequestModel * model = (EquipListRequestModel *)_dpModel;
    //仅做数据刷新，不做展示   详情数据请求中时，列表数据也需要刷新
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[EquipListRequestModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
        model.pageNum = 50;//刷新页数
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
        NSString * orderSN = eveModel.game_ordersn;
        if(eveModel.equipState == CBGEquipRoleState_unSelling)
        {
            [modelsDic setObject:eveModel forKey:orderSN];
        }else if(![self cacheOrDBContainOrderSN:orderSN])
        {//库表和缓存都不存在
            //首次上架的数据，或库表不存在的数据
            [modelsDic setObject:eveModel forKey:orderSN];
            [self checkRequestOrderListAndAddMoreOrderSn:orderSN];
        }
    }
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * backRefreshArr = [modelsDic allValues];
    if([backRefreshArr count] > 0)
    {
        //进行库表查询，取出创建时间
        NSMutableDictionary * currentDic = [NSMutableDictionary dictionary];
        NSArray * orderArr = [modelsDic allKeys];
        for (NSInteger index = 0 ;index < [orderArr count]; index ++ )
        {
            NSString * eveSn = [orderArr objectAtIndex:index];
            NSArray * modelsArr = [dbManager localSaveMakeOrderHistoryListForOrderSN:eveSn];
            if([modelsArr count] > 0)
            {
                Equip_listModel * listObj = [modelsDic objectForKey:eveSn];
                CBGListModel * eveCBG = [modelsArr firstObject];
                NSString * time = eveCBG.sell_create_time;
                
                listObj.appendHistory = eveCBG;
                [currentDic setObject:listObj forKey:time];
            }else
            {
                Equip_listModel * listObj = [modelsDic objectForKey:eveSn];
                [currentDic setObject:listObj forKey:eveSn];
            }
        }
        
        @synchronized (appendDic)
        {
            [appendDic addEntriesFromDictionary:currentDic];
        }
    }
    
//    [requestLock unlock];
}
#pragma mark - CacheOrderSN
//检查长度，追加新ordersn，当做缓存使用
-(void)checkRequestOrderListAndAddMoreOrderSn:(NSString *)orderSN
{
    NSString * preList = self.requestOrderList;
    if(!preList){
        preList = @"";
    }
    preList = [preList stringByAppendingFormat:@"%@|",orderSN];
    
    if([preList length] > maxLength)
    {
        NSRange range = [preList rangeOfString:@"|"];
        preList = [preList substringFromIndex:range.location + range.length];
    }
    self.requestOrderList = preList;
}

-(void)checkShowOrderListAndAddMoreOrderSn:(NSString *)orderSN
{
    NSString * preList = self.showOrderList;
    if(!preList){
        preList = @"";
    }
    preList = [preList stringByAppendingFormat:@"%@|",orderSN];
    
    if([preList length] > maxLength)
    {
        NSRange range = [preList rangeOfString:@"|"];
        preList = [preList substringFromIndex:range.location + range.length];
    }
    self.showOrderList = preList;
}
-(BOOL)cacheOrDBContainOrderSN:(NSString *)orderSn
{
    BOOL contain = YES;
    
    NSRange range = [self.requestOrderList rangeOfString:orderSn];
    if(range.length == 0 && !self.ingoreFirst)
    {//进行库表检查
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        NSArray * dbArr = [dbManager localSaveUserChangeHistoryListForOrderSN:orderSn];
        if([dbArr count] == 0 || !dbArr)
        {
            contain = NO;
        }
    }
    return contain;
}

#pragma mark -


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
    
    NSLog(@"EquipDetailArrayRequestModel  Success %lu",(unsigned long)[detailModels count]);
    
    NSMutableArray * removeArr = [NSMutableArray array];
    NSMutableArray * showArr  = [NSMutableArray array];
    
    NSArray * models = self.listReqArr;
    for (NSInteger index = 0; index < [models count]; index ++)
    {
        EquipModel * detailEve = nil;
        if([detailModels count] > index)
        {
            detailEve = [detailModels objectAtIndex:index];
        }
        Equip_listModel * obj = [models objectAtIndex:index];
        Equip_listModel * objCopy = [obj copy];
        if(![detailEve isKindOfClass:[NSNull class]])
        {
            objCopy.equipModel = detailEve;
            objCopy.earnRate = detailEve.extraEarnRate;
            if(objCopy.earnRate > 0)
            {
                objCopy.earnPrice = [NSString stringWithFormat:@"%.0f",[detailEve.equipExtra.buyPrice floatValue] - [detailEve.price floatValue]/100.0 - [detailEve.equipExtra.buyPrice floatValue] * 0.05];
            }
            if(!detailEve.equipExtra.buyPrice)
            {
                NSLog(@"失败 %@",objCopy.detailDataUrl);
            }
            
            if(detailEve.equipState != CBGEquipRoleState_unSelling)
            {
                [removeArr addObject:objCopy];
            }
            
            //当前处于未上架、或者首次上架，进行展示
            if([objCopy isFirstInSelling]&&!self.ingoreFirst)
            {
                NSString * orderSN = objCopy.game_ordersn;
                NSRange range = [self.showOrderList rangeOfString:orderSN];
                if(range.length == 0)
                {
                    [showArr addObject:objCopy];
                    [self checkShowOrderListAndAddMoreOrderSn:orderSN];
                }
            }else if(detailEve.equipState == CBGEquipRoleState_unSelling)
            {
                NSString * orderSN = objCopy.game_ordersn;
                NSRange range = [self.showOrderList rangeOfString:orderSN];
                if(range.length == 0)
                {
                    [showArr insertObject:objCopy atIndex:0];
                    [self checkShowOrderListAndAddMoreOrderSn:orderSN];
                }
            }else if(objCopy.equipState == CBGEquipRoleState_unSelling)
            {//列表数据是未上架，进行展示
                [showArr insertObject:objCopy atIndex:0];
            }
        }
    }
    
    //全部数据进行库表存储
    NSMutableArray * updateArr = [NSMutableArray array];
    for (NSInteger index = 0;index < [models count] ;index ++ )
    {
        Equip_listModel * list = [models objectAtIndex:index];
        if(list.equipModel)
        {
            CBGListModel * cbgList = [list listSaveModel];
            cbgList.dbStyle = CBGLocalDataBaseListUpdateStyle_UpdateTime;
            [updateArr addObject:cbgList];
        }
    }
    
    if(!self.ingoreFirst)
    {
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:updateArr];
    }
    
    @synchronized (cacheDic)
    {
        for (NSInteger index = 0 ;index < [removeArr count] ;index ++ )
        {
            Equip_listModel * eveObj = [removeArr objectAtIndex:index];
            //当前以时间发起的请求，而展示数组  进行展示
            
            NSString * eveKey = eveObj.equipModel.create_time;
            [cacheDic removeObjectForKey:eveKey];
            
            eveKey = eveObj.game_ordersn;
            [cacheDic removeObjectForKey:eveKey];
        }
    }
    
    @synchronized (appendDic)
    {
        for (NSInteger index = 0 ;index < [removeArr count] ;index ++ )
        {
            Equip_listModel * eveObj = [removeArr objectAtIndex:index];
            //当前以时间发起的请求，而展示数组  进行展示
            
            NSString * eveKey = eveObj.equipModel.create_time;
            [appendDic removeObjectForKey:eveKey];
            
            eveKey = eveObj.game_ordersn;
            [cacheDic removeObjectForKey:eveKey];
        }
    }
    
    
    NSLog(@"Refresh ShowArr %lu",(unsigned long)[showArr count]);

    [self refreshTableViewWithInputLatestListArray:showArr replace:NO];
    
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
