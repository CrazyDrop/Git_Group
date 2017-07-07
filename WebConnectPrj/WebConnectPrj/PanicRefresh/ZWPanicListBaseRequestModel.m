//
//  ZWPanicListBaseRequestModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/12.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicListBaseRequestModel.h"
#import "ZALocalModelDBManager.h"
#import "EquipDetailArrayRequestModel.h"
#import "EquipListRequestModel.h"
#import "Equip_listModel.h"
#import "ZWPanicRefreshManager.h"
#import "YYCache.h"

@interface ZWPanicListBaseRequestModel()
{
    //以时间排序，筛选需要进行刷新的
    
    NSMutableDictionary * appendDic;
    //新增的字典，以create时间排序  认为create时间不存在完全相同的
    
    NSCache * listOrderCache;
    YYCache * listShowCache;
    NSInteger maxLength;
    
    
    
    EquipDetailArrayRequestModel * _detailListReqModel;
    EquipListRequestModel * _dpModel;
}
@property (nonatomic, assign) NSInteger schoolNum;
@property (nonatomic, assign) NSInteger priceStatus;

@property (nonatomic, assign) NSInteger requestNum;
@property (nonatomic, strong) NSArray * listReqArr;
@property (nonatomic, strong) NSArray * modelCacheArr;

@property (nonatomic, assign) NSInteger errorTotal;

@property (nonatomic, assign) NSInteger detailError;
@end

@implementation ZWPanicListBaseRequestModel
-(id)init
{
    self = [super init];
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
        
        maxLength = 30 * 100;
        
        self.requestNum = 50;
    
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
            list.equip_status = @1;
            [readDic setObject:list forKey:order];
        }
    }
    return readDic;
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
        
        NSInteger maxRefresh = 30;
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
-(NSArray *)dbLocalSaveTotalList
{
    NSArray * listArr = [dbManager localSaveEquipHistoryModelListTotal];
    return listArr;
}
-(void)localSaveDBUpdateEquipListWithArray:(NSArray *)arr
{
    [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:arr];
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
            list.appendHistory = local;
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

-(void)prepareWebRequestParagramForListRequest
{
    dbManager = [[ZALocalModelDBManager alloc] initWithDBExtendString:_tagString];
    
    NSArray * tagArr = [_tagString componentsSeparatedByString:@"_"];
    if([tagArr count] == 2)
    {
        self.schoolNum = [[tagArr firstObject] integerValue];
        self.priceStatus = [[tagArr lastObject] integerValue];
    }
    
    //读取对应数据填充到缓存中
    if([self.cacheArr count] > 0){
        NSDictionary * dataDic = [self readLocalCacheDetailListFromLocalDBWithArrr:self.cacheArr];
        [cacheDic addEntriesFromDictionary:dataDic];
    }
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
//    [self refreshCurrentTitleVLableWithFinishWithStartListNumber:[details count]];
    
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
-(void)stopRefreshRequestAndClearRequestModel
{
    EquipDetailArrayRequestModel * detailRefresh = (EquipDetailArrayRequestModel *)_detailListReqModel;
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
    
    EquipListRequestModel * refresh = (EquipListRequestModel *)_dpModel;
    [refresh cancel];
    [refresh removeSignalResponder:self];
    
    _detailListReqModel = nil;
    _dpModel = nil;
}

-(void)refreshLatestMinRequestPageNumber:(NSInteger)pageNum
{
    self.requestNum = pageNum;
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
    [self refreshListRequestErrorWithFinishDelagateWithError:[NSError errorWithDomain:NSURLErrorDomain code:100 userInfo:nil]];
}
handleSignal( EquipListRequestModel, requestLoading )
{
}


handleSignal( EquipListRequestModel, requestLoaded )
{
    //    refreshLatestTotalArra
    NSLog(@"%s",__FUNCTION__);
    
    EquipListRequestModel * model = (EquipListRequestModel *) _dpModel;
    NSArray * total  = model.listArray;
    self.errorTotal = model.errNum;
    
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
    [self refreshListRequestErrorWithFinishDelagateWithError:[NSError errorWithDomain:NSURLErrorDomain code:100 userInfo:nil]];
}
handleSignal( EquipDetailArrayRequestModel, requestLoading )
{
}

handleSignal( EquipDetailArrayRequestModel, requestLoaded )
{
    NSLog(@"%s",__FUNCTION__);
    
    //进行存储操作、展示
    //列表数据，部分成功部分还失败，对于成功的数据，刷新展示，对于失败的数据，继续请求
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *) _detailListReqModel;
    NSArray * total  = model.listArray;
    
    NSMutableArray * detailModels = [NSMutableArray array];
    NSInteger errorNum = 0;
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            [detailModels addObject:[obj firstObject]];
        }else{
            errorNum ++;
            [detailModels addObject:[NSNull null]];
        }
    }
    
    NSLog(@"EquipDetailArrayRequestModel  Panic  %@ %lu(%lu)",self.tagString,(unsigned long)[detailModels count],errorNum);
    
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
            
            obj.listSaveModel = nil;
            obj.equipModel = detailEve;

            Equip_listModel * objShow = [obj copy];
            objShow.equipModel= detailEve;
            
            objShow.listSaveModel = nil;
            //当前处于未上架进行展示，并且非时间自动超时
            if(detailEve.equipState == CBGEquipRoleState_unSelling)
            {//详情数据处于暂存
                
                if(![objShow isAutoStopSelling])
                {
                    [cacheArr addObject:objShow];
                    
                    //处于缓存区域的，不再进行列表展示，确保下次可在列表展示
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
                }else if(detailEve.equipExtra.totalPrice > [detailEve.price integerValue]/100 * 0.90)
                {//相近数据，留作参考
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
            //对于失败的请求，单体刷新的数据也需要展示
            [listOrderCache removeObjectForKey:obj.game_ordersn];
            if(obj.equipState == CBGEquipRoleState_unSelling)
            {
                [cacheArr addObject:obj];
                
                //处于缓存区域的，不再进行列表展示，确保下次可在列表展示
                NSString * orderSN = obj.game_ordersn;
                [listShowCache  removeObjectForKey:orderSN];

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
    
    
    NSLog(@"Refresh ShowArr %lu %lu",(unsigned long)[showArr count],[cacheArr count]);
    
    
    if([showArr count] > 0 || [self.modelCacheArr count] != [cacheArr count])
    {
        self.modelCacheArr = cacheArr;
        [self refreshTableViewWithInputLatestListArray:showArr cacheArray:cacheArr];
    }else
    {
        
    }
}
-(void)refreshListRequestErrorWithFinishDelagateWithError:(NSError *)error
{
    if(self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(panicListRequestFinishWithModel:withListError:)])
    {
        [self.requestDelegate panicListRequestFinishWithModel:self
                                                withListError:error];
    }

}

//刷新列表数据
-(void)refreshTableViewWithInputLatestListArray:(NSArray *)array  cacheArray:(NSArray *)cacheArr
{
    if(self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(panicListRequestFinishWithModel:listArray:cacheArray:)])
    {
        [self.requestDelegate panicListRequestFinishWithModel:self
                                                    listArray:array
                                                   cacheArray:cacheArr];
    }
}



@end
