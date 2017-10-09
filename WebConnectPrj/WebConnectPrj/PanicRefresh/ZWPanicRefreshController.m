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
#import "MSAlertController.h"
#import "ZAPanicSortSchoolVC.h"
#import "YYCache.h"
@interface ZWPanicRefreshController ()
{
    NSMutableDictionary * cacheDic;//以时间为key  model为value
    //以时间排序，筛选需要进行刷新的
    
    NSMutableDictionary * appendDic;
    //新增的字典，以create时间排序  认为create时间不存在完全相同的
    
    NSCache * listOrderCache;
    YYCache * listShowCache;
    NSInteger maxLength;
}
@property (nonatomic, strong) NSArray * listReqArr;
//@property (nonatomic, assign) NSInteger requestNum;
@end

@implementation ZWPanicRefreshController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        cacheDic = [[NSMutableDictionary alloc] init];
        //detail的缓存，ordersn：CBGListModel
        
        appendDic = [[NSMutableDictionary alloc] init];
        //传递ordersn：createTime
        
        listOrderCache = [[NSCache alloc] init];
        listOrderCache.countLimit = 1300;
        listOrderCache.totalCostLimit = 1300;
        //缓存cache，减少库表查询次数
        
        listShowCache = [YYCache cacheWithName:@"YY_Cache_List_Show"];
        listShowCache.diskCache.countLimit = 10;
        listShowCache.diskCache.costLimit = 10;
        
        listShowCache.memoryCache.countLimit = 10;
        listShowCache.memoryCache.costLimit = 10;
        //展示缓存cache
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        
        NSArray * preArr = [total.orderSnCache componentsSeparatedByString:@"|"];
        NSDictionary * addDic = [self readLocalCacheDetailListFromLocalDBWithArrr:preArr];
        [cacheDic addEntriesFromDictionary:addDic];
        
        maxLength = 30 * 100;
        
        self.requestNum = 100;
    }
    return self;
}
-(NSDictionary *)readLocalCacheDetailListFromLocalDBWithArrr:(NSArray *)orderArr
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSMutableDictionary * readDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0;index < [orderArr count] ;index ++ )
    {
        NSString * order = [orderArr objectAtIndex:index];
        NSArray * arr = [dbManager localSaveEquipHistoryModelListForOrderSN:order];
        if([arr count] > 0)
        {
            CBGListModel * cbgList = [arr lastObject];
            Equip_listModel * list = [[Equip_listModel alloc] init];
            list.serverid = [NSNumber numberWithInteger:cbgList.server_id];
            list.game_ordersn = cbgList.game_ordersn;
            
            [readDic setObject:list forKey:order];
        }
    }
    return readDic;
}

-(BOOL)checkEquipModelCacheStatusWithLatestModel:(Equip_listModel *)list
{
    BOOL contain = YES;
    NSString * orderSn = list.game_ordersn;
    id obj = [listOrderCache objectForKey:orderSn];
    if(!obj)
    {
        //cache不存在，进行库表查询
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        NSArray * arr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSn];
        
        if([arr count] > 0){
            //价格不一致，价格改变很快，20s内修改
            CBGListModel * local = [arr firstObject];
            if([list.price integerValue] > 0 && local.equip_price != [list.price integerValue])
            {
                contain = NO;
            }
        }else{
            contain = NO;
        }
    }
    return contain;
}

- (void)viewDidLoad
{
    self.viewTtle = @"近期改价";
    self.rightTitle = @"筛选";
    self.showRightBtn = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ZWPanicRefreshManager * manager = [ZWPanicRefreshManager sharedInstance];
    if(manager.showArr)
    {
        [self refreshTableViewWithInputLatestListArray:nil cacheArray:manager.showArr];
    }
}

-(void)refreshLatestMinRequestPageNumber:(NSInteger)pageNum
{
    self.requestNum = pageNum;
}


-(void)submit
{
    NSString * log = [NSString stringWithFormat:@"对刷新数据设置？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"50页数据" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf refreshLatestMinRequestPageNumber:50];
                             }];
    [alertController addAction:action];
    
    
    action = [MSAlertAction actionWithTitle:@"100页数据" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestMinRequestPageNumber:100];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"20页数据" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestMinRequestPageNumber:20];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"门派设定" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf tapedOnSelectedSortSchool];
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
-(void)tapedOnSelectedSortSchool
{
    ZAPanicSortSchoolVC * sort = [[ZAPanicSortSchoolVC alloc] init];
    [[self rootNavigationController] pushViewController:sort animated:YES];
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
    _detailArrModel = nil;
    _dpModel = nil;
    [self startLocationDataRequest];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s disappear",__FUNCTION__);
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    EquipDetailArrayRequestModel * detailRefresh = (EquipDetailArrayRequestModel *)_detailArrModel;
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
    cache.showArr = self.dataArr;
    
    @synchronized (cacheDic)
    {
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        NSArray * arr = [cacheDic allKeys];
        total.orderSnCache = [arr componentsJoinedByString:@"|"];
        [total localSave];
    }
    
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
    
    EquipDetailArrayRequestModel * listRequest = (EquipDetailArrayRequestModel *)_detailArrModel;
    if(listRequest.executing) return;
    
//    NSLog(@"%s",__FUNCTION__);

    
    NSArray * details = [self latestRefreshRequestDetailUrls];
    [self refreshCurrentTitleVLableWithFinishWithStartListNumber:[details count]];
    
    if(!details || [details count] == 0)
    {
        return;
    }
    self.listReqArr = details;
    
    NSMutableArray * orderArr = [NSMutableArray array];
    
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0; index < [details count] ;index ++ )
    {
        Equip_listModel * list = [details objectAtIndex:index];
        NSString * url = list.detailDataUrl;
        [urls addObject:url];
        [orderArr addObject:list.game_ordersn];
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
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        NSInteger school = total.refreshSchool;
//        if(school > 0)
//        {
//            model.selectSchool = school;
//        }
//        model.priceStatus = total.refreshPriceStatus;
        model.pageNum = self.requestNum;//刷新页数
    }
    
    [model sendRequest];
}
-(void)autoRefreshListRequestNumberWithLatestBackNumber:(NSInteger)totalNum
{
    //请求参数自动调整
    if(totalNum == 0) return;
    
    NSInteger prePage = self.requestNum;
    NSInteger needNum = totalNum/15;
    NSInteger refreshNum = needNum + 2;
    
    if(prePage > needNum && prePage < refreshNum)
    {
        return;
    }
    
    //当前的，大于需要的+5页时，进行调整
    if(prePage > refreshNum)
    {
        [self refreshLatestMinRequestPageNumber:refreshNum];
    }else
    {//设定最大100页
        refreshNum = MIN(refreshNum, 100);
        [self refreshLatestMinRequestPageNumber:refreshNum];
    }
    
    
    EquipListRequestModel * refresh = (EquipListRequestModel *)_dpModel;
    [refresh cancel];
    [refresh removeSignalResponder:self];
    _dpModel = nil;
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
        }else if(![self checkEquipModelCacheStatusWithLatestModel:eveModel])
        {//库表和缓存都不存在
            //首次上架的数据，或库表不存在的数据
            [modelsDic setObject:eveModel forKey:orderSN];
            [listOrderCache setObject:[NSNumber numberWithInt:0] forKey:orderSN];
        }
    }
    
    NSArray * backRefreshArr = [modelsDic allValues];
    if([backRefreshArr count] > 0)
    {
        @synchronized (appendDic)
        {
            [appendDic addEntriesFromDictionary:modelsDic];
        }
    }
    
    //有时候会因为部分请求失败，造成检索范围有误
    [self autoRefreshListRequestNumberWithLatestBackNumber:[array count]];
}
#pragma mark - CacheOrderSN

#pragma mark -


-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
    NSLog(@"%s",__FUNCTION__);
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailArrModel;
    if(!model){
        model = [[EquipDetailArrayRequestModel alloc] init];
        [model addSignalResponder:self];
        _detailArrModel = model;
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
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *) _detailArrModel;
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
    
    NSLog(@"EquipDetailArrayRequestModel  Panic %lu",(unsigned long)[detailModels count]);
    
    NSMutableArray * removeArr = [NSMutableArray array];
    NSMutableArray * showArr  = [NSMutableArray array];
    NSMutableArray * cacheArr  = [NSMutableArray array];

    NSArray * models = self.listReqArr;
    for (NSInteger index = 0; index < [models count]; index ++)
    {
        EquipModel * detailEve = nil;
        if([detailModels count] > index)
        {
            detailEve = [detailModels objectAtIndex:index];
        }
        Equip_listModel * obj = [models objectAtIndex:index];
        
        if(![detailEve isKindOfClass:[NSNull class]])
        {
            if(!detailEve.game_ordersn){
                continue;
            }

//            obj.listSaveModel = nil;
            obj.equipModel = detailEve;
            CBGListModel * list = obj.listSaveModel;
            obj.earnRate = list.plan_rate;
            obj.earnPrice = [NSString stringWithFormat:@"%.0ld",list.price_earn_plan];
            
            if(list.plan_total_price == 0)
            {
                NSLog(@"失败 %@",obj.detailDataUrl);
            }
            
            Equip_listModel * objShow = [obj copy];
            objShow.equipModel= detailEve;
            
            //当前处于未上架进行展示
            if(detailEve.equipState == CBGEquipRoleState_unSelling)
            {//详情数据处于暂存
                
                if(detailEve.equipExtra.totalPrice > 1000)
                {
                    [cacheArr addObject:objShow];
                    
                    //处于缓存区域的，不再进行列表展示
                    NSString * orderSN = obj.game_ordersn;
                    [listShowCache  removeObjectForKey:orderSN];
                }else
                {
                    [removeArr addObject:objShow];
                }

            }else
            {
                //详情数据不处于暂存的，即将清除
                [removeArr addObject:objShow];
                if(obj.equipState == CBGEquipRoleState_unSelling)
                {//列表数据是未上架，详情数据已经上架，仅展示
                    NSString * orderSN = obj.game_ordersn;
                    if(![listShowCache objectForKey:orderSN])
                    {
                        [showArr insertObject:objShow atIndex:0];
                        [listShowCache setObject:[NSNumber numberWithInt:0] forKey:orderSN];
                    }
                }else if(detailEve.equipExtra.totalPrice > [detailEve.price integerValue]/100 * 0.9)
                {
                    NSString * orderSN = obj.game_ordersn;
                    if(![listShowCache objectForKey:orderSN])
                    {
                        [showArr addObject:objShow];
                        [listShowCache setObject:[NSNumber numberWithInt:0] forKey:orderSN];
                    }
                }else
                {
                    NSLog(@"detailDataUrl %@",[obj detailDataUrl]);
                }
            }
        }else
        {//详情请求失败
            [listOrderCache removeObjectForKey:obj.game_ordersn];
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
            cbgList.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPrice;
            
            if(list.equipModel.equipState != CBGEquipRoleState_unSelling)
            {
                [updateArr addObject:cbgList];
            }
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
            
            NSString * eveKey = nil;
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
            
            NSString * eveKey = nil;
            
            eveKey = eveObj.game_ordersn;
            [appendDic removeObjectForKey:eveKey];
        }
    }
    
    
    NSLog(@"Refresh ShowArr %lu",(unsigned long)[showArr count]);

    [self refreshTableViewWithInputLatestListArray:showArr cacheArray:cacheArr];
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
