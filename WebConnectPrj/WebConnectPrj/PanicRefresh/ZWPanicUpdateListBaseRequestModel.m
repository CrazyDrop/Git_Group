//
//  ZWPanicUpdateListBaseRequestModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/5.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicUpdateListBaseRequestModel.h"
#import "Equip_listModel.h"
#import "EquipListRequestModel.h"
#import "ZWOperationEquipReqListReqModel.h"
#import "VPNProxyModel.h"
#import "DZUtils.h"
#import "RoleDataModel.h"
#import "SessionReqModel.h"
@interface ZWPanicUpdateListBaseRequestModel ()
{
    NSMutableArray * repeatCache;
    NSMutableArray * localCacheArr;
    NSInteger maxLength;
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
@end

@implementation ZWPanicUpdateListBaseRequestModel

-(void)stopRefreshRequestAndClearRequestModel
{
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
        localCacheArr = [NSMutableArray array];
        repeatCache = [NSMutableArray array];
        self.requestNum = 25;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(detailRefreshFinishedLocalUpdateAndRemoveWithBackNoti:)
                                                     name:NOTIFICATION_REMOVE_REFRESH_WEBDETAIL_STATE
                                                   object:nil];
    }
    return self;
}
-(void)detailRefreshFinishedLocalUpdateAndRemoveWithBackNoti:(NSNotification *)noti
{
    Equip_listModel * list = (Equip_listModel *)[noti object];
    NSString * keyStr = list.listCombineIdfa;
    keyStr = list.game_ordersn;
    
    @synchronized (localCacheArr)
    {
        if(![localCacheArr containsObject:keyStr])
        {
            return;
        }
        
        //进行库表存储
    //    list.listSaveModel = nil;
        CBGEquipRoleState state = list.equipModel.equipState;
        if(state == CBGEquipRoleState_unSelling){
            list.listSaveModel = nil;
        }
        
        if(state == CBGEquipRoleState_PayFinish || state == CBGEquipRoleState_BuyFinish){
            list.listSaveModel = nil;
        }
        
        CBGListModel * cbgModel = [list listSaveModel];
        cbgModel.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:@[cbgModel]];
        

        if([localCacheArr containsObject:keyStr])
        {
            [localCacheArr removeObject:keyStr];
        }
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
    NSLog(@"%s %@",__FUNCTION__,self.tagString);
    
    ZWOperationEquipReqListReqModel * model = (ZWOperationEquipReqListReqModel *)_dpModel;
    //仅做数据刷新，不做展示   详情数据请求中时，列表数据也需要刷新
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[ZWOperationEquipReqListReqModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
        
        if(self.schoolNum > 0){
            model.selectSchool = self.schoolNum;
        }
        model.priceStatus = self.priceStatus;
    }
    
    
    model.pageNum = self.requestNum;//刷新页数
    
    ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];
    model.sessionArr = manager.sessionSubCache;
    
//    model.timerState = !model.timerState;
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
    Equip_listModel * lastModel = [arr lastObject];
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
    NSArray * proxyErr = model.errorProxy;
    
    ZWProxyRefreshManager * proxyManager = [ZWProxyRefreshManager sharedInstance];
    NSMutableArray * editProxy = [NSMutableArray arrayWithArray:proxyManager.proxyArrCache];
    
    NSInteger minPageNum = 0;
    NSInteger maxPageNum = 0;
    NSInteger errorNum = 0;
    //正常序列
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
        
        SessionReqModel * vpnObj = [model.baseReqModels objectAtIndex:index];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            minPageNum = index;
            BOOL effective = [self checkDetailListEquipNameWithBackEquipListArray:obj];
            if(effective)
            {
                for (Equip_listModel * eveObj in obj)
                {
                    [dataObjDic setObject:eveObj forKey:eveObj.game_ordersn];
                }
            }else{
                //进行异常处理
                vpnObj.proxyModel.errored = YES;//定期移除
            }
        }else{
            errorNum ++;
        }
    }
    
    NSArray * array = [dataObjDic allValues];

    
    NSLog(@"proxy %ld errorProxy %ld errorNum %ld total %ld %@",[editProxy count],[proxyErr count],errorNum,[total count],self.tagString);
    //检查得出未上架的数据
    //列表数据排重，区分未上架数据、价格变动数据
    NSMutableDictionary * refreshDic = [NSMutableDictionary dictionary];    //后期详情刷新dic
    NSMutableDictionary * statusDic = [NSMutableDictionary dictionary];     //状态变动，需要刷新dic
    NSMutableDictionary * modelsDic = [NSMutableDictionary dictionary];
    
    //筛选出价格变更数据进行展示、状态变更数据进行库表刷新、未上架数据进行详情刷新
    
    NSDate * latestDate = nil;//找出来最晚时间
    for (NSInteger index = 0 ;index < [array count]; index ++ )
    {
        NSInteger backIndex = [array count] - index - 1;
        Equip_listModel * eveModel = [array objectAtIndex:backIndex];
        NSDate * sellDate = [NSDate fromString:eveModel.selling_time];
        
        NSString * orderSN = eveModel.game_ordersn;
        if(eveModel.equipState == CBGEquipRoleState_unSelling)
        {
            NSLog(@"selling_time UNSell %@ %@ %@",orderSN,eveModel.serverid,eveModel.selling_time);
            [refreshDic setObject:eveModel forKey:orderSN];
            NSArray * orderArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
            if([orderArr count] > 0)
            {
                CBGListModel * pre = [orderArr firstObject];
                eveModel.appendHistory = pre;
                
                NSInteger prePirce = pre.equip_price ;
                pre.historyPrice = prePirce;
                if([eveModel.price integerValue] > 0){
                    pre.equip_price = [eveModel.price integerValue];
                    pre.plan_rate = pre.price_rate_latest_plan;
                }
                
                if(pre.plan_total_price < 0)
                {//估值太低的，不计入范围
                    [refreshDic removeObjectForKey:orderSN];
                }
            }
        }else if(eveModel.equipState == CBGEquipRoleState_Backing)
        {//取回，仅做状态刷新、界面展示
            NSArray * orderArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
            if([orderArr count] > 0)
            {
                CBGListModel * pre = [orderArr firstObject];
                pre.dbStyle = CBGLocalDataBaseListUpdateStyle_RefreshTotal;
                if([pre.sell_back_time length] == 0)
                {
                    pre.sell_back_time = [NSDate unixDate];
                    [statusDic setObject:pre forKey:orderSN];
                    
                    pre.equip_status = [eveModel.equip_status integerValue];
                    eveModel.appendHistory = pre;
                    [modelsDic setObject:eveModel forKey:orderSN];
                }
            }else
            {
                [refreshDic setObject:eveModel forKey:orderSN];
            }
            
        }else if(eveModel.equipState == CBGEquipRoleState_PayFinish || eveModel.equipState == CBGEquipRoleState_BuyFinish)
        {//售出的数据、取回的数据   可能存在价格和状态同时变化
            NSArray * orderArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
            if([orderArr count] > 0)
            {
                CBGListModel * pre = [orderArr firstObject];
                if(!pre.sell_sold_time || [pre.sell_sold_time length] == 0)
                {
                    if(self.lineDate && ![self lineDateEarlierThanSellDate:sellDate])
                    {
                        pre.bargainBuy = YES;
                    }
                    
                    eveModel.appendHistory = pre;
                    
                    NSInteger prePirce = pre.equip_price ;
                    pre.historyPrice = prePirce;
                    pre.equip_price = [eveModel.price integerValue];
                    pre.plan_rate = pre.price_rate_latest_plan;
                    pre.equip_status = [eveModel.equip_status integerValue];
                    pre.dbStyle = CBGLocalDataBaseListUpdateStyle_RefreshTotal;
//                    [modelsDic setObject:eveModel forKey:orderSN];
                    
                    eveModel.earnPrice = [NSString stringWithFormat:@"%.0ld",pre.price_earn_plan];
                    eveModel.earnRate = pre.plan_rate;
                    
                    [refreshDic setObject:eveModel forKey:orderSN];
                }
            }else
            {
                [refreshDic setObject:eveModel forKey:orderSN];
            }
        }else{
            
            BOOL compareDate = NO;
            if(self.lineDate){
                compareDate = YES;
            }
            
            if(!compareDate || (compareDate && [self lineDateEarlierThanSellDate:sellDate]))
            {
                //检查价格变动、价格有变动的，进行更新
                NSArray * orderArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
                if([orderArr count] > 0)
                {
                    CBGListModel * pre = [orderArr firstObject];
                    if(pre.equip_price != [eveModel.price integerValue] && [eveModel.price integerValue] > 0)
                    {
                        NSInteger prePirce = pre.equip_price ;
                        pre.historyPrice = prePirce;
                        pre.equip_price = [eveModel.price integerValue];
                        pre.plan_rate = pre.price_rate_latest_plan;
                        pre.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPrice;
                        [statusDic setObject:pre forKey:orderSN];
                        
                        eveModel.earnPrice = [NSString stringWithFormat:@"%.0ld",pre.price_earn_plan];
                        eveModel.earnRate = pre.plan_rate;
                        
                        eveModel.appendHistory = pre;
                        [modelsDic setObject:eveModel forKey:orderSN];
                    }
                }else
                {
                    [refreshDic setObject:eveModel forKey:orderSN];
                }
            }
        }
        
        
        if(latestDate)
        {
            NSTimeInterval count = [sellDate timeIntervalSinceDate:latestDate];
            if(count > 0){
                latestDate = sellDate;
            }
        }else{
            latestDate = sellDate;
        }

    }
    //最晚时间前2分钟，即2分钟内数据重复处理
    self.lineDate = [latestDate dateByAddingTimeInterval:-60 * 2];
    
    //全部数据进行库表存储
    NSArray * models = [modelsDic allValues];

    if([statusDic count] > 0){//库表变更
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:[statusDic allValues]];
    }
    
    //检查发送消息通知
    if([models count] > 0)
    {//进行展示
        [self refreshTableViewWithInputLatestListArray:models cacheArray:nil];
    }
    
    //详情刷新
    [self checkUnSellingListArrayPostSubNotificationWithArray:[refreshDic allValues]];

    //有时候会因为部分请求失败，造成检索范围有误
    [self autoRefreshListRequestNumberWithLatestMaxPageNumber:maxPageNum andMinPageNumber:minPageNum];
}
-(BOOL)lineDateEarlierThanSellDate:(NSDate *)sellDate
{//不存在时，认为都
    
    if(self.lineDate)
    {
        NSTimeInterval count = [sellDate timeIntervalSinceDate:self.lineDate];
        if(count > 0){
            return YES;
        }
    }
    return NO;
}

-(void)refreshLatestMinRequestPageNumber:(NSInteger)pageNum
{
    self.requestNum = pageNum;
}

-(void)autoRefreshListRequestNumberWithLatestMaxPageNumber:(NSInteger)maxNum andMinPageNumber:(NSInteger)minNumber
{
    //请求参数自动调整
    NSInteger refreshNum = 0;
    if(maxNum == 0){
        //最大值无效，最小值也可能无效
        refreshNum = self.requestNum + 2;
        refreshNum = MIN(refreshNum, 28);
    }else{
        refreshNum = maxNum;
    }
    
    
    [self refreshLatestMinRequestPageNumber:refreshNum];
    
    
//    EquipListRequestModel * refresh = (EquipListRequestModel *)_dpModel;
//    [refresh cancel];
//    [refresh removeSignalResponder:self];
//    _dpModel = nil;
}

-(void)checkUnSellingListArrayPostSubNotificationWithArray:(NSArray *)array
{
    
    //repeatCache最大值  20，20超过从前面移除
//    NSInteger countNum = 20;
//    if([repeatCache count] > countNum)
//    {
//        NSRange range = NSMakeRange(0, [repeatCache count] - countNum);
//        [repeatCache removeObjectsInRange:range];
//    }
    
    @synchronized (localCacheArr)
    {
        if([array count] == 0) return;
        
        for (NSInteger index = 0;index < [array count] ;index ++ )
        {
            Equip_listModel * eve = [array objectAtIndex:index];
            NSString * combine = eve.listCombineIdfa;
            combine = eve.game_ordersn;
            
//            if(eve.equipState != CBGEquipRoleState_unSelling )
//            {//对于非未上架的数据，增加重复排重限定
//                if([repeatCache containsObject:combine])
//                {
//                    continue;
//                }else
//                {
//                    [repeatCache addObject:combine];
//                }
//            }
            if(![localCacheArr containsObject:combine])
            {
                [localCacheArr addObject:combine];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_REFRESH_WEBDETAIL_STATE
                                                                    object:eve];
            }
        }
    }
    
}
-(void)refreshTableViewWithInputLatestListArray:(NSArray *)array  cacheArray:(NSArray *)arr1
{
    if(self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(panicListRequestFinishWithUpdateModel:listArray:cacheArray:)])
    {
        [self.requestDelegate panicListRequestFinishWithUpdateModel:self
                                                          listArray:array
                                                         cacheArray:arr1];
    }
}




//启动列表请求，检查数据状态、价格
//软件保存selltime，请求数据，仅对selltime之后的数据进行处理
//1、状态检查，未上架  发起消息通知
//否则：库表检查、价格变动、进行代理调用







@end
