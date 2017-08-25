//
//  CBGPlanModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/29.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanModel.h"
#import "LevelPlanModelBaseDelegate.h"
@interface CBGPlanModel()

@property (nonatomic,strong) CBGPlanZhaohuanModel * zhaohuanModel;
@property (nonatomic,strong) CBGPlanZhuangbeiModel * zhuangbeiModel;

@end


@implementation CBGPlanModel

//{1: "逍遥生", 2: "剑侠客", 3: "飞燕女", 4: "英女侠", 5: "巨魔王", 6: "虎头怪", 7: "狐美人", 8: "骨精灵", 9: "神天兵", 10: "龙太子", 11: "舞天姬", 12: "玄彩娥", 201: "偃无师", 203: "巫蛮儿", 205: "杀破狼", 207: "鬼潇潇", 209: "羽灵神", 211: "桃夭夭"}
+(NSString *)equipRoleTypeNameFromNumberId:(NSString *)idNum
{
    NSDictionary * nameDic = @{
                               @"1":@"逍遥生",
                               @"2":@"剑侠客",
                               @"3":@"飞燕女",
                               @"4":@"英女侠",
                               @"5":@"巨魔王",
                               @"6":@"虎头怪",
                               @"7":@"狐美人",
                               @"8":@"骨精灵",
                               @"9":@"神天兵",
                               @"10":@"龙太子",
                               @"11":@"舞天姬",
                               @"12":@"玄彩娥",
                               @"201":@"偃无师",
                               @"203":@"巫蛮儿",
                               @"205":@"杀破狼",
                               @"207":@"鬼潇潇",
                               @"209":@"羽灵神",
                               @"211":@"桃夭夭"};
    
    return [nameDic objectForKey:idNum];
}
//function get_role_iconid(type_id){var need_fix_range=[[13,24],[37,48],[61,72],[213,224],[237,248],[261,272]];for(var i=0;i<need_fix_range.length;i++){var range=need_fix_range[i];if(type_id>=range[0]&&type_id<=range[1]){type_id=type_id-12
//    break;}}
//    return type_id;}
+(NSInteger)get_role_iconid:(NSInteger)type_id
{
    NSArray * need_fix_range=@[@13,@37,@61,@213,@237,@261];
//    13-24
    
    for(NSInteger i=0;i<[need_fix_range count];i++)
    {
        NSInteger start = [need_fix_range[i] integerValue];
        NSInteger end = start + 11;
        
        if(type_id>=start&&type_id<=end)
        {
            type_id=type_id-12;
            break;
        }
    }
    return type_id;
}

//function get_role_kind_name(icon){var kindid=icon;if(icon>200){kindid=((icon-200-1)%12+1)+200;}else{kindid=((icon-1)%12+1);}
//    return RoleKindNameInfo[kindid];}
+(NSString *)get_role_kind_name:(NSInteger)icon
{
    NSInteger kindid=icon;
    if(icon>200){
        kindid=((icon-200-1)%12+1)+200;
    }else{
        kindid=((icon-1)%12+1);
    }
    NSString * num = [NSString stringWithFormat:@"%ld",kindid];
    return [CBGPlanModel equipRoleTypeNameFromNumberId:num];
}


//parse_role_kind_name:function(icon_id){var icon_id=get_role_iconid(icon_id);return get_role_kind_name(icon_id)}
+(NSString *)parse_role_kind_name:(NSInteger)icon_id
{
    icon_id=[CBGPlanModel get_role_iconid:icon_id];
    return [[CBGPlanModel class] get_role_kind_name:icon_id];
}


+(CBGPlanModel *)planModelForDetailEquipModel:(EquipModel *)detailModel
{
    if(!detailModel) return nil;
    
    CBGPlanModel * planModel = [[CBGPlanModel alloc] init];

    planModel.orderSn = detailModel.game_ordersn;
    planModel.serverId = [NSString stringWithFormat:@"%ld",(long)[detailModel.serverid integerValue]];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger minServerId = total.minServerId;
    NSInteger serverId = [detailModel.serverid integerValue];
    if(serverId != 45 && serverId < minServerId)
    {
        planModel.server_check = YES;
    }
    
    //根据筛选不同的代理 //根据等级、区分实现
    EquipExtraModel * extra = detailModel.equipExtra;
    extra.equipType = detailModel.equip_type;
    
    id<LevelPlanPriceBackDelegate> del = [LevelPlanModelBaseDelegate selectPlanModelFromExtraModel:extra];
    extra.priceDelegate = del;
    
    CBGPlanZhaohuanModel * zhaohuan = [CBGPlanZhaohuanModel planZhaohuanPriceModelFromEquipModelSummonArr:extra.AllSummon];
    planModel.zhaohuanModel = zhaohuan;
    planModel.zhaohuanshou_plan_price  = zhaohuan.total_price;

    CBGPlanZhuangbeiModel * zhuangbei = [CBGPlanZhuangbeiModel planZhuangbeiPriceModelFromAllEquipModel:extra.AllEquip];
    planModel.zhuangbeiModel = zhuangbei;
    planModel.zhuangbei_plan_price  = zhuangbei.total_price;

    planModel.xiulian_plan_price = extra.price_xiulian;
    planModel.chongxiu_plan_price = extra.price_chongxiu;
    planModel.jineng_plan_price = extra.price_jineng;
    planModel.jingyan_plan_price = extra.price_jingyan;
    planModel.qiannengguo_plan_price = extra.price_qiannengguo;
    planModel.qianyuandan_plan_price = extra.price_qianyuandan;
    planModel.dengji_plan_price = extra.price_dengji;
    planModel.jiyuan_plan_price = extra.price_jiyuan;
    planModel.menpai_plan_price = extra.price_menpai;
    planModel.fangwu_plan_price = extra.price_fangwu;
    planModel.xianjin_plan_price = extra.price_xianjin;
    planModel.haizi_plan_price = extra.price_haizi;
    planModel.xiangrui_plan_price = extra.price_xiangrui;
    planModel.zuoji_plan_price = extra.price_zuoji;
    planModel.fabao_plan_price = extra.price_fabao;
    
    NSInteger planMoney = [planModel totalCountPrice];
    if(planMoney == 0)
    {
        planMoney = -1;
    }
    
    planModel.total_price = planMoney;
    
    NSInteger coustMoney = [planModel totalPlanCoustMoneyWithTotalMoney:planMoney];
    NSInteger baseMoney = [detailModel.price integerValue] / 100;
    if(baseMoney == 0){
        baseMoney = [detailModel.last_price_desc integerValue];
    }
    NSInteger earn = planMoney - coustMoney -  baseMoney ;
    if(earn > 0)
    {
        planModel.earn_price = earn;
        planModel.plan_rate = earn /(baseMoney + 0.0) * 100;
    }
    
    return planModel;
}
-(NSInteger)totalPlanCoustMoneyWithTotalMoney:(NSInteger)total
{
//    NSInteger realPrice = self.equip_price/100;
    NSInteger price = total;
    NSInteger coustPrice = (NSInteger)price * 0.05;
    coustPrice = MIN(coustPrice, 1000);
    return coustPrice;
}

-(NSInteger)totalCountPrice
{
    NSInteger planPrice = 0;
    planPrice += self.zhaohuanModel.total_price;
    planPrice += self.zhuangbeiModel.total_price;
    
    planPrice += self.xiulian_plan_price;
    planPrice += self.chongxiu_plan_price;
    planPrice += self.jineng_plan_price;
    planPrice += self.jingyan_plan_price;
    planPrice += self.qiannengguo_plan_price;
    planPrice += self.qianyuandan_plan_price;
    planPrice += self.dengji_plan_price;
    planPrice += self.jiyuan_plan_price;
    planPrice += self.menpai_plan_price;
    planPrice += self.fangwu_plan_price;
    planPrice += self.xianjin_plan_price;
    planPrice += self.haizi_plan_price;
    planPrice += self.xiangrui_plan_price;
    planPrice += self.zuoji_plan_price;
    planPrice += self.fabao_plan_price;
    return planPrice;
}

-(NSString *)description
{
    NSMutableString * edit = [NSMutableString string];
    [edit appendFormat:@"总价 %.0ld ",(long)self.total_price];
    if(self.plan_rate > 0)
    {
        [edit appendFormat:@"收益 %.0ld(%.0ld) ",(long)self.earn_price,(long)self.plan_rate];
    }
    [edit appendFormat:@"修炼 %.0ld ",(long)self.xiulian_plan_price];
    [edit appendFormat:@"宠修 %.0ld ",(long)self.chongxiu_plan_price];
    [edit appendFormat:@"技能 %.0ld ",(long)self.jineng_plan_price];
    [edit appendFormat:@"经验 %.0ld ",(long)self.jingyan_plan_price];
    [edit appendFormat:@"潜能 %.0ld ",(long)self.qiannengguo_plan_price];
    [edit appendFormat:@"乾元丹 %.0ld ",(long)self.qianyuandan_plan_price];
    [edit appendFormat:@"等级 %.0ld ",(long)self.dengji_plan_price];
    [edit appendFormat:@"机缘 %.0ld ",(long)self.jiyuan_plan_price];
    [edit appendFormat:@"门派 %.0ld ",(long)self.menpai_plan_price];
    [edit appendFormat:@"房屋 %.0ld ",(long)self.fangwu_plan_price];
    [edit appendFormat:@"现金 %.0ld ",(long)self.xianjin_plan_price];
    [edit appendFormat:@"孩子 %.0ld ",(long)self.haizi_plan_price];
    [edit appendFormat:@"祥瑞 %.0ld ",(long)self.xiangrui_plan_price];
    [edit appendFormat:@"坐骑 %.0ld ",(long)self.zuoji_plan_price];
    [edit appendFormat:@"法宝 %.0ld ",(long)self.fabao_plan_price];
    [edit appendFormat:@"装备 %@ ",self.zhuangbeiModel];
    [edit appendFormat:@"宝宝 %@ ",self.zhaohuanModel];
    return edit;
}




@end
