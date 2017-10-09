//
//  ZWPanicUpdateLatestModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/9/5.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicUpdateLatestModel.h"
#import "Equip_listModel.h"
#import "EquipListRequestModel.h"
#import "ZWOperationEquipReqListReqModel.h"
#import "VPNProxyModel.h"
#import "DZUtils.h"
#import "RoleDataModel.h"
#import "SessionReqModel.h"
#import "YYCache.h"
@interface ZWPanicUpdateLatestModel ()
{
    
    NSInteger maxLength;
    YYCache * detailCache;
    NSOperationQueue * checkQueue;
}
@property (nonatomic, strong) NSDate * lineDate;

@property (nonatomic, assign) NSInteger schoolNum;
@property (nonatomic, assign) NSInteger priceStatus;

@property (nonatomic, assign) NSInteger requestNum;
@property (nonatomic, strong) NSArray * listReqArr;
@property (nonatomic, strong) NSArray * modelCacheArr;

@property (nonatomic, assign) NSInteger errorTotal;

@property (nonatomic, assign) NSInteger detailError;
@property (nonatomic, strong) NSString * schoolName;

@property (nonatomic, strong) NSMutableDictionary * finishDic;
@property (nonatomic, assign) NSInteger cacheNum;
@property (nonatomic, strong) NSMutableArray * timeCacheArray;
@end

@implementation ZWPanicUpdateLatestModel
+ (NSOperationQueue *)zw_sharedGroupRequestOperationQueue
{
    static NSOperationQueue *_zw_sharedGroupRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _zw_sharedGroupRequestOperationQueue = [[NSOperationQueue alloc] init];
        _zw_sharedGroupRequestOperationQueue.maxConcurrentOperationCount = 30;
    });
    
    return _zw_sharedGroupRequestOperationQueue;
}

-(void)stopRefreshRequestAndClearRequestModel
{
    [checkQueue cancelAllOperations];
    
    ZWOperationEquipReqListReqModel * detailRefresh = (ZWOperationEquipReqListReqModel *)_detailListReqModel;
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
    
    ZWOperationEquipReqListReqModel * refresh = (ZWOperationEquipReqListReqModel *)_dpModel;
    [refresh cancel];
    [refresh removeSignalResponder:self];
    
    _detailListReqModel = nil;
    _dpModel = nil;
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

-(void)prepareWebRequestParagramForListRequest
{
    NSArray * tagArr = [_tagString componentsSeparatedByString:@"_"];
    if([tagArr count] == 2)
    {
        self.schoolNum = [[tagArr firstObject] integerValue];
        self.priceStatus = [[tagArr lastObject] integerValue];
        self.schoolName = [CBGListModel schoolNameFromSchoolNumber:self.schoolNum];
    }
    detailCache = [[YYCache alloc] initWithName:[NSString stringWithFormat:@"cache_%@",_tagString]];
    [detailCache removeAllObjects];

    dbManager = [[ZALocalModelDBManager alloc] initWithDBExtendString:_tagString];
    
    //读取对应数据填充到缓存中
    if([self.cacheArr count] > 0){
        NSDictionary * dataDic = [self readLocalCacheDetailListFromLocalDBWithArrr:self.cacheArr];
        [cacheDic addEntriesFromDictionary:dataDic];
    }
    
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


-(id)init
{
    self = [super init];
    if(self){
        
        self.timeCacheArray = [NSMutableArray array];
        self.finishDic = [NSMutableDictionary dictionary];
        self.requestNum = 25;
        self.cacheNum = 0;
        checkQueue = [[self class] zw_sharedGroupRequestOperationQueue];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(detailRefreshFinishedLocalUpdateAndRemoveWithBackNoti:)
                                                     name:NOTIFICATION_REMOVE_REFRESH_WEBDETAIL_STATE
                                                   object:nil];
    }
    return self;
}
-(void)detailRefreshFinishedLocalUpdateAndRemoveWithBackNoti:(NSNotification *)noti
{
    //希望仅一次进行请求，针对被购买、确实改价的进行移除操作
    NSArray * listArr = (NSArray *)[noti object];
    NSMutableArray * editArr = [NSMutableArray array];
    
//    NSMutableArray * refreshArr = [NSMutableArray array];
//    //筛选自己发起的请求，移除操作
//    @synchronized (self.finishDic)
//    {
//        [refreshArr addObjectsFromArray:[self.finishDic allKeys]];
//    }

    for (Equip_listModel * list in listArr)
    {
        NSString * keyStr = list.listCombineIdfa;
        keyStr = list.game_ordersn;
        NSString * result = (NSString *)[detailCache objectForKey:keyStr];
        if(result && [result integerValue] == 0)
        {
            [editArr addObject:list];
            EquipModel * detail = list.equipModel;
            
            //一些情况下，不进行移除操作，
            //全部进行移除操作的问题、连续请求
            [detailCache removeObjectForKey:keyStr];
            self.cacheNum --;
        }
    }
    
    
    if([editArr count] > 0)
    {
        NSMutableDictionary * editDic = [NSMutableDictionary dictionary];
        for(NSInteger index = 0;index < [editArr count]; index ++)
        {
            Equip_listModel * list = [editArr objectAtIndex:index];
            NSString * keyStr = list.listCombineIdfa;
            keyStr = list.game_ordersn;
            
            //进行库表存储
            CBGEquipRoleState state = list.equipModel.equipState;
            if(state == CBGEquipRoleState_unSelling){
                list.listSaveModel = nil;
            }
            
            if(state == CBGEquipRoleState_PayFinish || state == CBGEquipRoleState_BuyFinish){
                list.listSaveModel = nil;
            }
            
            CBGListModel * cbgModel = [list listSaveModel];
            cbgModel.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;
            cbgModel.listRefresh = NO;//已售出，但是列表内再次刷新
            [editDic setObject:cbgModel forKey:keyStr];
            
        }
        
        //本地保存，子线程内批量保存造成失败，移动位置，移动位置，详情结束后处理
        NSArray * dataArr = [editDic allValues];
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:dataArr];
        [dbManager localSaveUserChangeArrayListWithDetailCBGModelArray:dataArr];
    }
}
//启动请求
-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    ZWOperationEquipReqListReqModel * listRequest = (ZWOperationEquipReqListReqModel *)_dpModel;
    if(listRequest.executing) return;
    
    //    [requestLock lock];
    self.errorTotal = 0;
//    NSLog(@"%s %@ %ld",__FUNCTION__,self.tagString,[localCacheArr count]);
    
    
    ZWOperationEquipReqListReqModel * model = (ZWOperationEquipReqListReqModel *)_dpModel;
    //仅做数据刷新，不做展示   详情数据请求中时，列表数据也需要刷新
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[ZWOperationEquipReqListReqModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    
    if(self.schoolNum > 0){
        model.selectSchool = self.schoolNum;
    }
    model.priceStatus = self.priceStatus;
    model.pageNum = self.requestNum;//刷新页数
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.isProxy)
    {
        ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];
        model.sessionArr = manager.sessionSubCache;
    }
    
    model.timerState = !model.timerState;
    [model sendRequest];
}
-(BOOL)checkDetailListEquipNameWithBackEquipListArray:(NSArray *)list
{
    BOOL compareEqual = YES;
    for (NSInteger index = 0; index < [list count]; index ++) {
        Equip_listModel * eve = [list objectAtIndex:index];
        if(![eve.equip_name isEqualToString:self.schoolName])
        {
            compareEqual = NO;
            break;
        }
    }
    return compareEqual;
}

-(void)refreshProxyArrayWithFinishedListArray:(NSArray *)arr andObj:(SessionReqModel *)opt
{
    ZWProxyRefreshManager * proxyManager = [ZWProxyRefreshManager sharedInstance];
    NSMutableArray * editProxy = [NSMutableArray arrayWithArray:proxyManager.proxyArrCache];
    
    BOOL proxyCheck = NO;
    NSString * compareName = self.schoolName;
    
    Equip_listModel * listModel = [arr firstObject];
    //    Equip_listModel * lastModel = [arr lastObject];
    if(compareName && ![compareName isEqualToString:listModel.equip_name])
    {
        proxyCheck = YES;
    }
    
    if(proxyCheck)
    {
        VPNProxyModel * optModel = opt.proxyModel;
        if([editProxy containsObject:optModel])
        {
            [editProxy removeObject:optModel];
            proxyManager.proxyArrCache = editProxy;
            [proxyManager localRefreshListFileWithLatestProxyList];
        }
        NSLog(@"ingore ip  %@ %@ %@",optModel.idNum,listModel.equip_name,opt.url);
    }
}
#pragma mark ZWOperationEquipReqListReqModel
handleSignal( ZWOperationEquipReqListReqModel, requestError )
{
    //    [self refreshListRequestErrorWithFinishDelagateWithError:[NSError errorWithDomain:NSURLErrorDomain code:100 userInfo:nil]];
}
handleSignal( ZWOperationEquipReqListReqModel, requestLoading )
{
}
handleSignal( ZWOperationEquipReqListReqModel, requestLoaded )
{
    //    refreshLatestTotalArra
    NSLog(@"%s",__FUNCTION__);
    
    ZWOperationEquipReqListReqModel * model = (ZWOperationEquipReqListReqModel *) _dpModel;
    NSArray * total  = [NSArray arrayWithArray:model.listArray];
    NSArray * sessionArr = model.baseReqModels;
    NSArray * proxyErr = model.errorProxy;
    
    NSInteger minPageNum = 0;
    NSInteger maxPageNum = 0;
    NSInteger errorNum = 0;
    //正常序列，检查代理缓存数据，计算下次请求页数
    //数据判定、页码判定
    NSMutableDictionary * dataObjDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = index;
        NSArray * dataObj = [total objectAtIndex:backIndex];
        RoleDataModel * roleObj = nil;
        if([dataObj isKindOfClass:[NSArray class]] && [dataObj count] > 0){
            roleObj = [dataObj lastObject];
        }
        id obj = roleObj.equip_list;
        BOOL isLast = [roleObj.is_last_page boolValue];
        if(maxPageNum == 0 && isLast)
        {
            maxPageNum = index;
        }
        
        NSDate * backDate = [NSDate fromString:roleObj.now_time];
        NSTimeInterval count = [[NSDate date] timeIntervalSinceDate:backDate];
        
        SessionReqModel * vpnObj = [sessionArr objectAtIndex:index];
        if(backDate && count > 1*MINUTE)
        {
            errorNum ++;
            vpnObj.proxyModel.errored = YES;//定期移除
        }else if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            minPageNum = index;
            BOOL effective = [self checkDetailListEquipNameWithBackEquipListArray:obj];
            if(effective)
            {
                [dataObjDic setObject:roleObj forKey:[NSString stringWithFormat:@"%ld",index]];
            }else{
                //进行异常处理
                vpnObj.proxyModel.errored = YES;//定期移除
                errorNum ++;
            }
        }else if(isLast)
        {
            
        }else{
            errorNum ++;
        }
    }
    
    NSLog(@"errorProxy %ld errorNum %ld total %ld %@ cacheNum %ld",[proxyErr count],errorNum,[total count],self.tagString,self.cacheNum);
//    self.errorTotal = errorNum;
    NSInteger totalNum = [total count];
    
    //有时候会因为部分请求失败，造成检索范围有误
    [self autoRefreshListRequestNumberWithLatestMaxPageNumber:maxPageNum andMinPageNumber:minPageNum];
    
    
    __weak typeof(self) weakSelf = self;
    void(^listCheckBlock)(void) = ^()
    {
        //读取历史数据，整理库表方便比对
        NSArray * hisArr = [dbManager localSavePanicListHistoryArray];
        NSMutableDictionary * hisDic = [NSMutableDictionary dictionary];
        for (NSInteger index = 0; index < [hisArr count]; index ++) {
            CBGListModel * eve = [hisArr objectAtIndex:index];
            NSString * keyStr = eve.listCombineIdfa;
            keyStr = eve.game_ordersn;
            [hisDic setObject:eve forKey:keyStr];
        }
        
        if([hisArr count] > 0){
            NSLog(@"hisArrTotal %@ %ld %@   %@",weakSelf.tagString,[hisArr count],[[hisArr firstObject] sell_start_time],[[hisArr lastObject] sell_start_time]);
        }

        NSArray * array = [dataObjDic allValues];
        //检查得出未上架的数据
        //列表数据排重，区分未上架数据、价格变动数据
        NSMutableDictionary * webRefreshDic = [NSMutableDictionary dictionary];    //后期详情刷新dic
        NSMutableDictionary * statusDic = [NSMutableDictionary dictionary];     //状态变动，需要刷新dic
        NSMutableDictionary * localRefreshDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
        //筛选出价格变更数据进行展示、状态变更数据进行库表刷新、未上架数据进行详情刷新
        
        for (NSInteger index = 0 ;index < [array count]; index ++ )
        {
            RoleDataModel * eveRole = [array objectAtIndex:index];
            NSArray * roleArr = eveRole.equip_list;
            NSInteger preIndex = NSNotFound;
            BOOL timeError = NO;
            NSString * preDate = nil;//发现差异后，进行比对，检查当前是否是时间错乱数据
            for (NSInteger subIndex = 0;subIndex < [roleArr count] ;subIndex ++ )
            {
                Equip_listModel * eveList = [roleArr objectAtIndex:subIndex];
                NSString * orderSN = eveList.game_ordersn;
                orderSN = eveList.listCombineIdfa;
                orderSN = eveList.game_ordersn;
                CBGListModel * hisCBG = [hisDic objectForKey:orderSN];
                NSInteger latestIndex = NSNotFound;
                if(hisCBG)
                {//检查列表存在//账号时间不变化，不需要更新
                    if([eveList.selling_time isEqualToString:hisCBG.sell_start_time])
                    {//列表账号时间变更、用户上下架
                        latestIndex = [hisArr indexOfObject:hisCBG];
                    }
                    else
                    {
                        //校验数据不存在，进行校验数据刷新
                        NSDate * preListDate = [NSDate fromString:hisCBG.sell_start_time];
                        NSDate * latestDate = [NSDate fromString:eveList.selling_time];
                        if([latestDate timeIntervalSinceDate:preListDate] > 0)
                        {//时间不一致时，排序没意义，视为不存在序号、后续再次刷新重新读取后使用
//                            latestIndex = [hisArr indexOfObject:hisCBG];
                            CBGListModel * eveCBG = [eveList listCompareModel];
                            [changeDic setObject:eveCBG forKey:orderSN];
                            [webRefreshDic setObject:eveList forKey:orderSN];
                        }else
                        {
                            NSLog(@"sell_start_time data error %@ %@ %@ %@",weakSelf.tagString,hisCBG.sell_start_time,eveList.selling_time,eveRole.now_time);
                            timeError = YES;
                        }
                    }
                }else
                {//变更时进行修改，不存在时修改
                    CBGListModel * eveCBG = [eveList listCompareModel];
                    [changeDic setObject:eveCBG forKey:orderSN];
                }
                
                
                if(timeError){//时间异常，放弃此列全部数据
                    continue;
                }
                
                //结束状态，也需要变更，此时认为数据已经结束，关闭校验的检查标识，检查列表的库表数据刷新
                //状态变更时修改
                CBGEquipRoleState latestState = eveList.equipState;
                if(latestState == CBGEquipRoleState_Backing ||
                   latestState == CBGEquipRoleState_PayFinish ||
                   latestState == CBGEquipRoleState_BuyFinish)
                {
                    CBGListModel * eveCBG = [changeDic objectForKey:orderSN];
                    if(!eveCBG){
                        eveCBG = [eveList listCompareModel];
                    }
                    eveCBG.listRefresh = NO;
                    [changeDic setObject:eveCBG forKey:orderSN];
                }
                
                //没有历史数据的，先进行历史数据请求
                NSArray * orderArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
                if([orderArr count] > 0)
                {
                    CBGListModel * pre = [orderArr firstObject];
                    eveList.appendHistory = pre;
                    
                    NSInteger prePirce = pre.equip_price;
                    pre.historyPrice = prePirce;
                    if([eveList.price integerValue] > 0)
                    {
                        pre.equip_price = [eveList.price integerValue];
                        pre.plan_rate = pre.price_rate_latest_plan;
                        
                        eveList.earnPrice = [NSString stringWithFormat:@"%.0ld",pre.price_earn_plan];
                        eveList.earnRate = pre.plan_rate;
                    }
                    
                    if([pre.sell_back_time length] > 0 ||
                       [pre.sell_sold_time length] > 0)
                    {
                        preIndex = latestIndex;
                        preDate = eveList.selling_time;
                        continue;
                    }
                    
                }else
                {
                    //查看库表数据，历史数据不存在
                    [webRefreshDic setObject:eveList forKey:orderSN];

                    preDate = eveList.selling_time;
                    preIndex = latestIndex;
                    continue;
                }
                
                
                //筛选添加，所有数据均有历史数据，否则之前已经重启请求
                if(latestIndex == NSNotFound)//当前的未查找到,进行校验列表写入
                {//筛选检索列表不存在的，进行详情请求
                    
                }else if(preIndex == NSNotFound)
                {//第一个查找到的，和历史时间不一致时，认为是
                    //和历史时间比对，历史时间不一致，进行本地刷新，由于之前放弃了序号读取，理论上没有数据
                    if(![hisCBG.sell_start_time isEqualToString:eveList.selling_time])
                    {
                        [webRefreshDic setObject:eveList forKey:orderSN];
//                        if(eveList.earnRate > 0){
//                        }else
                        {
                            NSLog(@"(preIndex == NSNotFound) %@ %@ %@",eveList.game_ordersn,eveList.selling_time,weakSelf.tagString);
//                            [localRefreshDic setObject:eveList forKey:orderSN];
                        }
                    }
                }
                else if(preIndex != NSNotFound)//前一个，已经查找到
                {//相邻两个均在历史库表存在  之前是0   现在是2，则进行中间数据的读取
                    //查找中间数据，发起详情请求
                    NSInteger sepCount = latestIndex - preIndex;
                    if(sepCount > 1 && sepCount < 15)//针对有连续两个发生变化的情况，之前是 2、3、4参数
                    {// && sepCount < 5  担心  两拨请求之间，出现偏差  理论不会太大
                        NSDate * preIndexDate = [NSDate fromString:preDate];
                        NSDate * latestDate = [NSDate fromString:eveList.selling_time];

                        if(preDate && [preIndexDate timeIntervalSinceDate:latestDate] >= 0 &&
                           (preIndex >= 2 || sepCount <=3 ))
                        {
                            CBGListModel * preCbg = [hisArr objectAtIndex:preIndex];
                            NSLog(@"sepCount %ld %@ preCbg %@(%@) hisCBG %@(%@) %ld %ld",sepCount,weakSelf.tagString,preCbg.game_ordersn,preCbg.sell_start_time,hisCBG.game_ordersn,hisCBG.sell_start_time,preIndex,latestIndex);
                            //进行时间检查，检查上一个数据的时间
                            
                            NSString * cacheDate = [NSString stringWithFormat:@"%@_%@_%ld",preDate,eveList.selling_time,sepCount];
                            NSMutableArray * editCache = weakSelf.timeCacheArray;
                            BOOL timeEnable = NO;
                            if(![editCache containsObject:cacheDate])
                            {
                                timeEnable = YES;
                                [editCache addObject:cacheDate];
                                if([editCache count] > 10)
                                {
                                    [editCache removeObjectAtIndex:0];
                                }
                            }

                            //进一步判定时间有效，排除近期检索过的时间序列
                            if(timeEnable)
                            {//数量相近，时间有效，
                                //存在刷新中断的情况，即  正常数据也可能出现连续中断的情况，需要区分系统随机中断、系统稳定中断
                                {
                                    for (NSInteger addIndex = 1;addIndex < sepCount;addIndex ++ )
                                    {
                                        CBGListModel * addCBG = [hisArr objectAtIndex:preIndex + addIndex];
                                        if(addCBG.listRefresh)
                                        {
                                            Equip_listModel * addList = [[Equip_listModel alloc] init];
                                            addList.game_ordersn = addCBG.game_ordersn;
                                            addList.serverid = [NSNumber numberWithInteger:addCBG.server_id];
                                            addList.selling_time = addCBG.sell_start_time;
                                            NSString * addOrderSn = addList.listCombineIdfa;
                                            addOrderSn = addList.game_ordersn;
                                            
                                            NSArray * addArr = [dbManager localSaveEquipHistoryModelListForOrderSN:addCBG.game_ordersn];
                                            if([addArr count] > 0)
                                            {
                                                CBGListModel * pre = [addArr firstObject];
                                                addList.appendHistory = pre;
                                                
                                                pre.historyPrice = pre.equip_price;
                                                addList.earnPrice = [NSString stringWithFormat:@"%.0ld",pre.price_earn_plan];
                                                addList.earnRate = pre.plan_rate;
                                                addList.price = [NSNumber numberWithInteger:pre.equip_price];
                                                
                                                if([pre.sell_back_time length] == 0 &&
                                                   [pre.sell_sold_time length] == 0)
                                                {
                                                    addCBG.listRefresh = NO;
                                                    [changeDic setObject:addCBG forKey:addOrderSn];
                                                    
                                                    [webRefreshDic setObject:addList forKey:addOrderSn];
                                                    NSLog(@"addList detail %@ %@ %@ %ld",weakSelf.tagString,addCBG.sell_start_time,addList.game_ordersn,addIndex);
                                                }else
                                                {
                                                    addCBG.listRefresh = NO;
                                                    //                                            [localRefreshDic setObject:addCBG forKey:addCBG.game_ordersn];
                                                    [changeDic setObject:addCBG forKey:addOrderSn];
                                                }
                                                
                                            }else
                                            {//间隔数据，历史不存在
                                                [webRefreshDic setObject:addList forKey:addOrderSn];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                if(eveList.equipState == CBGEquipRoleState_PayFinish ||
                   eveList.equipState == CBGEquipRoleState_BuyFinish ||
                   eveList.equipState == CBGEquipRoleState_Backing)
                {//结束状态的，进行详情刷新
                    [webRefreshDic setObject:eveList forKey:orderSN];
//                    NSLog(@"eveList.equipState 监听 %@ %@ %@",eveList.game_ordersn,eveList.equip_status,weakSelf.tagString);
                }
                
                if(eveList.equipState == CBGEquipRoleState_unSelling)
                {
                    if(![eveList isListAutoStopSelling])
                    {
                        [webRefreshDic setObject:eveList forKey:orderSN];
                        NSLog(@"eveList.equipState 监听 %@ %@ %@",eveList.game_ordersn,eveList.equip_status,weakSelf.tagString);
                    }
                }

                preDate = eveList.selling_time;
                preIndex = latestIndex;
            }
        }
        
        NSArray * allKeys = [webRefreshDic allKeys];
        for (NSInteger index = 0;index < [allKeys count] ;index ++)
        {
            NSString * keySN = [allKeys objectAtIndex:index];
            if([detailCache containsObjectForKey:keySN])
            {//存在可能，
//                NSLog(@"ingore sn %@",keySN);
                [webRefreshDic removeObjectForKey:keySN];
            }else
            {
                self.cacheNum ++;
                [detailCache setObject:@"0" forKey:keySN];
            }
        }
        
        //最晚时间前2分钟，即2分钟内数据重复处理
        //全部数据进行库表存储
        NSArray * localRefresh = [localRefreshDic allValues];
        NSArray * webRefresh = [webRefreshDic allValues];
        
        NSLog(@"local:%ld web:%ld %@",[localRefresh count],[webRefresh count],weakSelf.tagString);
//        if([statusDic count] > 0)
//        {//库表变更
//            [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:[statusDic allValues]];
//        }
        
        if([changeDic allValues] > 0)
        {
            [dbManager localSaveUserChangeArrayListWithDetailCBGModelArray:[changeDic allValues]];
        }
        
        //检查发送消息通知
        if([localRefresh count] > 0 || [webRefresh count]> 0)
        {//进行展示
            [weakSelf refreshTableViewWithInputLatestListArray:localRefresh
                                                    cacheArray:webRefresh
                                                   andTotalNum:totalNum
                                                      andError:errorNum];
        }

    };
    
    NSBlockOperation * blockOpe = [NSBlockOperation blockOperationWithBlock:listCheckBlock];
    [checkQueue addOperation:blockOpe];
}

-(void)refreshLatestMinRequestPageNumber:(NSInteger)pageNum
{
    self.requestNum = pageNum;
}

-(void)autoRefreshListRequestNumberWithLatestMaxPageNumber:(NSInteger)maxNum andMinPageNumber:(NSInteger)minNumber
{
    //    return;
    //请求参数自动调整
    NSInteger refreshNum = 0;
    if(minNumber == 0 && maxNum == 0)
    {//均为0，不变化
        refreshNum = self.requestNum;
    }else if(maxNum > 0)
    {//最大值存在，使用最大值
        refreshNum = maxNum;
    }else
    {//最大值为0   minNumber不为0
        if(minNumber > self.requestNum - 3)
        {//有成功的数量，慎重的增加数量
            //最大值无效，最小值也可能无效
            refreshNum = self.requestNum + 2;
        }else{
            refreshNum = self.requestNum;
        }
        
        refreshNum = MIN(refreshNum, 35);
    }
    
    [self refreshLatestMinRequestPageNumber:refreshNum];
}

-(void)refreshTableViewWithInputLatestListArray:(NSArray *)refresh  cacheArray:(NSArray *)cache andTotalNum:(NSInteger)total andError:(NSInteger)error
{
//    [[NSThread currentThread] isMainThread]
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if(self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(panicListRequestFinishWithUpdateModel:listArray:cacheArray:totalReqNum:andErrorNum:)])
        {
            [self.requestDelegate panicListRequestFinishWithUpdateModel:self
                                                              listArray:refresh
                                                             cacheArray:cache
                                                            totalReqNum:total
                                                            andErrorNum:error];
        }
    });
    
}

@end
