//
//  EquipModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "EquipModel.h"
#import "NSData+Extension.h"
#import "NSDate+Extension.h"
#import "CBGPlanModel.h"
@implementation EquipModel
-(CBGListModel *)listSaveModel
{
    //判定是否需要清空
    if(_listSaveModel)
    {
        //以详情数据为准
        EquipModel * detail = self;
        if(detail)
        {//价格或状态发生变化，进行变更
            if([detail.price integerValue] != _listSaveModel.equip_price ||
               [detail.status integerValue] != _listSaveModel.equip_status)
            {
                _listSaveModel = nil;
            }
            if(detail.appointed_roleid)
            {
                _listSaveModel = nil;
            }
        }
    }
    
    if(!_listSaveModel)
    {
        EquipModel * detail = self;
        
        CBGListModel * list = [[CBGListModel alloc] init];
        
        list.game_ordersn = self.game_ordersn;
        list.owner_roleid = detail.owner_roleid;
        list.server_id = [self.serverid intValue];
        
        list.equip_status = [detail.status intValue];

        list.equip_level =      [detail.equip_level intValue];
        list.equip_name =       detail.owner_nickname;
        if(detail)
        {
            list.equip_id = [detail.equipid integerValue];
            list.equip_price = [detail.price integerValue];
            if(list.equip_price == 0)
            {
                list.equip_price = [self.last_price_desc integerValue] * 100;
            }
            
            list.equip_start_price = [detail.last_price_desc intValue];
        }
        
        list.equip_eval_price = 0;
        list.equip_type = detail.equip_type;
        list.kindid = [detail.kindid integerValue];
        
        if(detail.appointed_roleid && [detail.appointed_roleid length] > 0)
        {
            list.appointed = YES;
        }
        
        
        EquipExtraModel * extra = detail.equipExtra;
        list.equip_school =     [extra.iSchool intValue];
        if(list.equip_school == 0)
        {
            list.equip_school = [CBGListModel schoolNumberFromSchoolName:self.equip_name];
        }
        
        CBGPlanModel * planModel = [CBGPlanModel planModelForDetailEquipModel:detail];
        list.plan_total_price = planModel.total_price;
        list.plan_xiulian_price = planModel.xiulian_plan_price;
        list.plan_chongxiu_price = planModel.chongxiu_plan_price;
        list.plan_jineng_price = planModel.jineng_plan_price;
        list.plan_jingyan_price = planModel.jingyan_plan_price;
        list.plan_qiannengguo_price = planModel.qiannengguo_plan_price;
        list.plan_qianyuandan_price = planModel.qianyuandan_plan_price;
        list.plan_dengji_price = planModel.dengji_plan_price;
        list.plan_jiyuan_price = planModel.jiyuan_plan_price;
        list.plan_menpai_price = planModel.menpai_plan_price;
        list.plan_fangwu_price = planModel.fangwu_plan_price;
        list.plan_xianjin_price = planModel.xianjin_plan_price;
        list.plan_haizi_price = planModel.haizi_plan_price;
        list.plan_xiangrui_price = planModel.xiangrui_plan_price;
        list.plan_zuoji_price = planModel.zuoji_plan_price;
        list.plan_fabao_price = planModel.fabao_plan_price;
        list.plan_zhaohuanshou_price = planModel.zhaohuanshou_plan_price;
        list.plan_zhuangbei_price = planModel.zhuangbei_plan_price;
        list.plan_rate = planModel.plan_rate;
        list.plan_des = [planModel description];
        list.server_check = planModel.server_check;
        
        list.equip_more_append = [list createLatestMoreAppendString];
        
        list.equip_price_common = [detail.web_last_price_desc integerValue];
        list.equip_accept = [detail.allow_bargain integerValue];
        
        //        NSArray * array = [detail.selling_info lastObject].infoArray;
        //        ExtraModel * extraModel = [array lastObject];
        
        list.sell_start_time = detail.selling_time;
        list.sell_create_time = detail.create_time;
        list.sell_sold_time = [detail equipSoldOutResultTime];
        list.sell_back_time = [detail equipCancelBackResultTime];
        
        if(!list.sell_start_time){
            list.sell_start_time = @"";
        }
        if(!list.sell_create_time){
            list.sell_create_time = @"";
        }
        if(!list.sell_sold_time)
        {
            list.sell_sold_time = @"";
        }
        if(!list.sell_back_time)
        {
            list.sell_back_time = @"";
        }
        if([list.sell_sold_time length] > 0)
        {
            NSDate * createDate = [NSDate fromString:detail.selling_time];
            NSDate * soldDate = [NSDate fromString:list.sell_sold_time];
            NSTimeInterval timeNum = [soldDate timeIntervalSinceDate:createDate];
            if(timeNum <= 0){
                timeNum = 1;
            }
            list.sell_space = timeNum;
        }
        //结束时间的获取
        //        if([list latestEquipListStatus] == CBGEquipRoleState_BuyFinish || [list latestEquipListStatus] == CBGEquipRoleState_PayFinish)
        //        {
        //            list.sell_sold_time = extraModel.extraString;
        //        }else if([list latestEquipListStatus] == CBGEquipRoleState_Backing)
        //        {
        //            list.sell_back_time = extraModel.extraString;;
        //        }
        
        //本地时间两个
        list.sell_order_time = [NSDate unixDate];
        list.sell_cancel_time = list.sell_order_time;
        
        if(detail){
            list.serverName = [NSString stringWithFormat:@"%@-%@",detail.area_name,detail.server_name];
        }else{
            list.serverName = @"";
        }
        
        //        list.sell_order_time = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_ORDER];
        //        list.sell_cancel_time = [resultSet stringForColumn:ZADATABASE_TABLE_EQUIP_KEY_SELL_CANCEL];
        
        _listSaveModel = list;
    }
    return _listSaveModel;
}


-(BOOL)isAutoStopSelling
{
    if(!self.equipExtra) return NO;
    
    EquipModel * detail = self;
    //    NSString * leftTime = detail.sell_expire_time_desc;
    if([detail.sell_expire_time_desc isEqualToString:@"5分钟"])
    {
        return YES;
    }

    
    NSDate * sellDate = [NSDate fromString:detail.selling_time];
    NSDate * finishDate = [NSDate dateWithTimeInterval:DAY * 14 sinceDate:sellDate];
    NSDate * nowDate = [NSDate date];
    
    //使用商品锁定时间、用户下架也会造成，没有自动下架时间，只能默认14天使用
    //    finishDate = [NSDate fromString:detail.equip_lock_time];
    NSTimeInterval interval = [nowDate timeIntervalSinceDate:finishDate];
    if(interval > 0)
    {
        return YES;
    }
    
    return NO;
}


+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"statuses" : @"MJStatus",
             @"ads" : @"MJAd"
             };
}

-(CBGEquipRoleState)equipState
{
    CBGEquipRoleState status = CBGEquipRoleState_None;
    NSInteger number = [self.status integerValue];
    switch (number)
    {
        case 0:
        {
            status = CBGEquipRoleState_Backing;
        }
            break;
        case 1:
        {
            status = CBGEquipRoleState_unSelling;
        }
            break;
        case 2:
        {
            status = CBGEquipRoleState_InSelling;
        }
            break;
            
        case 3:
        {
            status = CBGEquipRoleState_InOrdering;
        }
            break;
        case 4:
        {
            status = CBGEquipRoleState_PayFinish;
        }
            break;
        case 5:
        {
            //交易完成，认为和购买一致
            status = CBGEquipRoleState_BuyFinish;
        }
            break;
        case 6:
        {
            status = CBGEquipRoleState_BuyFinish;
        }
            break;
            
        default:
            break;
    }
    
    return status;
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    /*  [Example] change property id to productID
     *
     *  if([key isEqualToString:@"id"]) {
     *
     *      self.productID = value;
     *      return;
     *  }
     */
    
    // show undefined key
//    NSLog(@"%@.h have undefined key '%@', the key's type is '%@'.", NSStringFromClass([self class]), key, [value class]);
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    // ignore null value
    if ([value isKindOfClass:[NSNull class]]) {
        
        return;
    }
    // bargain_info
    if ([key isEqualToString:@"bargain_info"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[Bargain_infoModel alloc] initWithDictionary:value];
    }

    // cross_buy_serverids
    if ([key isEqualToString:@"cross_buy_serverids"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            Cross_buy_serveridsModel *model = [[Cross_buy_serveridsModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    // highlight
    if ([key isEqualToString:@"highlight"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            HighlightModel *model = [[HighlightModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    // selling_info
    if ([key isEqualToString:@"selling_info"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            Selling_infoModel *model = [[Selling_infoModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    // poundage_list
    if ([key isEqualToString:@"poundage_list"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            Poundage_listModel *model = [[Poundage_listModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }
    if ([key isEqualToString:@"equipExtra"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[EquipExtraModel alloc] initWithDictionary:value];
        
    }

    [super setValue:value forKey:key];
}
-(NSDictionary *)detailDesDicFromCurrentDesc
{
    NSString * result = self.equip_desc;
    
    return nil;
}
-(NSString *)equipSoldOutResultTime
{
    NSString * soldTime = nil;
    for (NSInteger index = 0; index < [self.selling_info count]; index ++)
    {
        Selling_infoModel * info = [self.selling_info objectAtIndex:index];
        if(info.soldTime)
        {
            soldTime = info.soldTime;
        }
    }
    if(!soldTime) return nil;
//         03-30 13:24 //补全时间数据，售出时间没有年份，
//    2017-03-31 17:32:08
//    self.fair_show_end_time
    NSDate * showDate = [NSDate fromString:self.selling_time];
    showDate = [showDate dateByAddingTimeInterval:-1 * DAY];
    NSString * soldDateStr = [NSString stringWithFormat:@"%ld-%@:00",showDate.year,soldTime];
    NSDate * soldDate = [NSDate fromString:soldDateStr];//当售出时间早于展示时间，
    //公示期结束的时间
    if([soldDate timeIntervalSinceDate:showDate] < 0)
    {
        soldDateStr = [NSString stringWithFormat:@"%ld-%@:00",showDate.year + 1,soldTime];
    }

    return soldDateStr;
}
-(NSString *)equipCancelBackResultTime
{
    NSString * soldTime = nil;
    for (NSInteger index = 0; index < [self.selling_info count]; index ++)
    {
        Selling_infoModel * info = [self.selling_info objectAtIndex:index];
        if(info.backTime)
        {
            soldTime = info.backTime;
        }
    }
    if(!soldTime) return nil;
    //         03-30 13:24 //补全时间数据
    //    2017-03-31 17:32:08
    NSDate * nowDate = [NSDate date];
    NSString * soldDateStr = [NSString stringWithFormat:@"%ld-%@:00",nowDate.year,soldTime];
    return soldDateStr;
}

-(NSString *)detailStatusDes
{
    NSString * statusDes = nil;
    NSInteger number = [self.status integerValue];
    switch (number)
    {
        case 0:
        {
            statusDes = @"已取回";
        }
            break;
        case 1:
        {
            statusDes = @"暂存";
//            status = CBGEquipRoleState_unSelling;
        }
            break;
        case 2:
        {
            statusDes = @"上架中";
//            status = CBGEquipRoleState_InSelling;
        }
            break;
            
        case 3:
        {
            statusDes = @"下单中";
//            status = CBGEquipRoleState_InOrdering;
        }
            break;
        case 4:
        {
            statusDes = @"已付款";
//            status = CBGEquipRoleState_PayFinish;
        }
            break;
        case 5:
        {
            //交易完成，认为和购买一致
            statusDes = @"已取走";
//            status = CBGEquipRoleState_BuyFinish;
        }
            break;
        case 6:
        {
            statusDes = @"已取走";
//            status = CBGEquipRoleState_BuyFinish;
        }
            break;
            
        default:
            break;
    }
    return statusDes;
}

-(BOOL)isFirstInSelling
{
    EquipModel * detail = self;
    NSDate * createDate = [NSDate fromString:detail.create_time];
    NSDate * sellDate = [NSDate fromString:detail.selling_time];
    
    NSTimeInterval interval = [sellDate timeIntervalSinceDate:createDate];
    if(interval < 60 * 60 * 24 )
    {
        
    }
    if(interval < 60 * 5){
        return YES;
    }
    
    return NO;
}
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        if (self = [super init]) {
            
            [self setValuesForKeysWithDictionary:dictionary];
        }
    }
    
    return self;
}

@end

