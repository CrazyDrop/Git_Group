//
//  ZWPaincCombineBaseVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPaincCombineBaseVC.h"
#import "ZALocalModelDBManager.h"
#import "EquipDetailArrayRequestModel.h"
#import "EquipListRequestModel.h"
#import "Equip_listModel.h"
#import "CBGDetailWebView.h"
#import "ZALocationLocalModel.h"
#import "ZWPanicRefreshManager.h"
#import "MSAlertController.h"
#import "ZAPanicSortSchoolVC.h"
#import "YYCache.h"

@interface ZWPaincCombineBaseVC ()
{
    NSMutableDictionary * cacheDic;//以时间为key  model为value
    //以时间排序，筛选需要进行刷新的
    
    NSMutableDictionary * appendDic;
    //新增的字典，以create时间排序  认为create时间不存在完全相同的
    
    NSCache * listOrderCache;
    YYCache * listShowCache;
    NSInteger maxLength;
    
    ZALocalModelDBManager  * dbManager;
}
@property (nonatomic, assign) NSInteger schoolNum;
@property (nonatomic, assign) NSInteger priceStatus;
@property (nonatomic, strong) NSString * showName;

@property (nonatomic, assign) NSInteger requestNum;
@property (nonatomic, strong) NSArray * listReqArr;
//@property (nonatomic, assign) NSInteger requestNum;

@property (nonatomic, assign) BOOL refreshState;
@end

@implementation ZWPaincCombineBaseVC
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
        
//        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//        
//        NSArray * preArr = [total.orderSnCache componentsSeparatedByString:@"|"];
//        NSDictionary * addDic = [self readLocalCacheDetailListFromLocalDBWithArrr:preArr];
//        [cacheDic addEntriesFromDictionary:addDic];
        
        maxLength = 30 * 100;
        
        self.refreshState = YES;
        self.requestNum = 100;
    }
    return self;
}
-(NSDictionary *)readLocalCacheDetailListFromLocalDBWithArrr:(NSArray *)orderArr
{
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
    
    self.viewTtle = _tagString;
    self.rightTitle = @"筛选";
    self.showRightBtn = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dbManager = [[ZALocalModelDBManager alloc] initWithDBExtendString:_tagString];
    
    NSArray * tagArr = [_tagString componentsSeparatedByString:@"_"];
    if([tagArr count] == 2)
    {
        self.schoolNum = [[tagArr firstObject] integerValue];
        self.priceStatus = [[tagArr lastObject] integerValue];
    }
    
    NSString * tagName = [CBGListModel schoolNameFromSchoolNumber:self.schoolNum];
    NSString * refreshName = [tagName stringByAppendingFormat:@"-%ld",self.priceStatus];
    self.showName = refreshName;
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
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"停止刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf refreshTitleWithRefreshState:NO];
                             }];
    [alertController addAction:action];
    
    
    action = [MSAlertAction actionWithTitle:@"开始刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshTitleWithRefreshState:YES];
              }];
    [alertController addAction:action];
    
//    action = [MSAlertAction actionWithTitle:@"20页数据" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
//              {
//                  [weakSelf refreshLatestMinRequestPageNumber:20];
//              }];
//    [alertController addAction:action];
//    
//    action = [MSAlertAction actionWithTitle:@"门派设定" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
//              {
//                  [weakSelf tapedOnSelectedSortSchool];
//              }];
//    [alertController addAction:action];
    
    
    
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

    _detailListReqModel = nil;
    _dpModel = nil;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s disappear",__FUNCTION__);
    [super viewWillDisappear:animated];
    
    EquipDetailArrayRequestModel * detailRefresh = (EquipDetailArrayRequestModel *)_detailListReqModel;
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
    
    EquipListRequestModel * refresh = (EquipListRequestModel *)_dpModel;
    [refresh cancel];
    [refresh removeSignalResponder:self];
    
    
    
    
//    ZWPanicRefreshManager * cache = [ZWPanicRefreshManager sharedInstance];
//    cache.showArr = self.dataArr;
    
    @synchronized (cacheDic)
    {
//        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//        NSArray * arr = [cacheDic allKeys];
//        total.orderSnCache = [arr componentsJoinedByString:@"|"];
//        [total localSave];
    }
    
}
-(void)refreshTitleWithRefreshState:(BOOL)refresh
{
    self.refreshState = refresh;
    self.titleV.text = refresh?@"开始刷新":@"停止刷新";
}

-(void)refreshCurrentTitleVLableWithFinishWithStartListNumber:(NSInteger)number
{
    self.titleV.text = [NSString stringWithFormat:@"%@ (%ld)",self.showName,(long)number];
}

-(void)startRefreshLatestDetailModelRequest
{
    if(!self.refreshState){
        return;
    }
    
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
    if(!self.refreshState){
        return;
    }
    
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    EquipListRequestModel * listRequest = (EquipListRequestModel *)_dpModel;
    if(listRequest.executing) return;
    
    //    [requestLock lock];
    
    NSLog(@"%s %@",__FUNCTION__,_tagString);
    
    EquipListRequestModel * model = (EquipListRequestModel *)_dpModel;
    //仅做数据刷新，不做展示   详情数据请求中时，列表数据也需要刷新
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[EquipListRequestModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;

        if(self.schoolNum > 0){
         model.selectSchool = self.schoolNum;
        }
        model.priceStatus = self.priceStatus;
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
            obj.earnRate = detailEve.extraEarnRate;
            
            if(obj.earnRate > 0)
            {
                obj.earnPrice = [NSString stringWithFormat:@"%.0f",[detailEve.equipExtra.buyPrice floatValue] - [detailEve.price floatValue]/100.0 - [detailEve.equipExtra.buyPrice floatValue] * 0.05];
            }
            if(!detailEve.equipExtra.buyPrice)
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
                }else if(detailEve.equipExtra.totalPrice > [detailEve.price integerValue]/100 - 300)
                {
                    NSString * orderSN = obj.game_ordersn;
                    if(![listShowCache objectForKey:orderSN])
                    {
                        [showArr addObject:objShow];
                        [listShowCache setObject:[NSNumber numberWithInt:0] forKey:orderSN];
                    }
                }else
                {
//                    NSLog(@"detailDataUrl %@",[obj detailDataUrl]);
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
    
    {
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
