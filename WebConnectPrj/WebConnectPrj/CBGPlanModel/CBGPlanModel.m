//
//  CBGPlanModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/29.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanModel.h"
@interface CBGPlanModel()

@property (nonatomic,strong) CBGPlanZhaohuanModel * zhaohuanModel;
@property (nonatomic,strong) CBGPlanZhuangbeiModel * zhuangbeiModel;

@end


@implementation CBGPlanModel


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
    
    //根据等级、区分实现
    EquipExtraModel * extra = detailModel.equipExtra;
    extra.priceDelegate =
    
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
