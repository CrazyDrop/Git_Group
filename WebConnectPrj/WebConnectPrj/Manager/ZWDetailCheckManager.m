//
//  ZWDetailCheckManager.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/4/21.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDetailCheckManager.h"
#import "Equip_listModel.h"
#import "EquipModel.h"
#import "ZALocationLocalModel.h"
#import "YYCache.h"
#define DetailFinishAddNumber  100000   //10万等级
#define DetailFinishStatusNumber  1000000  //100万等级
@interface ZWDetailCheckManager()<NSCacheDelegate>
{
#if  !TARGET_IPHONE_SIMULATOR
    //真机
    YYCache * statusCache;  //缓存历史status
    YYCache * priceCache;   //缓存历史price
#else
    NSCache * statusCache;
    NSCache * priceCache;
#endif
    
    NSMutableArray * statusArray;
    CBGListModel * stateModel;
    
}
@property (nonatomic,assign) BOOL foreRefresh;
@property (nonatomic,strong) NSArray * localUpdateModels;
@property (nonatomic,assign) BOOL timerState;//通过随机时间控制状态变更

@property (nonatomic,assign) NSArray * updateDBArr;
@end

@implementation ZWDetailCheckManager
+(instancetype)sharedInstance
{
    static ZWDetailCheckManager *shareZWDetailCheckManagerInstance = nil;
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
        statusArray = [NSMutableArray array];
        //缓存当前已经存储的数据
        
#if  !TARGET_IPHONE_SIMULATOR
        //真机
        statusCache = [YYCache cacheWithName:@"list_ordersn_status_cache"];
        priceCache = [YYCache cacheWithName:@"list_ordersn_money_cache"];
#else
        statusCache = [[NSCache alloc] init];
        statusCache.countLimit = 10000;
        priceCache = [[NSCache alloc] init];
        priceCache.countLimit = 10000;
#endif
        
        stateModel = [[CBGListModel alloc] init];
        
        [self startFirstTimerUpdate];
    }
    return self;
}

-(void)startFirstTimerUpdate
{
    NSInteger count = arc4random() % 20 + 10;
    self.timerState = !self.timerState;
    
    NSTimeInterval second = count * 60;
    
    [self performSelector:@selector(startFirstTimerUpdate) withObject:nil afterDelay:second];
}
-(BOOL)refreshListRequestUpdate
{
    return self.timerState;
}

//筛选需要请求详情的listModel   1、当前已经截止的数据 (取回 售出)  2、从未请求过的数据
-(NSArray *)checkLatestBackListDataModelsWithBackModelArray:(NSArray *)backArray
{
    //所有数据，进行排重后使用
    NSMutableDictionary * modelsDic = [NSMutableDictionary dictionary];
    
    //1、筛选当前需要进行详情请求的数据进行详情请求
    //2、筛选需要进行库表更新的数据进行库表更新  包括三个表
    for (NSInteger index = 0 ;index < [backArray count]; index ++ )
    {
        Equip_listModel * eveModel = [backArray objectAtIndex:index];
        NSString * identifier = eveModel.detailCheckIdentifier;
        NSNumber * status = eveModel.equip_status;
        NSNumber * price = eveModel.price;
        BOOL eveResult = [self checkWebRequestLocalSaveEquipListModelWithEveListModel:eveModel];
        if(eveResult)
        {
            if(!price)
            {
                price = [NSNumber numberWithInteger:0];
            }
            [modelsDic setObject:eveModel forKey:identifier];
            [statusCache setObject:status forKey:identifier];
            [priceCache setObject:price forKey:identifier];
        }
    }
    
    NSArray * requestArr = [modelsDic allValues];
    return requestArr;
}
-(BOOL)checkWebRequestLocalSaveEquipListModelWithEveListModel:(Equip_listModel *)eveModel
{
    BOOL result = NO;
    NSString * identifier = eveModel.detailCheckIdentifier;
    NSNumber * status = eveModel.equip_status;
    NSNumber * price = eveModel.price;
    NSString * orderSN = eveModel.game_ordersn;
    if(!price)
    {
        price = [NSNumber numberWithInteger:0];
    }

    NSNumber * prePrice = (NSNumber *)[priceCache objectForKey:identifier];
    NSNumber * preStatus = (NSNumber *)[statusCache objectForKey:identifier];
    
    CBGEquipRoleState latestState = [self statusStateFromNum:status];
    CBGEquipRoleState preState = [self statusStateFromNum:preStatus];

    
    //如果没缓存，则进行存储，有缓存，则进行判定，状态判定不一致即处理
    if(!preStatus)
    {//没有之前的状态，表明请求失败，或者没有请求过
        //进行库表检查，库表不存在缓存，库表价格变化大的继续
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        NSArray * dbArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
        if([dbArr count] > 0)
        {
            CBGListModel * list = [dbArr lastObject];
            if([list.sell_sold_time length] > 0 || [list.sell_back_time length] > 0){
                //之前已经结束，不在进行
                preState = CBGEquipRoleState_PayFinish;
            }else{
                preState = CBGEquipRoleState_InSelling;
            }
            prePrice = [NSNumber numberWithInteger:list.equip_price];
        }
    }
    
    
    if(preState == CBGEquipRoleState_None){
        //之前没状态
        result = YES;
    }else if(preState == CBGEquipRoleState_PayFinish ||
       preState == CBGEquipRoleState_BuyFinish ||
       preState == CBGEquipRoleState_Backing){
        //之前已经结束，不再处理
        result = NO;
    }else {
        //状态 无变化不请求
        if([status isEqual:preStatus])
        {
            result = NO;
        }else {

            if(price && [price intValue] > 0 && [prePrice intValue] > [price intValue]){
                result = YES;
            }
            if(latestState == CBGEquipRoleState_unSelling){
                result = YES;
            }
        }
    }
    
    return result;
}


//库表修改,仅修改order表，sell表修改后置  与网络请求一起
-(void)refreshLocalDBHistoryWithLatestBackModelArr:(NSArray *)backArray
{
    return;
    //当前批次，存在网络请求，后续发起，筛选
    NSMutableArray * orderArr = [NSMutableArray array];
    NSMutableArray * sellArr = [NSMutableArray array];
    
    for (NSInteger index = 0 ;index < [backArray count]; index ++ )
    {
        Equip_listModel * eveModel = [backArray objectAtIndex:index];
        NSString * identifier = eveModel.detailCheckIdentifier;
        NSNumber * status = eveModel.equip_status;
        NSNumber * price = eveModel.price;
        
        NSNumber * prePrice = (NSNumber *)[priceCache objectForKey:identifier];
        NSNumber * preStatus = (NSNumber *)[statusCache objectForKey:identifier];
        if([status isEqual:preStatus] && [price isEqual:prePrice])
        {//已经准备发起网络请求，或不需要
            continue;
        }
        
        CBGEquipRoleState latestState = [self statusStateFromNum:status];
        CBGEquipRoleState preState = [self statusStateFromNum:preStatus];

        //2变为3 3变为2  均需要更新订单表，状态变更仅两种
        BOOL orderUpdate = (preState == CBGEquipRoleState_InSelling
                            && latestState == CBGEquipRoleState_InOrdering) ||
        (preState == CBGEquipRoleState_InOrdering
         && latestState == CBGEquipRoleState_InSelling);
        
        if(orderUpdate)
        {//需要库表更新，但是展示，仅选择当前被下单的即可
            [orderArr addObject:eveModel];
        }

        
        //                sell表，仅详情请求后处理
        BOOL sellUpdate =  (preState == CBGEquipRoleState_unSelling && (
                            latestState == CBGEquipRoleState_InSelling ||
                            latestState == CBGEquipRoleState_InOrdering));
        
        if(sellUpdate)
        {
            [sellArr addObject:eveModel];
        }
        //进行库表数据更新，返回对应的库表历史数据
    }
    
    [self updateLocalOrderAndChangeDatabaseWithSellArr:sellArr andOrderArr:orderArr];
    
}

//完成库表填充、对强制刷新的数据，进行数据补全
-(NSArray *)updateLocalOrderAndChangeDatabaseWithSellArr:(NSArray *)sellArray andOrderArr:(NSArray *)orderArr
{
    //进行库表刷新
    if((!sellArray || [sellArray count] == 0)&&(!orderArr || [orderArr count] == 0))
    {
        return nil;
    }
    NSMutableArray * totalUpdateArray = [NSMutableArray array];
    
    
    NSMutableArray * list_order = [NSMutableArray array];
    NSMutableArray * list_sell = [NSMutableArray array];
    NSMutableArray * list_role = [NSMutableArray array];

    //更新sell表
    for (NSInteger index = 0; index < [sellArray count]; index++)
    {
        Equip_listModel * aListModel = [sellArray objectAtIndex:index];
        NSString * orderSN = aListModel.game_ordersn;
        //结束后进行刷新
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        NSArray * modelArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
        NSArray * dbSellArr = [dbManager localSaveUserChangeHistoryListForOrderSN:orderSN];
        if([modelArr count] == 0 || [dbSellArr count] == 0)
        {
            NSLog(@"history error sell %ld %ld",[modelArr count],[dbSellArr count]);
            [statusCache removeObjectForKey:aListModel.detailCheckIdentifier];
            continue;
        }
        CBGListModel * dbSellModel = [dbSellArr lastObject];
        CBGListModel * dbTotalModel = [modelArr lastObject];
        dbTotalModel.equip_status = [aListModel.equip_status integerValue];
        dbTotalModel.sell_start_time = dbSellModel.sell_start_time;
        
        CBGEquipRoleState state = dbTotalModel.latestEquipListStatus;
        if(state == CBGEquipRoleState_InSelling)
        {
            dbTotalModel.sell_start_time = [NSDate unixDate];
            [list_sell addObject:dbTotalModel];
        }
        
        aListModel.listSaveModel = dbTotalModel;
        [totalUpdateArray addObject:aListModel];
    }
    //更新order表
    for (NSInteger index = 0; index < [orderArr count]; index++)
    {
        Equip_listModel * aListModel = [orderArr objectAtIndex:index];
        NSString * orderSN = aListModel.game_ordersn;
        //结束后进行刷新
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        NSArray * modelArr = [dbManager localSaveEquipHistoryModelListForOrderSN:orderSN];
        NSArray * dbSellArr = [dbManager localSaveUserChangeHistoryListForOrderSN:orderSN];
        if([modelArr count] == 0 || [dbSellArr count] == 0)
        {
            NSLog(@"history error sell %ld %ld",[modelArr count],[dbSellArr count]);
            [statusCache removeObjectForKey:aListModel.detailCheckIdentifier];
            continue;
        }
        CBGListModel * dbSellModel = [dbSellArr lastObject];
        CBGListModel * dbTotalModel = [modelArr lastObject];
        dbTotalModel.equip_status = [aListModel.equip_status integerValue];
        dbTotalModel.sell_start_time = dbSellModel.sell_start_time;
        
        NSString * latest = [NSDate unixDate];
        dbTotalModel.sell_order_time = latest;
        dbTotalModel.sell_cancel_time = latest;
        
        if([dbTotalModel latestEquipListStatus] == CBGEquipRoleState_InOrdering){
            dbTotalModel.sell_cancel_time = @"";
        }else{
            dbTotalModel.sell_order_time = @"";
        }
        
        [list_order addObject:dbTotalModel];
        
        aListModel.listSaveModel = dbTotalModel;
        [totalUpdateArray addObject:aListModel];
    }

    
    //刷新库表
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    if([list_sell count]>0)
    {
        [dbManager localSaveUserChangeArrayListWithDetailCBGModelArray:list_sell];
    }
    if([list_order count]>0)
    {
        [dbManager localSaveMakeOrderArrayListDetailCBGModelArray:list_order];
    }
    if([list_role count]>0)
    {
//        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:list_role];
    }
    return totalUpdateArray;

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
        Equip_listModel * list = [array objectAtIndex:index];
        NSString * idenfifier = list.detailCheckIdentifier;
        if(list.equipModel)
        {///详情请求成功的
            NSNumber * finishNum = list.equip_status;
            NSNumber * price = list.price;
            if(!price)
            {
                price = [NSNumber numberWithInteger:0];
            }
            [statusCache setObject:finishNum forKey:idenfifier];
            [priceCache setObject:price forKey:idenfifier];
            
            CBGListModel * cbgList = [list listSaveModel];
            cbgList.dbStyle = CBGLocalDataBaseListUpdateStyle_UpdateTime;
            [updateArr addObject:cbgList];
            
            NSDate * startDate = [NSDate fromString:list.equipModel.selling_time];
            NSTimeInterval count = [latestDate timeIntervalSinceDate:startDate];
            if(!latestDate || count < 0)
            {
                latestDate = startDate;
            }
            
            if(!self.ingoreUpdate || (self.ingoreUpdate && [list isFirstInSelling])){
                [editArr addObject:list];
            }

        }else{
            [statusCache removeObjectForKey:idenfifier];
        }
    }
    
    if(self.foreRefresh)
    {//强制刷新，网络请求的结果无效
        [editArr removeAllObjects];
    }
    //若屏蔽本地数据，筛选时不赋值
    [editArr addObjectsFromArray:self.localUpdateModels];

    
    if(latestDate && [editArr count] > 0 && !self.foreRefresh)
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



@end
