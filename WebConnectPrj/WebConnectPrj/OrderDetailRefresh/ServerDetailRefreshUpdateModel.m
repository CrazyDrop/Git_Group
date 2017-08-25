//
//  ServerDetailRefreshUpdateModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/19.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ServerDetailRefreshUpdateModel.h"
#import "ServerDetailRefreshModel.h"
#import "ZWOperationEquipReqListReqModel.h"
#import "ZWOperationDetailListReqModel.h"
#import "ZWOperationAutoDetailListReqModel.h"
#import "ZALocalModelDBManager.h"
#import "ServerRefreshRequestModel.h"
#import "EquipSNAutoModel.h"
#import "Equip_listModel.h"
#import "ServerEquipIdRequestModel.h"
#import "ZWServerEquipModel.h"
#import "SessionReqModel.h"
#import "VPNProxyModel.h"
#import "ZWServerMoneyReqModel.h"
@interface ServerDetailRefreshUpdateModel ()
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

@property (nonatomic, assign) BOOL  listWait;
@property (nonatomic, assign) NSInteger  waitNum;

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
@property (nonatomic, strong) ZWServerEquipModel * equipModel;
//@property (nonatomic, strong) ZWServerEquipModel * equipModel2;

@property (nonatomic, assign) NSInteger tryNumbers;
@end

@implementation ServerDetailRefreshUpdateModel

-(id)init
{
    self = [super init];
    if (self)
    {
        self.minuteNum = 2;
        self.maxTestNum = 30;
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
        if(self.listWait && self.waitNum <= 5)
        {
            self.waitNum ++;
            return;
        }
        self.listWait = NO;
        [self startMobileServerListRequest];
    }else if(self.detailRequest)
    {//详情请求
        [self startServerListBackDetailRequestWithEquipModels:self.errorDetails];
    }else if(self.equipRequest)
    {//一次间隔10个请求1个，//进行equipid请求
        [self startLatestEquipIdRefreshAndCheck];
    }else
    {//时间递增
        [self startDetailArrayListRequest];
    }
}
-(void)refreshLatestFinishModelWithFinishedDetail:(EquipModel *)endDetail
{
    self.tryNumbers = 0;
    NSLog(@"%s %@ %@",__FUNCTION__,endDetail.serverid,endDetail.game_ordersn);
    self.latestDate = [NSDate fromString:endDetail.create_time];
    self.finishModel = [[EquipSNAutoModel alloc] initWithEquipSN:endDetail.game_ordersn andEquipId:[endDetail.equipid integerValue]];
    self.finishModel.serverId = self.serverNum;
    self.latestCheckDate = [NSDate dateWithTimeIntervalSinceNow:self.minuteNum * MINUTE];

}
-(void)refreshLatestFinishModelWithFinishedMoneyList:(Equip_listModel *)endList
{
    self.tryNumbers = 0;
    NSLog(@"%s %@ %@",__FUNCTION__,endList.serverid,endList.game_ordersn);
    self.latestDate = [NSDate fromString:endList.selling_time];
    self.finishModel = [[EquipSNAutoModel alloc] initWithEquipSN:endList.game_ordersn andEquipId:[endList.equipid integerValue]];
    self.finishModel.serverId = self.serverNum;
    self.latestCheckDate = [NSDate dateWithTimeIntervalSinceNow:self.minuteNum * MINUTE];
    
}



-(void)startMobileServerListRequest
{
    ServerEquipIdRequestModel * equipRefresh = (ServerEquipIdRequestModel *)_equipReqModel;
    if(equipRefresh.executing) return;
    
    ServerRefreshRequestModel * listRequest = (ServerRefreshRequestModel *)_dpModel;
    if(listRequest.executing) return;
    
    
    ZWOperationDetailListReqModel * detailRequest = (ZWOperationDetailListReqModel *)_detailListReqModel;
    if(detailRequest.executing) return;
    
    
    ZWOperationAutoDetailListReqModel * autoRequest = (ZWOperationAutoDetailListReqModel *)_detailAutoReqModel;
    if(autoRequest.executing) return;
    
    
    //    [requestLock lock];
//    NSLog(@"%s %@",__FUNCTION__,self.serverTag);
    
    ZWServerMoneyReqModel * model = (ZWServerMoneyReqModel *)_dpModel;
    //仅做数据刷新，不做展示   详情数据请求中时，列表数据也需要刷新
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[ZWServerMoneyReqModel alloc] init];
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

#pragma mark ZWServerMoneyReqModel
handleSignal( ZWServerMoneyReqModel, requestError )
{
    
}
handleSignal( ZWServerMoneyReqModel, requestLoading )
{
}
handleSignal( ZWServerMoneyReqModel, requestLoaded )
{
//    NSLog(@"%s %@",__FUNCTION__,self.serverNum);
    
    ServerRefreshRequestModel * model = (ServerRefreshRequestModel *) _dpModel;
    NSArray * total  = model.listArray;
    
    //正常序列
    NSMutableArray * array = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        NSArray * obj = [total objectAtIndex:backIndex];
        SessionReqModel * vpnObj = [model.baseReqModels objectAtIndex:index];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            BOOL effective = [self equipListServerNameCheckWithEquipListArray:obj];
            if(effective){
                [array addObjectsFromArray:obj];
            }else{
                vpnObj.proxyModel.errored = YES;
            }
        }
    }
    
    
    //列表数据排重
    NSInteger maxEquipId = 0;
    Equip_listModel * maxModel = nil;
    NSMutableDictionary * modelsDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0 ;index < [array count]; index ++ )
    {
        NSInteger backIndex = [array count] - index - 1;
        Equip_listModel * eveModel = [array objectAtIndex:backIndex];
        if(maxEquipId == 0 || maxEquipId < [eveModel.equipid integerValue]){
            maxEquipId = [eveModel.equipid integerValue];
            maxModel = eveModel;
        }
        
        NSArray * dbArr = [dbManager localSaveEquipHistoryModelListForOrderSN:eveModel.game_ordersn];
        if(!dbArr || [dbArr count] == 0)
        {
            [modelsDic setObject:eveModel forKey:eveModel.detailCheckIdentifier];
        }
    }
    
    if(maxEquipId == 0) return;
    
    NSArray * backArray = [modelsDic allValues];

    //当最大商品时间差过大时，使用equipid递增查找
    NSDate * latestDate = [NSDate fromString:maxModel.selling_time];
    latestDate = [latestDate dateByAddingTimeInterval:2 * MINUTE];
    if([latestDate timeIntervalSinceNow] < 0 && [backArray count] > 0)
    {
        if(!self.listWait)
        {
            NSLog(@"limit%@ id:%ld listWait %@",self.serverNum,maxEquipId,maxModel.selling_time);
            self.listWait = YES;
            self.waitNum = 0;
        }
//        //触发equipid检查
//        [self refreshLatestFinishModelWithFinishedMoneyList:maxModel];
//        self.equipRequest = YES;
//        self.listCheck = NO;
        return;
    }
    
    if([backArray count] > 0)
    {//有新发现的数据，直接使用
        self.listCheck = NO;
        [self refreshLatestFinishModelWithFinishedMoneyList:maxModel];
        
        if(self.equipEnable)
        {
            self.equipRequest = YES;
        }else{
            self.equipRequest = NO;
        }
    }else if(self.latestDate)
    {//修改倒计时时间、计数 统计量
        NSLog(@"无最新 继续时间递增");
        self.tryNumbers = 0;
        self.latestCheckDate = [NSDate dateWithTimeIntervalSinceNow:self.minuteNum * MINUTE];
        self.listCheck = NO;
    }
}
-(BOOL)equipListServerNameCheckWithEquipListArray:(NSArray *)arr
{
    BOOL effective = YES;
    for (NSInteger index = 0;index < [arr count] ;index ++ )
    {
        Equip_listModel * list = [arr objectAtIndex:index];
        NSString * name = list.server_name;
        if(![self.serverName containsString:name])
        {
            effective = NO;
            break;
        }
    }
    return effective;
}
-(void)startServerListBackDetailRequestWithEquipModels:(NSArray *)models
{
    ServerEquipIdRequestModel * equipRefresh = (ServerEquipIdRequestModel *)_equipReqModel;
    if(equipRefresh.executing) return;
    
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
    NSLog(@"%s %@ %ld",__FUNCTION__,self.serverNum,[array count]);
    
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
            
            NSDate * endDate = [NSDate fromString:detailEve.create_time];
            if(!totalEndDate)
            {
                totalEndDate = endDate;
                endDetail = detailEve;
            }else if([totalEndDate timeIntervalSinceDate:endDate] < 0)
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
    NSLog(@"%s %@ %ld/%ld",__FUNCTION__,self.serverNum,[err count],[total count]);

    
    if(totalEndDate)
    {//进行创建
        if(!self.latestDate || ([totalEndDate timeIntervalSinceDate:self.latestDate] > 0))
        {//开启下一个请求
            if([endDetail isFirstInSelling])
            {
                [self refreshLatestFinishModelWithFinishedDetail:endDetail];
                self.equipRequest = YES;
                self.detailRequest = NO;
                self.listCheck = NO;
            }
        }
    }else if(self.latestCheckDate && [self.latestCheckDate timeIntervalSinceNow] < 0)
    {//尝试的次数过多时，时间差达到20分钟
//        self.listCheck = YES;
    }
    
    if([localArr count] > 0)
    {
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:localArr];
    }
    
    if(!self.equipRequest)
    {
        if([err count] > 0)
        {
            //继续请求详情
            self.errorDetails = err;
            self.detailRequest = YES;
        }else{
            self.errorDetails = nil;
            self.detailRequest = NO;
            self.listCheck = YES;
        }
    }
    
    if([listArr count] > 0)
    {
        [self doneServerRequestWithFinishedArray:listArr];
    }
    
}
-(void)startDetailArrayListRequest
{
    ServerEquipIdRequestModel * equipRefresh = (ServerEquipIdRequestModel *)_equipReqModel;
    if(equipRefresh.executing) return;
    
    ServerRefreshRequestModel * listRequest = (ServerRefreshRequestModel *)_dpModel;
    if(listRequest.executing) return;
    
    
    ZWOperationDetailListReqModel * detailRequest = (ZWOperationDetailListReqModel *)_detailListReqModel;
    if(detailRequest.executing) return;
    
    
    ZWOperationAutoDetailListReqModel * autoRequest = (ZWOperationAutoDetailListReqModel *)_detailAutoReqModel;
    if(autoRequest.executing) return;
    
    
    //    [requestLock lock];
    
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
//    NSDate * endDate = [NSDate dateWithTimeIntervalSince1970:self.finishTimeNum];
//    NSLog(@"%s serverId %@ %@",__FUNCTION__,self.serverNum,endDate);
    
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
    
//    addNum = addNum/2;
//    NSInteger countNum = 0;
//    for (NSInteger index = 0;index < addNum ;index ++ )
//    {
//        if(equiModel.timeNum < maxTestNum)
//        {
//            countNum ++;
//            equiModel.timeNum ++;
//            [editArr addObject:equiModel.nextTryDetailDataUrl];
//            [editArr addObject:equiModel.next2TryDetailDataUrl];
//        }
//    }
    
    NSInteger countNum = 0;
    for (NSInteger index = 0;index < addNum ;index ++ )
    {
        if(equiModel.timeNum < maxTestNum)
        {
            countNum ++;
            equiModel.timeNum ++;
            [editArr addObject:equiModel.nextTryDetailDataUrl];
        }
    }
    
    self.tryNumbers += countNum;
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
    NSArray * sessionArr  = model.baseReqModels;

    NSMutableArray * detailModels = [NSMutableArray array];
    NSInteger errorNum = 0;
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        SessionReqModel * vpnObj = [sessionArr objectAtIndex:index];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            vpnObj.proxyModel.errored = YES;
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
                
                NSInteger curEquipId = labs([detailEve.equipid integerValue] - nextEquipId);
                if(nextEquipId > 0 &&  curEquipId > 2 ){
                    [err addObject:url];
                    continue;
                }
                
                NSDate * endDate = [NSDate fromString:detailEve.create_time];
                if(!totalEndDate)
                {
                    totalEndDate = endDate;
                    endDetail = detailEve;
                }else if([totalEndDate timeIntervalSinceDate:endDate] < 0)
                {
                    endDetail = detailEve;
                    totalEndDate = endDate;
                }
                
                Equip_listModel * obj = [[Equip_listModel alloc] init];
                endListModel = obj;
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
    
    
    self.erroredArr = err;
    
    NSDate * createDate = [NSDate fromString:endDetail.create_time];
    NSTimeInterval sepNum = [[NSDate date] timeIntervalSinceDate:createDate];
    
    if([localArr count] > 0)
    {
        NSLog(@"%s success %@ %@ %fs",__FUNCTION__,endDetail.serverid,endDetail.game_ordersn,sepNum);
    }else{
        NSDate * endDate = [NSDate dateWithTimeIntervalSince1970:self.finishTimeNum];
        NSLog(@"%s %@(error tryNum %ld %@)",__FUNCTION__,self.serverNum,self.tryNumbers,[endDate toString:@"HH:mm:ss"]);
    }
    
    if(sepNum > (self.minuteNum + 1) * MINUTE)
    {
        self.listCheck = YES;
        self.equipRequest = NO;
    }else if(totalEndDate)
    {//进行替换
        if(!self.latestDate || ([totalEndDate timeIntervalSinceDate:self.latestDate] > 0))
        {//开启下一个请求
            [self refreshLatestFinishModelWithFinishedDetail:endDetail];
        }
    }
    else  if((self.latestCheckDate && [self.latestCheckDate timeIntervalSinceNow] < 0))
    {//尝试的次数过多时，时间差达到20分钟，5分钟内没上架的产品，重新检查列表
        self.listCheck = YES;
        self.equipRequest = NO;
    }
    
    if(endListModel)
    {
        if([localArr count] > 0)
        {
            NSArray * dbArr = [dbManager localSaveEquipHistoryModelListForOrderSN:endListModel.game_ordersn];
            if(!dbArr || [dbArr count] == 0)
            {
                [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:localArr];
                [self doneServerRequestWithFinishedArray:@[endListModel]];
            }
        }
    }
    
}
#pragma mark  - EquipIdRequest
-(void)startLatestEquipIdRefreshAndCheck
{//前提条件，必须有finishModel
    
    ServerEquipIdRequestModel * equipRefresh = (ServerEquipIdRequestModel *)_equipReqModel;
    if(equipRefresh.executing) return;
    
    ServerRefreshRequestModel * listRequest = (ServerRefreshRequestModel *)_dpModel;
    if(listRequest.executing) return;
    
    
    ZWOperationDetailListReqModel * detailRequest = (ZWOperationDetailListReqModel *)_detailListReqModel;
    if(detailRequest.executing) return;
    
    
    ZWOperationAutoDetailListReqModel * autoRequest = (ZWOperationAutoDetailListReqModel *)_detailAutoReqModel;
    if(autoRequest.executing) return;
    
    NSMutableArray * editArr = [NSMutableArray array];
    if(!self.equipModel)
    {
        ZWServerEquipModel * aEquip = [[ZWServerEquipModel alloc] init];
        self.equipModel = aEquip;
    }
    ZWServerEquipModel * equip = self.equipModel;
    if(equip.checkMaxNum == 0)
    {//初始化
        equip.partSepNum = 5;
        equip.checkMaxNum = self.finishModel.nextEquipId + equip.partSepNum;
        equip.equipId = equip.checkMaxNum;
        equip.detailCheck = NO;
        equip.serverId = [self.serverNum integerValue];
    }
    
    [editArr addObject:self.equipModel];
    
//    NSLog(@"%s",__FUNCTION__);
    
    ServerEquipIdRequestModel * model = (ServerEquipIdRequestModel *)_equipReqModel;
    
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[ServerEquipIdRequestModel alloc] init];
        [model addSignalResponder:self];
        _equipReqModel = model;
        
        /*
         if(self.totalPageNum >= 3)
         {
         [self refreshLatestListRequestModelWithSmallList:YES];
         }
         if(self.maxRefresh)
         {
         model.pageNum = 100;
         }
         */
    }
    
    model.saveCookie = YES;
    model.serverArr = editArr;
    model.timerState = !model.timerState;
    [model sendRequest];
}
#pragma mark ServerEquipIdRequestModel
handleSignal( ServerEquipIdRequestModel, requestError )
{
    NSLog(@"%s",__FUNCTION__);
}
handleSignal( ServerEquipIdRequestModel, requestLoading )
{
}
handleSignal( ServerEquipIdRequestModel, requestLoaded )
{
    NSLog(@"%s",__FUNCTION__);
    
    //使用total给request赋值
    ServerEquipIdRequestModel * model = (ServerEquipIdRequestModel *) _equipReqModel;
    NSArray * total  = model.listArray;
    NSArray * request = model.serverArr;
    NSMutableArray * backArray = [NSMutableArray array];//用来展示的
    
    NSMutableArray * finishArr = [NSMutableArray array];
    NSMutableArray * randArr = [NSMutableArray array];
    NSMutableArray * waitingArr = [NSMutableArray array];
    
    
    if([total count] == [request count])
    {
        for (NSInteger index = 0;index < [total count] ;index ++ )
        {
            NSArray * objArr = [total objectAtIndex:index];
            ZWServerEquipModel * req = [request objectAtIndex:index];
            
            if([objArr isKindOfClass:[NSArray class]] && [objArr count] > 0)
            {
                EquipModel * detail = [objArr lastObject];
                req.detail = detail;
                req.equipDesc =  detail.equip_desc;
                req.orderSN = detail.game_ordersn;
                
                if([detail.game_ordersn length] > 0)
                {
                    Equip_listModel * list = [[Equip_listModel alloc] init];
                    list.serverid = detail.serverid;
                    list.game_ordersn = detail.game_ordersn;
                    list.equipModel = detail;
                    
                    [backArray addObject:list];
                }
                
                switch (detail.resultType)
                {
                    case ServerResultCheckType_Error:
                    {
                        [randArr addObject:detail];
                    }
                        break;
                    case ServerResultCheckType_Redirect:{
                        [waitingArr addObject:detail];
                    }
                        break;
                    case ServerResultCheckType_None:
                    {
                        [finishArr addObject:detail];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }else
    {
        NSLog(@"数量不相等");
    }
    
    //可能结果
    //得到验证码、中断，下次继续请求
    //得到不存在、停止刷新，选取上次ordersn进行处理
    //得到返回结果、比对equipid，继续下次请求
    
    //仅针对一个请求、单一处理
    ZWServerEquipModel * server = self.equipModel;
    ServerResultCheckType type = server.detail.resultType;
    switch (type)
    {
        case ServerResultCheckType_Success:
        {
            server.equipId += server.partSepNum;
            server.cookieClear = NO;
            [self refreshLatestFinishModelWithFinishedDetail:server.detail];
            
            server.detail = nil;
            server.equipDesc = nil;
            server.orderSN = nil;
            self.equipEnable = YES;
        }
            break;
        case ServerResultCheckType_NoneProduct:
        {
            server.cookieClear = YES;
            self.equipRequest = NO;
            self.equipEnable = YES;
        }
            break;
        case ServerResultCheckType_Error:
        {
            self.equipEnable = NO;
            self.endRefresh = YES;
            server.cookieClear = YES;
            [self doneServerRequestWithErroredBack];
        }
            break;
            
        default:
            break;
    }

}
-(void)doneServerRequestWithErroredBack
{
    if(self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(serverDetailRequestErroredWithUpdateModel:)])
    {
        [self.requestDelegate serverDetailUpdateRequestErroredWithUpdateModel:self];
    }
}

-(void)doneServerRequestWithFinishedArray:(NSArray *)array
{
    if(self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(serverDetailListUpdateRequestFinishWithUpdateModel:listArray:)])
    {
        self.resultArr = array;
        [self.requestDelegate serverDetailListUpdateRequestFinishWithUpdateModel:self
                                                                       listArray:array];
    }
}



@end
