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
    NSMutableArray * repeatCache;
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
    
    dbManager = [[ZALocalModelDBManager alloc] initWithDBExtendString:_tagString];
    detailCache = [[YYCache alloc] initWithName:[NSString stringWithFormat:@"cache_%@",_tagString]];
    
    [detailCache removeAllObjects];
    
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
        repeatCache = [NSMutableArray array];
        self.finishDic = [NSMutableDictionary dictionary];
        self.requestNum = 25;
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
        NSString *  keyStr = list.game_ordersn;
        NSString * result = (NSString *)[detailCache objectForKey:keyStr];
        if(result && [result integerValue] == 0)
        {
            [editArr addObject:list];
            [detailCache removeObjectForKey:keyStr];
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
            cbgModel.listRefresh = NO;
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
    
    NSLog(@"errorProxy %ld errorNum %ld total %ld %@",[proxyErr count],errorNum,[total count],self.tagString);
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
            [hisDic setObject:eve forKey:eve.game_ordersn];
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
            for (NSInteger subIndex = 0;subIndex < [roleArr count] ;subIndex ++ )
            {
                Equip_listModel * eveList = [roleArr objectAtIndex:subIndex];
                NSString * orderSN = eveList.game_ordersn;
                CBGListModel * hisCBG = [hisDic objectForKey:orderSN];
                NSInteger latestIndex = NSNotFound;
                if(hisCBG)
                {
                    if([eveList.selling_time isEqualToString:hisCBG.sell_start_time]){
                        latestIndex = [hisArr indexOfObject:hisCBG];
                    }else{
                        NSDate * preDate = [NSDate fromString:hisCBG.sell_start_time];
                        NSDate * latestDate = [NSDate fromString:eveList.selling_time];
                        if([latestDate timeIntervalSinceDate:preDate] > 0)
                        {
                            //                        NSLog(@"sell_start_time %@ %@",hisCBG.sell_start_time,eveList.selling_time);
                        }else
                        {
                            NSLog(@"sell_start_time data error %@ %@",hisCBG.sell_start_time,eveList.selling_time);
                            continue;
                        }
                    }
                }
                
                //没有历史数据的，先进行历史数据请求
//                CBGListModel * preHis = nil;
                //历史数据追加，有则追加，没有则不变
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
                    
                    if(pre.plan_total_price < 0)
                    {//估值太低的，不计入范围
                        [webRefreshDic removeObjectForKey:orderSN];
                    }
                }
                
                //筛选添加
                if(latestIndex == NSNotFound)//当前的未查找到
                {//筛选检索列表不存在的，进行详情请求
                    if([orderArr count] == 0)
                    {
                        CBGListModel * eveCBG = [eveList listCompareModel];
                        [changeDic setObject:eveCBG forKey:orderSN];
                        [webRefreshDic setObject:eveList forKey:orderSN];
//                    }
//                    else if(eveList.appendHistory &&
//                             [eveList.appendHistory.sell_back_time length] == 0 &&
//                             [eveList.appendHistory.sell_sold_time length] == 0)
//                    {//筛选列表不存在，库存列表存在，可能是已经置为失效，理论上不存在
//                        //可能库表写入原因，列表数据未填充
//                        CBGListModel * eveCBG = [eveList listCompareModel];
//                        [changeDic setObject:eveCBG forKey:orderSN];
//                        [localRefreshDic setObject:eveList forKey:orderSN];
////                        NSLog(@"cbgHistory data error %@ %@",orderSN,self.tagString);
                    }else
                    {//此数据为详情请求数据，列表查询不返回
                        CBGListModel * eveCBG = [eveList listCompareModel];
                        [changeDic setObject:eveCBG forKey:orderSN];
//                        if(eveList.earnRate > 0)
//                        {
//                            [webRefreshDic setObject:eveList forKey:orderSN];
//                        }else
//                        {
//                            [localRefreshDic setObject:eveList forKey:orderSN];
//                        }
                    }
                }else if(preIndex == NSNotFound)
                {//第一个查找到的
                    //和历史时间比对，历史时间不一致，进行本地刷新
                    if(!eveList.appendHistory)
                    {
                        [webRefreshDic setObject:eveList forKey:orderSN];
                    }else if(![hisCBG.sell_start_time isEqualToString:eveList.selling_time])
                    {
                        if(eveList.earnRate > 0){
                            [webRefreshDic setObject:eveList forKey:orderSN];
                        }else
                        {
                            [localRefreshDic setObject:eveList forKey:orderSN];
                        }
                    }
                }
                else if(preIndex != NSNotFound)//前一个，已经查找到
                {//相邻两个均在历史库表存在  之前是0   现在是2，则进行中间数据的读取
                    //查找中间数据，发起详情请求
                    
                    NSInteger sepCount = latestIndex - preIndex;
                    if(sepCount > 1 && sepCount < 5)//针对有连续两个发生变化的情况
                    {// && sepCount < 5  担心  两拨请求之间，出现偏差  理论不会太大
                        for (NSInteger addIndex = 1;addIndex < sepCount;addIndex ++ )
                        {
                            CBGListModel * addCBG = [hisArr objectAtIndex:preIndex + addIndex];
                            if(addCBG.listRefresh)
                            {
                                Equip_listModel * addList = [[Equip_listModel alloc] init];
                                addList.game_ordersn = addCBG.game_ordersn;
                                addList.serverid = [NSNumber numberWithInteger:addCBG.server_id];
                                addList.selling_time = addCBG.sell_start_time;
                                
                                NSArray * orderArr = [dbManager localSaveEquipHistoryModelListForOrderSN:addCBG.game_ordersn];
                                if([orderArr count] > 0)
                                {
                                    CBGListModel * pre = [orderArr firstObject];
                                    addList.appendHistory = pre;
                                    
                                    NSInteger prePirce = pre.equip_price;
                                    pre.historyPrice = prePirce;
                                    if([addList.price integerValue] > 0)
                                    {
                                        pre.equip_price = [addList.price integerValue];
                                        pre.plan_rate = pre.price_rate_latest_plan;
                                        
                                        addList.earnPrice = [NSString stringWithFormat:@"%.0ld",pre.price_earn_plan];
                                        addList.earnRate = pre.plan_rate;
                                    }
                                }
                                
                                
                                if([addList.appendHistory.sell_back_time length] == 0 &&
                                   [addList.appendHistory.sell_sold_time length] == 0)
                                {
//                                    if(addList.earnRate > 0 || [orderArr count] == 0)
                                    {
                                        [webRefreshDic setObject:addList forKey:addList.game_ordersn];
                                    }
//                                    else{
//                                        [localRefreshDic setObject:addList forKey:addList.game_ordersn];
//                                    }
                                }

                            }
                        }
                    }
                }
                if(eveList.equipState == CBGEquipRoleState_unSelling ||
                   eveList.equipState == CBGEquipRoleState_PayFinish ||
                   eveList.equipState == CBGEquipRoleState_BuyFinish)
                {//结束状态的，进行详情刷新
                    [webRefreshDic setObject:eveList forKey:orderSN];
                }
                
                //移除//已经结束
                if([eveList.appendHistory.sell_back_time length] > 0 ||
                   [eveList.appendHistory.sell_sold_time length] > 0)
                {
                    [webRefreshDic removeObjectForKey:orderSN];
                }
                preIndex = latestIndex;
            }
        }
        
        NSArray * allKeys = [webRefreshDic allKeys];
        for (NSInteger index = 0;index < [allKeys count] ;index ++)
        {
            NSString * keySN = [allKeys objectAtIndex:index];
            if([detailCache containsObjectForKey:keySN])
            {
                NSLog(@"ingore sn %@",keySN);
                [webRefreshDic removeObjectForKey:keySN];
            }else
            {
                [detailCache setObject:@"0" forKey:keySN];
            }
        }
        
        //最晚时间前2分钟，即2分钟内数据重复处理
        //全部数据进行库表存储
        NSArray * localRefresh = [localRefreshDic allValues];
        NSArray * webRefresh = [webRefreshDic allValues];
        
        NSLog(@"local:%ld web:%ld %@",[localRefresh count],[webRefresh count],weakSelf.tagString);
        if([statusDic count] > 0)
        {//库表变更
            [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:[statusDic allValues]];
        }
        
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
