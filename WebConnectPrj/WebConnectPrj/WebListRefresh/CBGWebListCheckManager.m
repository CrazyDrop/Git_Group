//
//  CBGWebListCheckManager.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/25.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGWebListCheckManager.h"
#import "YYCache.h"
#import "WebEquip_listModel.h"
#import "ZALocationLocalModel.h"
@interface CBGWebListCheckManager()
{
//    YYCache * historyCache;
//不在使用缓存，统一使用库表查询
    NSCache * statusCache;
    NSCache * priceCache;
    NSCache * evalCache;
    CBGListModel * stateModel;
}
@end
@implementation CBGWebListCheckManager
+(instancetype)sharedInstance
{
    static CBGWebListCheckManager *shareZWDetailCheckManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWDetailCheckManagerInstance = [[[self class] alloc] init];
    });
    return shareZWDetailCheckManagerInstance;
}
-(id)init
{
    self = [super init];
    if(self){
        //缓存当前已经存储的数据
//        historyCache = [YYCache cacheWithName:@"web_ordersn_cache"];
        //缓存数据仅作为中间变量使用
        
        priceCache = [[NSCache alloc] init];
        priceCache.countLimit = 10000;
        statusCache = [[NSCache alloc] init];
        statusCache.countLimit = 10000;
        evalCache = [[NSCache alloc] init];
        evalCache.countLimit = 1000;
#if  !TARGET_IPHONE_SIMULATOR
        priceCache.countLimit = 3000;
        statusCache.countLimit = 3000;
        evalCache.countLimit = 3000;
#endif
        stateModel = [[CBGListModel alloc] init];

    }
    return self;
}

//筛选需要请求详情的listModel   1、当前已经截止的数据 (取回 售出)  2、从未请求过的数据
-(NSArray *)checkLatestBackListDataModelsWithBackModelArray:(NSArray *)backArray
{
    //所有数据，进行排重后使用
    NSMutableDictionary * modelsDic = [NSMutableDictionary dictionary];
    
    NSMutableDictionary * refreshDic = [NSMutableDictionary dictionary];
    
    //1、筛选当前需要进行详情请求的数据进行详情请求
    //2、筛选需要进行库表更新的数据进行库表更新  包括三个表
    for (NSInteger index = 0 ;index < [backArray count]; index ++ )
    {
        WebEquip_listModel * eveModel = [backArray objectAtIndex:index];
        NSString * identifier = eveModel.detailCheckIdentifier;
        NSNumber * status = eveModel.status;
        NSString * price = eveModel.price;
        NSNumber * evalPrice = eveModel.eval_price;
        
        BOOL priceResult = [self checkHistoryPriceWithLatestEveModel:eveModel];
        BOOL statusResult = [self checkHistoryStatusWithLatestEveModel:eveModel];
        
        if(statusResult && priceResult){
            //两者均有变化，还价成交的类型，进行详情请求
            continue;
        }else if(!statusResult && !priceResult){
            [modelsDic setObject:eveModel forKey:identifier];
        }else if(!statusResult && priceResult){
            //下单取消、购买、结束等
            [modelsDic setObject:eveModel forKey:identifier];
        }else if(statusResult && !priceResult){
            //状态未变，价格改变
//            eveModel.appendHistory.equip_price = [price integerValue] * 100;
            eveModel.appendHistory.equip_accept = [eveModel.can_bargain integerValue];
            eveModel.appendHistory.sell_start_time = [NSDate unixDate];
            eveModel.appendHistory.dbStyle = CBGLocalDataBaseListUpdateStyle_RefreshEval;
            eveModel.appendHistory.equip_eval_price = [eveModel.eval_price integerValue];
            eveModel.appendHistory.plan_rate = eveModel.appendHistory.price_rate_latest_plan;
            //            eveModel.appendHistory.sell_order_time = [NSDate unixDate];
            //            eveModel.appendHistory.sell_cancel_time = [NSDate unixDate];
            
            eveModel.earnRate = eveModel.appendHistory.price_rate_latest_plan;
            eveModel.earnPrice = eveModel.appendHistory.price_earn_plan;
            
            [refreshDic setObject:eveModel forKey:identifier];
        }
        
        if(!price)
        {
            price = @"0";
        }
        if(!evalPrice)
        {
            evalPrice = @0;
        }
        [evalCache setObject:evalPrice forKey:identifier];
        [statusCache setObject:status forKey:identifier];
        [priceCache setObject:price forKey:identifier];
    }
    
    NSArray * dataArr = [refreshDic allValues];
    self.refreshArr = dataArr;
    
    //库表操作
    NSMutableArray * updateArr = [NSMutableArray array];
    for (WebEquip_listModel * eveModel in dataArr)
    {
        if(eveModel.appendHistory)
        {
            [updateArr addObject:eveModel.appendHistory];
        }
    }
    
    if([updateArr count] > 0)
    {
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:updateArr];
        [dbManager localSaveUserChangeArrayListWithDetailCBGModelArray:updateArr];
    }
    
    NSArray * models = [modelsDic allValues];
    self.modelsArray = models;
    return models;
}
//价格不存在、进行数据请求//状态不存在，进行详情请求
-(BOOL)checkHistoryPriceWithLatestEveModel:(WebEquip_listModel *)eveModel
{//返回价格比对结果，相同yes，不同NO
    //不再使用缓存，历史全部库表查询
    BOOL result = NO;
    NSString * orderSN = eveModel.game_ordersn;
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * dbArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
    if([dbArr count] > 0)
    {
        CBGListModel * list = [dbArr lastObject];
        eveModel.appendHistory = list;
        
        //估价价格都相同
        if(([eveModel.eval_price integerValue] == 0 || [eveModel.eval_price integerValue] == list.equip_eval_price) && [eveModel.price integerValue] == list.equip_price / 100)
        {
            //估价需要更新返回NO
            result = YES;
        }else if(eveModel.equipState != CBGEquipRoleState_InSelling && eveModel.equipState != CBGEquipRoleState_InOrdering)
        {//非购买状态
            result = YES;
        }else
        {
            NSInteger hisPrice = list.equip_price;
            list.historyPrice = hisPrice;
            list.equip_price = [eveModel.price integerValue] * 100;
        }
    }
    

    return result;
}

-(BOOL)checkHistoryStatusWithLatestEveModel:(WebEquip_listModel *)eveModel
{
//    NSNumber * status = eveModel.status;
    NSString * orderSN = eveModel.game_ordersn;
//    NSString * identifier = eveModel.detailCheckIdentifier;
    
    BOOL result = NO;
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * dbArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
    if([dbArr count] > 0)
    {
        result = YES;
//        CBGListModel * list = [dbArr lastObject];
//        if([list.sell_sold_time length] > 0 || [list.sell_back_time length] > 0){
//            //之前已经结束，不在进行
//            result = YES;
//        }else if(eveModel.equipState == CBGEquipRoleState_InOrdering)
//        {
//            result = YES;
//        }
    }
    
    return result;
}

-(CBGEquipRoleState)statusStateFromNum:(NSNumber *)aNum
{
    CBGEquipRoleState status = CBGEquipRoleState_None;
    if(aNum)
    {
        stateModel.equip_status = [aNum intValue];
        status = [stateModel latestEquipListStatus];
    }
    return status;
}

-(void)refreshLocalSaveDBListModelWithArray:(NSArray *)array
{
    
}

//方法调用，进行详情信息的筛选展示
-(void)refreshDiskCacheWithDetailRequestFinishedArray:(NSArray *)array
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    
    //统计进行修改   缓存数据增加DetailFinishAddNumber
    NSMutableArray * updateArr = [NSMutableArray array];
    NSMutableArray * editArr = [NSMutableArray array];
    
    NSDate * latestDate = nil;
    //详情数据请求成功的，新增数据，筛选首次的进行展示
    for (NSInteger index = 0;index < [array count] ;index ++ )
    {
        WebEquip_listModel * list = [array objectAtIndex:index];
        NSString * idenfifier = list.detailCheckIdentifier;
        if(list.equipModel)
        {///详情请求成功的
            NSNumber * finishNum = list.status;
            NSString * price = list.price;
            if(!price)
            {
                price = @"0";
            }
            [statusCache setObject:finishNum forKey:idenfifier];
            [priceCache setObject:price forKey:idenfifier];
            
            CBGListModel * cbgList = [list listSaveModel];
            cbgList.dbStyle = CBGLocalDataBaseListUpdateStyle_RefreshEval;
            [updateArr addObject:cbgList];
            
            NSDate * startDate = [NSDate fromString:list.equipModel.selling_time];
            NSTimeInterval count = [latestDate timeIntervalSinceDate:startDate];
            if(!latestDate || count < 0)
            {
                latestDate = startDate;
            }
            
            [editArr addObject:list];
            
        }else{
            [statusCache removeObjectForKey:idenfifier];
        }
    }
    
    if(latestDate && [editArr count] > 0)
    {
        NSDate * nowDate = [NSDate date];
        NSTimeInterval count = [nowDate timeIntervalSinceDate:latestDate];
        [DZUtils noticeCustomerWithShowText:[NSString stringWithFormat:@"%.0f",count]];
    }
    
    
    //    NSLog(@"finishArr %ld filterArray %ld refresh %ld",[array count],[editArr count],[self.show_Models count]);
    NSLog(@"filterArray %ld ",[editArr count]);
    self.filterArray = editArr;
    
    //根据updateArr  更新主表
    if([updateArr count] > 0)
    {
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:updateArr];
        [dbManager localSaveUserChangeArrayListWithDetailCBGModelArray:updateArr];
    }
    
}

//返回需要详情刷新的列表
//-(void)checkLatestBackListDataModelsWithBackModelArray:(NSArray *)array
//{
//    //缓存
//    if(!array)
//    {
//        self.urlsArray = nil;
//        self.modelsArray = nil;
//        return;
//    }
//     
//    NSMutableArray * requestUrlsArr = [NSMutableArray array];
//    NSMutableArray * requestArr = [NSMutableArray array];
//    
//    for (NSInteger index = 0 ;index < [array count]; index ++ )
//    {
//        NSInteger backIndex = [array count] - index - 1;
//        WebEquip_listModel * eveModel = [array objectAtIndex:backIndex];
//        NSString * url = eveModel.detailDataUrl;
//        NSString * identifier = eveModel.detailCheckIdentifier;
//        NSString * price = eveModel.price;
//        if(!price){
//            price = @"0";
//        }
//        
//        if(![self checkLocalHistoryWithEveWebListModel:eveModel]){
//            //不需要进行请求
//            continue;
//        }
//        
//        if(url)
//        {
//            if(![requestUrlsArr containsObject:url])
//            {
//                [requestUrlsArr insertObject:url atIndex:0];
//                [requestArr insertObject:eveModel atIndex:0];
//            }
//            
//            //0为有启动过1为成功2为失败
//            [priceCache setObject:price forKey:identifier];
//            [statusCache setObject:[NSNumber numberWithInt:0] forKey:identifier];
//        }
//    }
//    
//    self.modelsArray = requestArr;
//    self.urlsArray = requestUrlsArr;
//}

//返回yes，则需要请求
-(BOOL)checkLocalHistoryWithEveWebListModel:(WebEquip_listModel *)eveModel
{
    BOOL request = NO;//是否包含历史，默认不需要
    NSString * identifier = eveModel.detailCheckIdentifier;
    NSString * orderSN = eveModel.game_ordersn;
    NSString * price = eveModel.price;
    if(!price){
        price = @"0";
    }
    
    NSString * prePrice = [priceCache objectForKey:identifier];
    //如果没缓存，则进行存储，有缓存，则进行判定，状态判定不一致即处理
    NSNumber * cacheNum = (NSNumber *) [statusCache objectForKey:identifier];
    if([cacheNum integerValue] ==0  && prePrice)
    {//没有缓存过或缓存失败，进行详情请求
        //缓存数据处理
    }else{
        //读取库表数据
        if(YES)
        {
            ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
            NSArray * dbArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
            if([dbArr count] > 0)
            {
                CBGListModel * list = [dbArr lastObject];
                prePrice = [NSString stringWithFormat:@"%ld",list.equip_price/100];
            }
        }
    }

    //之前价格不存在，或价格改动100以上，需要请求
    NSInteger change = [prePrice integerValue] - [price integerValue] ;
    if(!prePrice || change > 100)
    {
        request = YES;
    }

    return request;
}



    
    
@end
