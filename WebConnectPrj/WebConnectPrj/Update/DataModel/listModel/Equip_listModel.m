//
//  Equip_listModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "Equip_listModel.h"
#import "EquipExtraModel.h"
#import "NSDate+Extension.h"
#import "CBGPlanModel.h"
@implementation Equip_listModel
-(BOOL)isFirstInSelling
{
    if(!self.equipModel) return NO;
    if(!self.equipModel.equipExtra) return NO;
    
    EquipModel * detail = self.equipModel;
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
-(BOOL)isAutoStopSelling
{
    if(!self.equipModel) return NO;
    if(!self.equipModel.equipExtra) return NO;

    EquipModel * detail = self.equipModel;
//    NSString * leftTime = detail.sell_expire_time_desc;
    
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

-(void)refrehLocalBaseListModelWithDetail:(EquipModel *)detail
{//补全list信息，以便能够进行listSaveModel生成
    self.equipModel = detail;
    self.equip_status = detail.status;
    self.desc_sumup = detail.desc_sumup;
    self.price = detail.price;
    self.equip_name = detail.equip_name;
//    self.listSaveModel = nil;
    
}

//-(CGFloat)earnRate
//{
//    if(!_earnRate)
//    {
//        _earnRate = [[self createLatestRate] floatValue];
//    }
//    return _earnRate;
//}
//-(NSString *)createLatestRate
//{
//    if(!self.earnPrice || !self.detaiModel.last_price_desc) return nil;
//    EquipModel * detail = self.detaiModel;
//    NSString * rate  = [NSString stringWithFormat:@"%.0f",[self.earnPrice floatValue] * 100/[detail.last_price_desc floatValue]];
//    return rate;
//}

- (NSString * )detailCheckIdentifier
{
    NSString * identifier = self.game_ordersn;
    if(self.price_desc)
    {
//        identifier = [identifier stringByAppendingFormat:@"-%@",self.price_desc];
    }
    return identifier;
}
- (NSString * )detailDataUrl
{
    if(!self.serverid || !self.game_ordersn)
    {
        NSLog(@"none url serverId:%@ sn:%@",self.serverid,self.game_ordersn);
        return nil;
    }
//    http://xyq-ios2.cbg.163.com/app2-cgi-bin//query.py?serverid=443&game_ordersn=525_1480680251_527287531&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=%E5%BC%A0%E8%B6%85%E7%BE%A4%E7%9A%84%20iPhone&os_name=iPhone%20OS&os_version=9.1&device_id=AC3A0755-1BFF-4B8E-9970-9097A296E519
    NSString * url = [NSString stringWithFormat:@"http://xyq-ios2.cbg.163.com/app2-cgi-bin/query.py?serverid=%@&game_ordersn=%@&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.9&device_name=iPhone&os_name=iPhoneOS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8",self.serverid,self.game_ordersn];
    return url;
}
- (NSString * )detailWebUrl
{
    if(!self.serverid || !self.game_ordersn){
        return nil;
    }
//    http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=443&ordersn=525_1480680251_527287531&equip_refer=1
    NSString * url = [NSString stringWithFormat:@"http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=%@&ordersn=%@&equip_refer=1",self.serverid,self.game_ordersn];
    return url;
    return nil;
}
- (NSString * )listCombineIdfa{
    if(!self.serverid || !self.game_ordersn){
        return nil;
    }
    //    http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=443&ordersn=525_1480680251_527287531&equip_refer=1
    
    NSString * idfa = nil;

    if (self.selling_time && [self.selling_time length] > 0)
    {
        idfa = [NSString stringWithFormat:@"%@|%@|%@",self.game_ordersn,self.serverid,self.selling_time];
    }else
    {
        idfa = [NSString stringWithFormat:@"%@|%@",self.game_ordersn,self.serverid];

    }
    return idfa;
}

//计算公式，判定账号是否值得购买
- (BOOL)preBuyEquipStatusWithCurrentExtraEquip
{
//    if([self isFirstInSelling]){
//        return YES;
//    }
    
    if([self.equipModel.appointed_roleid length] > 0)
    {
        return NO;
    }
    CGFloat earnRate = self.earnRate;
//    if((earnRate > 0 && [self.serverid integerValue]!=45))
//    {
//        return YES;
//    }
    
    if((earnRate > 8 && [self.serverid integerValue]!=45))
    {
        return YES;
    }
    
    //    if([self.eval_price intValue]/100 > [self.price intValue])
    //    {
    //        return YES;
    //    }
    
    return NO;
}

-(CBGListModel *)listSaveModel
{
    //判定是否需要清空
    if(_listSaveModel)
    {
        //以详情数据为准
        EquipModel * detail = self.equipModel;
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
        }else
        {
            if([self.price integerValue] != _listSaveModel.equip_price ||
               [self.equip_status integerValue] != _listSaveModel.equip_status)
            {
                _listSaveModel = nil;
            }

        }
    }
    
    if(!_listSaveModel)
    {
        EquipModel * detail = self.equipModel;
        
        CBGListModel * list = [[CBGListModel alloc] init];
        
        list.game_ordersn = self.game_ordersn;
        list.owner_roleid = detail.owner_roleid;
        list.server_id = [self.serverid intValue];
        
        if(!self.equipModel){
            list.equip_status = [self.equip_status intValue];
        }else{
            list.equip_status = [detail.status intValue];
        }
        
        
        list.equip_level =      [detail.equip_level intValue];
        list.equip_name =       detail.owner_nickname;
        if(detail)
        {
            list.equip_id = [detail.equipid integerValue];
            list.equip_price = [detail.price integerValue];
            if(list.equip_price == 0)
            {
                list.equip_price = [self.listLatestShowPrice integerValue] * 100;
            }
            
            list.equip_start_price = [detail.last_price_desc intValue];
        }else
        {
            list.equip_price = [self.price intValue];
            list.equip_start_price = [self.price intValue]/100;
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
-(NSString *)listLatestShowPrice
{
    NSString * show = self.price_desc;
    if(!show || [show length] == 0)
    {
        EquipModel * detail = self.equipModel;
        if(self.price)
        {
            show = [NSString stringWithFormat:@"%d",[self.price intValue]/100];
        }else if(detail)
        {
            NSNumber * num = detail.price;
            if(num){
                show = [NSString stringWithFormat:@"%d",[num intValue]/100];
            }else
            {
                show = detail.price_desc;
                if(!show || [show length] == 0)
                {
                    show = detail.last_price_desc;
                }
                if(!show || [show length] == 0){
                    show = detail.web_last_price_desc;
                }
            }
        }
    }
    return show;
}

-(CBGEquipRoleState)equipState
{
    CBGEquipRoleState status = CBGEquipRoleState_None;
    NSInteger number = [self.equip_status integerValue];
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
    if ([key isEqualToString:@"detaiModel"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[EquipModel alloc] initWithDictionary:value];

    }


    [super setValue:value forKey:key];
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

