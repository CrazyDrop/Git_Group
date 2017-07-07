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

@interface ZWPanicUpdateListBaseRequestModel ()
{
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
@end

@implementation ZWPanicUpdateListBaseRequestModel

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
    
    //进行库表存储
//    list.listSaveModel = nil;
    CBGListModel * cbgModel = [list listSaveModel];
    cbgModel.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;
    [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:@[cbgModel]];

    
    @synchronized (localCacheArr)
    {
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
    
    EquipListRequestModel * listRequest = (EquipListRequestModel *)_dpModel;
    if(listRequest.executing) return;
    
    //    [requestLock lock];
    
    NSLog(@"%s %@",__FUNCTION__,self.tagString);
    
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
#pragma mark EquipListRequestModel
handleSignal( EquipListRequestModel, requestError )
{
//    [self refreshListRequestErrorWithFinishDelagateWithError:[NSError errorWithDomain:NSURLErrorDomain code:100 userInfo:nil]];
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
    //列表数据排重，区分未上架数据、价格变动数据
    NSMutableDictionary * modelsDic = [NSMutableDictionary dictionary];
    NSMutableDictionary * priceDic = [NSMutableDictionary dictionary];
    NSDate * latestDate = nil;//找出来最晚时间
    for (NSInteger index = 0 ;index < [array count]; index ++ )
    {
        NSInteger backIndex = [array count] - index - 1;
        Equip_listModel * eveModel = [array objectAtIndex:backIndex];
        NSDate * sellDate = [NSDate fromString:eveModel.selling_time];

        NSString * orderSN = eveModel.game_ordersn;
        if(eveModel.equipState == CBGEquipRoleState_unSelling)
        {
            [modelsDic setObject:eveModel forKey:orderSN];
        }else
        {
            //时间戳判定，
            if(self.lineDate)
            {
                NSTimeInterval count = [sellDate timeIntervalSinceDate:self.lineDate];
                if(count > 0)
                {
                    //进行库表查询，价格判定，筛选响应数据
                    NSArray * orderArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
                    if([orderArr count] > 0)
                    {
                        CBGListModel * pre = [orderArr firstObject];
                        if(pre.equip_price != [eveModel.price integerValue])
                        {
                            eveModel.appendHistory = pre;
                            [priceDic setObject:eveModel forKey:orderSN];
                        }
                    }else{
                        [modelsDic setObject:eveModel forKey:orderSN];
                    }
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
    
    
    //检查发送消息通知
    if([priceDic count] > 0){
        [self refreshTableViewWithInputLatestListArray:[priceDic allValues] cacheArray:nil];
    }
    [self checkUnSellingListArrayPostSubNotificationWithArray:[modelsDic allValues]];

    //有时候会因为部分请求失败，造成检索范围有误
    [self autoRefreshListRequestNumberWithLatestBackNumber:[array count]];
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

-(void)checkUnSellingListArrayPostSubNotificationWithArray:(NSArray *)array
{
    if([array count] == 0) return;
    @synchronized (localCacheArr)
    {
        for (NSInteger index = 0;index < [array count] ;index ++ )
        {
            Equip_listModel * eve = [array objectAtIndex:index];
            NSString * combine = eve.listCombineIdfa;
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
