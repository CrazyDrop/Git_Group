//
//  ServerDetailRefreshModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ServerDetailRefreshModel.h"
#import "ZWOperationEquipReqListReqModel.h"
#import "ZWOperationDetailListReqModel.h"
#import "ZWOperationAutoDetailListReqModel.h"
#import "ZALocalModelDBManager.h"
#import "ServerRefreshRequestModel.h"
#import "EquipSNAutoModel.h"
#import "Equip_listModel.h"
#import "ServerEquipIdRequestModel.h"
@interface ServerDetailRefreshModel ()
{
    BaseRequestModel * _dpModel;                //基础server列表，查找当前最近的equipid
    BaseRequestModel * _detailListReqModel;
    BaseRequestModel * _detailAutoReqModel;
    BaseRequestModel * _equipReqModel;
    ZALocalModelDBManager  * dbManager;
    
}

@property (nonatomic, assign) BOOL  listCheck;
@property (nonatomic, assign) BOOL  detailRequest;
@property (nonatomic, copy) NSString * serverNum;

//每次请求成功，修改finishModel、latestDate
@property (nonatomic, strong) EquipSNAutoModel * finishModel;
@property (nonatomic, strong) NSDate * latestDate;
@property (nonatomic, strong) NSDate * latestCheckDate;

@property (nonatomic, assign) NSInteger maxTestNum;     //最大单次尝试数量
@property (nonatomic, assign) NSInteger finishTimeNum;  //当前已经结束的最大时间数、发起请求即计数

@property (nonatomic, strong) NSArray * erroredArr;//错误链接

@property (nonatomic, strong) NSArray * detailsArr;
@property (nonatomic, strong) NSArray * errorDetails;

@property (nonatomic, assign) NSInteger minuteNum;
@property (nonatomic, strong) NSArray * resultArr;

@property (nonatomic, assign) BOOL equipRequest;
@end

@implementation ServerDetailRefreshModel

-(id)init
{
    self = [super init];
    if (self)
    {
        self.minuteNum = 20;
        self.maxTestNum = 20;
        self.proxyEnable = NO;
        self.listCheck = YES;
    }
    return self;
}

-(void)stopRefreshRequestAndClearRequestModel
{
    ServerEquipIdRequestModel * equipRefresh = (ServerEquipIdRequestModel *)_equipReqModel;
    [equipRefresh cancel];
    [equipRefresh removeSignalResponder:self];

    ZWOperationDetailListReqModel * detailRefresh = (ZWOperationDetailListReqModel *)_detailListReqModel;
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
    
    ZWOperationEquipReqListReqModel * refresh = (ZWOperationEquipReqListReqModel *)_dpModel;
    [refresh cancel];
    [refresh removeSignalResponder:self];
    
    ZWOperationAutoDetailListReqModel * tryRefresh = (ZWOperationAutoDetailListReqModel *)_detailAutoReqModel;
    [tryRefresh cancel];
    [tryRefresh removeSignalResponder:self];
    
    _detailListReqModel = nil;
    _dpModel = nil;
    _detailAutoReqModel = nil;
    _equipReqModel = nil;
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
    self.serverNum = self.serverTag;
    
    NSArray * tagArr = [_serverTag componentsSeparatedByString:@"_"];
    dbManager = [[ZALocalModelDBManager alloc] initWithDBExtendString:_serverTag];
    
    //读取对应数据填充到缓存中
//    if([self.cacheArr count] > 0){
//        NSDictionary * dataDic = [self readLocalCacheDetailListFromLocalDBWithArrr:self.cacheArr];
//        [cacheDic addEntriesFromDictionary:dataDic];
//    }
    
}
-(NSDictionary *)readLocalCacheDetailListFromLocalDBWithArrr:(NSArray *)orderArr
{
    NSMutableDictionary * readDic = [NSMutableDictionary dictionary];
//    for (NSInteger index = 0;index < [orderArr count] ;index ++ )
//    {
//        NSString * order = [orderArr objectAtIndex:index];
//        NSArray * arr = [dbManager localSaveEquipHistoryModelListForOrderSN:order];
//        if([arr count] > 0)
//        {
//            CBGListModel * cbgList = [arr lastObject];
//            Equip_listModel * list = [[Equip_listModel alloc] init];
//            list.serverid = [NSNumber numberWithInteger:cbgList.server_id];
//            list.game_ordersn = cbgList.game_ordersn;
//            list.equip_status = @1;
//            [readDic setObject:list forKey:order];
//        }
//    }
    return readDic;
}



//启动请求
-(void)startRefreshDataModelRequest
{
    if(self.endRefresh) return;
    
    if(self.listCheck)
    {//列表检查
        [self startMobileServerListRequest];
    }else if(self.detailRequest)
    {//详情请求
        [self startServerListBackDetailRequestWithEquipModels:self.errorDetails];
    }else
    {//时间递增
        [self startDetailArrayListRequest];
    }
}
-(void)startMobileServerListRequest
{
    ServerRefreshRequestModel * listRequest = (ServerRefreshRequestModel *)_dpModel;
    if(listRequest.executing) return;
    
    
    ZWOperationDetailListReqModel * detailRequest = (ZWOperationDetailListReqModel *)_detailListReqModel;
    if(detailRequest.executing) return;

    
    ZWOperationAutoDetailListReqModel * autoRequest = (ZWOperationAutoDetailListReqModel *)_detailAutoReqModel;
    if(autoRequest.executing) return;

    
    //    [requestLock lock];
    NSLog(@"%s %@",__FUNCTION__,self.serverTag);
    
    ServerRefreshRequestModel * model = (ServerRefreshRequestModel *)_dpModel;
    //仅做数据刷新，不做展示   详情数据请求中时，列表数据也需要刷新
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[ServerRefreshRequestModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.isProxy)
    {
        ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];
        model.sessionArr = manager.sessionSubCache;
    }
    model.serverArr = @[self.serverNum];
    
    model.timerState = !model.timerState;
    [model sendRequest];    
}

#pragma mark ServerRefreshRequestModel
handleSignal( ServerRefreshRequestModel, requestError )
{
    
}
handleSignal( ServerRefreshRequestModel, requestLoading )
{
}

handleSignal( ServerRefreshRequestModel, requestLoaded )
{
    NSLog(@"%s %@",__FUNCTION__,self.serverNum);
    
    ServerRefreshRequestModel * model = (ServerRefreshRequestModel *) _dpModel;
    NSArray * total  = model.listArray;
    
    //正常序列
    NSMutableArray * array = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        NSArray * obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            [array addObjectsFromArray:obj];
        }
    }
    
    
    //列表数据排重
    NSMutableDictionary * modelsDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0 ;index < [array count]; index ++ )
    {
        NSInteger backIndex = [array count] - index - 1;
        Equip_listModel * eveModel = [array objectAtIndex:backIndex];
        
        
        NSArray * dbArr = [dbManager localSaveEquipHistoryModelListForOrderSN:eveModel.game_ordersn];
        if(!dbArr || [dbArr count] == 0)
        {
            [modelsDic setObject:eveModel forKey:eveModel.detailCheckIdentifier];
        }
    }
    
    NSArray * backArray = [modelsDic allValues];
    if([backArray count] > 0)
    {
        self.errorDetails = backArray;
        self.detailRequest = YES;
        self.listCheck = NO;
    }else
    {
        if(self.latestDate)
        {
            self.listCheck = NO;
        }else
        {
//            //读取本地最后一个
//            NSArray * hisArr = [dbManager localSaveEquipHistoryModelListMaxedEquipID];
//            if([hisArr count] > 0)
//            {
//                CBGListModel * dbObj = [hisArr lastObject];
//                NSLog(@"detailEndDetail%ld %@",dbObj.server_id,dbObj.game_ordersn);
//                if(dbObj.server_id == [self.serverNum integerValue])
//                {
//                    NSDate * endDate = [NSDate fromString:dbObj.sell_create_time];
//                    self.latestDate = endDate;
//                    self.finishModel = [[EquipSNAutoModel alloc] initWithEquipSN:dbObj.game_ordersn andEquipId:dbObj.equip_id];
//                    self.finishModel.serverId = self.serverNum;
//                    self.latestCheckDate = [NSDate dateWithTimeIntervalSinceNow:self.minuteNum * MINUTE];
//                }
//            }
        }
    }
}

-(void)startServerListBackDetailRequestWithEquipModels:(NSArray *)models
{
    ServerRefreshRequestModel * listRequest = (ServerRefreshRequestModel *)_dpModel;
    if(listRequest.executing) return;
    
    
    ZWOperationDetailListReqModel * detailRequest = (ZWOperationDetailListReqModel *)_detailListReqModel;
    if(detailRequest.executing) return;
    
    
    ZWOperationAutoDetailListReqModel * autoRequest = (ZWOperationAutoDetailListReqModel *)_detailAutoReqModel;
    if(autoRequest.executing) return;
    
    self.detailsArr = [NSArray arrayWithArray:models];
    
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0; index < [models count]; index++)
    {
        Equip_listModel * eveModel = [models objectAtIndex:index];
        [urls addObject:eveModel.detailDataUrl];
    }
    [self startEquipDetailAllRequestWithUrls:urls];
}
-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
//    NSLog(@"%s",__FUNCTION__);
    
    ZWOperationDetailListReqModel * model = (ZWOperationDetailListReqModel *)_detailListReqModel;
    
    if(!model){
        model = [[ZWOperationDetailListReqModel alloc] init];
        [model addSignalResponder:self];
        _detailListReqModel = model;
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.isProxy)
    {
        ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];
        model.sessionArr = manager.sessionSubCache;
    }
    
    [model refreshWebRequestWithArray:array];
    [model sendRequest];
}


#pragma mark ZWOperationDetailListReqModel
handleSignal( ZWOperationDetailListReqModel, requestError )
{
//    NSLog(@"%s",__FUNCTION__);
    //修改文本，提示网络异常
}
handleSignal( ZWOperationDetailListReqModel, requestLoading )
{
}

handleSignal( ZWOperationDetailListReqModel, requestLoaded )
{
    
    //进行存储操作、展示
    //列表数据，部分成功部分还失败，对于成功的数据，刷新展示，对于失败的数据，继续请求
    ZWOperationDetailListReqModel * model = (ZWOperationDetailListReqModel *) _detailListReqModel;
    NSArray * total  = [NSArray arrayWithArray:model.listArray];
    NSArray * models = [NSArray arrayWithArray:self.detailsArr];
    
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
    
//    NSLog(@"%s %ld",__FUNCTION__,errorNum);
    
    
    NSDate * totalEndDate = nil;
    EquipModel * endDetail = nil;
    
    NSMutableArray * listArr = [NSMutableArray array];
    NSMutableArray * err = [NSMutableArray array];
    NSMutableArray * localArr = [NSMutableArray array];
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
            if(![obj.game_ordersn isEqualToString:detailEve.game_ordersn])
            {
                [err addObject:obj];
                continue;
            }
            
            if(!detailEve.game_ordersn)
            {
                [err addObject:obj];
                continue;
            }
            
            if([detailEve.serverid integerValue] != [self.serverNum integerValue])
            {
                [err addObject:obj];
                continue;
            }

            
            NSDate * endDate = [NSDate fromString:detailEve.create_time];
            if(!totalEndDate)
            {
                totalEndDate = endDate;
                endDetail = detailEve;
            }else if([totalEndDate timeIntervalSinceDate:endDate] > 0)
            {
                endDetail = detailEve;
                totalEndDate = endDate;
            }
            [listArr addObject:obj];
            obj.equipModel = detailEve;
            CBGListModel * listObj = obj.listSaveModel;
            obj.earnRate = listObj.plan_rate;
            obj.earnPrice = [NSString stringWithFormat:@"%ld",listObj.price_earn_plan];
            [localArr addObject:listObj];
        }else
        {
            [err addObject:obj];
        }
    }
    
    
    if(totalEndDate)
    {//进行创建
        if(!self.latestDate || ([totalEndDate timeIntervalSinceDate:self.latestDate] > 0))
        {//开启下一个请求
            if([endDetail isFirstInSelling])
            {
                NSLog(@"startFind %@ %@",endDetail.serverid,endDetail.game_ordersn);
                self.latestDate = totalEndDate;
                self.finishModel = [[EquipSNAutoModel alloc] initWithEquipSN:endDetail.game_ordersn andEquipId:[endDetail.equipid integerValue]];
                self.finishModel.serverId = self.serverNum;
                self.latestCheckDate = [NSDate dateWithTimeIntervalSinceNow:self.minuteNum * MINUTE];
            }
        }else if(self.latestCheckDate && [self.latestCheckDate timeIntervalSinceNow] < 0)
        {//尝试的次数过多时，时间差达到20分钟
            self.listCheck = YES;
        }
    }
    
    if([localArr count] > 0)
    {
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:localArr];
    }
    
    if([err count] > 0){
        //继续请求详情
        self.errorDetails = err;
        self.detailRequest = YES;
    }else{
        self.errorDetails = nil;
        self.detailRequest = NO;
    }

    if(self.latestCheckDate)
    {//找到新上架的，停止请求
        self.listCheck = NO;
    }
    
    if([listArr count] > 0)
    {
        [self doneServerRequestWithFinishedArray:listArr];
    }

}
-(void)startDetailArrayListRequest
{
    ServerRefreshRequestModel * listRequest = (ServerRefreshRequestModel *)_dpModel;
    if(listRequest.executing) return;
    
    
    ZWOperationDetailListReqModel * detailRequest = (ZWOperationDetailListReqModel *)_detailListReqModel;
    if(detailRequest.executing) return;
    
    
    ZWOperationAutoDetailListReqModel * autoRequest = (ZWOperationAutoDetailListReqModel *)_detailAutoReqModel;
    if(autoRequest.executing) return;
    
    
    //    [requestLock lock];
    NSLog(@"%s serverId %@",__FUNCTION__,self.serverTag);
    
    ZWOperationAutoDetailListReqModel * model = (ZWOperationAutoDetailListReqModel *)_detailAutoReqModel;
    //仅做数据刷新，不做展示   详情数据请求中时，列表数据也需要刷新
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[ZWOperationAutoDetailListReqModel alloc] init];
        [model addSignalResponder:self];
        _detailAutoReqModel = model;
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.isProxy)
    {
        ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];
        model.sessionArr = manager.sessionSubCache;
    }
    
    NSArray * array = [self latestDetailRequestTestUrls];
//    NSArray * array = @[@"http://xyq-ios2.cbg.163.com/app2-cgi-bin/query.py?serverid=33&game_ordersn=120_1503038501_121589155&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=iPhone&os_name=iPhoneOS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8"];
    [model refreshWebRequestWithArray:array];
    [model sendRequest];
}
-(NSArray * )latestDetailRequestTestUrls
{
    NSMutableArray * editArr = [NSMutableArray array];
    [editArr addObjectsFromArray:self.erroredArr];
    
    NSInteger maxTestNum = [[NSDate date] timeIntervalSince1970];
    EquipSNAutoModel * equiModel = self.finishModel;
    NSInteger addNum = self.maxTestNum - [self.erroredArr count];
    for (NSInteger index = 0;index < addNum ;index ++ )
    {
        if(equiModel.timeNum < maxTestNum)
        {
            equiModel.timeNum ++;
            [editArr addObject:equiModel.nextTryDetailDataUrl];
        }
    }
    self.finishTimeNum = equiModel.timeNum;
    
    return editArr;
}
#pragma mark ZWOperationAutoDetailListReqModel
handleSignal( ZWOperationAutoDetailListReqModel, requestError )
{
    NSLog(@"%s",__FUNCTION__);
    //修改文本，提示网络异常
}
handleSignal( ZWOperationAutoDetailListReqModel, requestLoading )
{
}

handleSignal( ZWOperationAutoDetailListReqModel, requestLoaded )
{
    //进行存储操作、展示
    //列表数据，部分成功部分还失败，对于成功的数据，刷新展示，对于失败的数据，继续请求
    ZWOperationAutoDetailListReqModel * model = (ZWOperationAutoDetailListReqModel *) _detailAutoReqModel;
    NSArray * total  = [NSArray arrayWithArray:model.listArray];
    
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
    
    
    NSDate * totalEndDate = nil;
    EquipModel * endDetail = nil;
    Equip_listModel * endListModel = nil;
    NSMutableArray * err = [NSMutableArray array];
    NSMutableArray * localArr = [NSMutableArray array];
    NSArray * models = model.baseUrls;
    NSInteger nextEquipId = self.finishModel.nextEquipId;
    for (NSInteger index = 0; index < [models count]; index ++)
    {
        EquipModel * detailEve = nil;
        if([detailModels count] > index)
        {
            detailEve = [detailModels objectAtIndex:index];
        }
        NSString * url = [models objectAtIndex:index];
        if(![detailEve isKindOfClass:[NSNull class]])
        {
            if(detailEve.game_ordersn)
            {
                if([detailEve.serverid integerValue] != [self.serverNum integerValue])
                {
                    [err addObject:url];
                    continue;
                }
                
                if(nextEquipId > 0 && [detailEve.equipid integerValue] != nextEquipId){
                    [err addObject:url];
                    continue;
                }
                
                NSDate * endDate = [NSDate fromString:detailEve.create_time];
                if(!totalEndDate)
                {
                    totalEndDate = endDate;
                    endDetail = detailEve;
                }else if([totalEndDate timeIntervalSinceDate:endDate] > 0)
                {
                    endDetail = detailEve;
                    totalEndDate = endDate;
                }
                
                Equip_listModel * obj = [[Equip_listModel alloc] init];
                obj.game_ordersn = detailEve.game_ordersn;
                obj.serverid = detailEve.serverid;
                
                obj.equipModel = detailEve;
                CBGListModel * listObj = obj.listSaveModel;
                obj.earnRate = listObj.plan_rate;
                obj.earnPrice = [NSString stringWithFormat:@"%ld",listObj.price_earn_plan];
                [localArr addObject:listObj];
            }
//            NSLog(@"noneUrl %@",url);
        }else
        {
            [err addObject:url];
        }
    }
    
    if([localArr count] > 0)
    {
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:localArr];
    }
    self.erroredArr = err;
    
    if([localArr count] > 0)
    {
        NSLog(@"%s success %@ %@",__FUNCTION__,self.serverNum,endDetail.game_ordersn);
    }else{
        NSLog(@"%s %@(error %ld/%ld)",__FUNCTION__,self.serverNum,[err count],[detailModels count]);
    }
    
    if(totalEndDate)
    {//进行替换
        if(!self.latestDate || ([totalEndDate timeIntervalSinceDate:self.latestDate] > 0))
        {//开启下一个请求
            NSLog(@"autoFind %@ %@",endDetail.serverid,endDetail.game_ordersn);
            self.latestDate = totalEndDate;
            self.finishModel = [[EquipSNAutoModel alloc] initWithEquipSN:endDetail.game_ordersn andEquipId:[endDetail.equipid integerValue]];
            self.finishModel.serverId = self.serverNum;
            self.latestCheckDate = [NSDate dateWithTimeIntervalSinceNow:self.minuteNum * MINUTE];
        }else if([self.latestCheckDate timeIntervalSinceNow] < 0)
        {//尝试的次数过多时，时间差达到20分钟
            self.listCheck = YES;
        }
    }
    
    if(endListModel)
    {
        [self doneServerRequestWithFinishedArray:@[endListModel]];
    }
    
}



-(void)doneServerRequestWithFinishedArray:(NSArray *)array
{
    if(self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(serverDetailListRequestFinishWithUpdateModel:listArray:)])
    {
        self.resultArr = array;
        [self.requestDelegate serverDetailListRequestFinishWithUpdateModel:self
                                                                 listArray:array];
    }
}



@end
