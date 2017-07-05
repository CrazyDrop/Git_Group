//
//  CBGListModel.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGListModel.h"
#import "EquipModel.h"
#import "JSONKit.h"
#import "CBGPlanModel.h"
#define   EquipSchoolNumDic   [NSDictionary dictionaryWithObjectsAndKeys:@"大唐官府",@"1",@"化生寺",@"2",@"女儿村",@"3",@"方寸山",@"4",@"天宫",@"5",@"普陀山",@"6",@"龙宫",@"7",@"五庄观",@"8",@"狮驼岭",@"9",@"魔王寨",@"10",@"阴曹地府",@"11",@"盘丝洞",@"12",@"神木林",@"13",@"凌波城",@"14",@"无底洞",@"15",nil]
#define   EquipSchoolNameDic   [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"大唐官府",@"2",@"化生寺",@"3",@"女儿村",@"4",@"方寸山",@"5",@"天宫",@"6",@"普陀山",@"7",@"龙宫",@"8",@"五庄观",@"9",@"狮驼岭",@"10",@"魔王寨",@"11",@"阴曹地府",@"12",@"盘丝洞",@"13",@"神木林",@"14",@"凌波城",@"15",@"无底洞", nil]


@implementation CBGListModel
//@synthesize plan_des;

-(void)refreshCBGListDataModelWithDetaiEquipModel:(EquipModel *)aDetaiModel
{
    if(!aDetaiModel)
    {
        return;
    }
    self.detailRefresh = YES;
    self.equip_price = [aDetaiModel.price intValue];
    if(self.equip_price == 0)
    {
        self.equip_price = [aDetaiModel.last_price_desc intValue] * 100;
    }
    if(self.equip_price == 0)
    {
        self.equip_price = [aDetaiModel.web_last_price_desc intValue] * 100;
    }
    if(aDetaiModel.appointed_roleid && [aDetaiModel.appointed_roleid length] > 0)
    {
        self.appointed = YES;
    }
    
    self.equip_status = [aDetaiModel.status integerValue];
    self.equip_type = aDetaiModel.equip_type;
    self.kindid = [aDetaiModel.kindid integerValue];
    
    self.equip_more_append = [self createLatestMoreAppendString];

    
    CBGPlanModel * planModel = [CBGPlanModel planModelForDetailEquipModel:aDetaiModel];
    self.plan_total_price = planModel.total_price;
    self.plan_xiulian_price = planModel.xiulian_plan_price;
    self.plan_chongxiu_price = planModel.chongxiu_plan_price;
    self.plan_jineng_price = planModel.jineng_plan_price;
    self.plan_jingyan_price = planModel.jingyan_plan_price;
    self.plan_qiannengguo_price = planModel.qiannengguo_plan_price;
    self.plan_qianyuandan_price = planModel.qianyuandan_plan_price;
    self.plan_dengji_price = planModel.dengji_plan_price;
    self.plan_jiyuan_price = planModel.jiyuan_plan_price;
    self.plan_menpai_price = planModel.menpai_plan_price;
    self.plan_fangwu_price = planModel.fangwu_plan_price;
    self.plan_xianjin_price = planModel.xianjin_plan_price;
    self.plan_haizi_price = planModel.haizi_plan_price;
    self.plan_xiangrui_price = planModel.xiangrui_plan_price;
    self.plan_zuoji_price = planModel.zuoji_plan_price;
    self.plan_fabao_price = planModel.fabao_plan_price;
    self.plan_zhaohuanshou_price = planModel.zhaohuanshou_plan_price;
    self.plan_zhuangbei_price = planModel.zhuangbei_plan_price;
    self.plan_rate = planModel.plan_rate;
    self.plan_des = [planModel description];
    self.server_check = planModel.server_check;
    
    self.equip_accept = [aDetaiModel.allow_bargain integerValue];

    self.sell_order_time = [NSDate unixDate];
    self.sell_cancel_time = self.sell_order_time;
    
    self.sell_sold_time = [aDetaiModel equipSoldOutResultTime];
    self.sell_back_time = [aDetaiModel equipCancelBackResultTime];

    if(!self.sell_sold_time)
    {
        self.sell_sold_time = @"";
    }
    if(!self.sell_back_time)
    {
        self.sell_back_time = @"";
    }
    
    if([self.sell_sold_time length] > 0)
    {
        NSDate * createDate = [NSDate fromString:aDetaiModel.selling_time];
        NSDate * soldDate = [NSDate fromString:self.sell_sold_time];
        NSTimeInterval timeNum = [soldDate timeIntervalSinceDate:createDate];
        if(timeNum <= 0){
            timeNum = 1;
        }
        self.sell_space = timeNum;
    }
    
    if(aDetaiModel){
        self.serverName = [NSString stringWithFormat:@"%@-%@",aDetaiModel.area_name,aDetaiModel.server_name];
    }else{
        self.serverName = @"";
    }
}



// 1 未上架2 上架中3 被下单 6 已出售0 已取回
-(CBGEquipRoleState)latestEquipListStatus
{
//    @"大唐官府:1-阴曹地府:11-方寸山:4-化生寺:2-魔王寨:10-龙宫:7-神木林:13-凌波城:14-狮驼岭:9-无底洞:15-普陀山:6-天宫:5-五庄观:8-女儿村:3-盘丝洞:12"
    

    CBGEquipRoleState status = CBGEquipRoleState_None;
    NSInteger number = self.equip_status;
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
-(NSString * )equip_school_name
{
    NSString * name = @"门派";
    NSString * schoolNum = [NSString stringWithFormat:@"%ld",self.equip_school];
    NSString * value = [EquipSchoolNumDic valueForKey:schoolNum];
    if(value)
    {
        name = value;
    }
    return name;
}
+(NSInteger)schoolNumberFromSchoolName:(NSString *)name
{
    NSInteger schoolNum  = 0;
    NSString * value = [EquipSchoolNameDic valueForKey:name];
    if(value)
    {
        schoolNum = [value intValue];
    }
    return schoolNum;
}
+(NSString *)schoolNameFromSchoolNumber:(NSInteger)school
{
    NSString * name = @"门派";
    NSString * schoolNum = [NSString stringWithFormat:@"%ld",school];
    NSString * value = [EquipSchoolNumDic valueForKey:schoolNum];
    if(value)
    {
        name = value;
    }
    return name;

}
-(NSInteger)price_add_total_plan
{
    NSInteger total = self.plan_total_price;
    if(total > 0){
        return total;
    }
    total =
    self.plan_xiulian_price +
    self.plan_chongxiu_price +
    self.plan_jineng_price +
    self.plan_jingyan_price +
    self.plan_qianyuandan_price +
    self.plan_zhaohuanshou_price +
    self.plan_zhuangbei_price;
    return total;
}
-(NSInteger)price_rate_latest_plan
{
    if(self.equip_price == 0) return 0;
    NSInteger price = self.price_add_total_plan;
    NSInteger realPrice = self.equip_price/100;
    NSInteger coustPrice = (NSInteger)price * 0.05;
    coustPrice = MIN(coustPrice, 1000);
    
    CGFloat earnPrice = price - realPrice - coustPrice;

    if(earnPrice > 0)
    {
        NSString * rate = [NSString stringWithFormat:@"%.f",earnPrice/(realPrice + 0.0) * 100];
        return [rate intValue];
    }
    return 0;
}
-(NSInteger)price_earn_plan
{
    if(self.equip_price == 0) return 0;
    NSInteger price = self.price_add_total_plan;
    NSInteger realPrice = self.equip_price/100;
    NSInteger coustPrice = (NSInteger)price * 0.05;
    coustPrice = MIN(coustPrice, 1000);
    
    CGFloat earnPrice = price - realPrice - coustPrice;
    
    if(earnPrice > 0)
    {
        return earnPrice;
    }
    return 0;

}
- (NSString * )detailWebUrl
{
    if(!self.game_ordersn)
    {
        return nil;
    }
    //    http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=443&ordersn=525_1480680251_527287531&equip_refer=1
    NSString * url = [NSString stringWithFormat:@"http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=%ld&ordersn=%@&equip_refer=1",self.server_id ,self.game_ordersn];
    return url;
}
- (NSString * )detailDataUrl
{
    if(!self.game_ordersn)
    {
        return nil;
    }
    //    http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=443&ordersn=525_1480680251_527287531&equip_refer=1
    NSString * url = [NSString stringWithFormat:@"http://xyq-ios2.cbg.163.com/app2-cgi-bin/query.py?serverid=%ld&game_ordersn=%@&act=get_equip_detail&show_income_receive_mode=1&platform=ios&app_version=2.2.8&device_name=iPhone&os_name=iPhoneOS&os_version=9.1&device_id=DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8",self.server_id ,self.game_ordersn];
    return url;

}
- (NSString * )mobileAppDetailShowUrl
{
    if(!self.game_ordersn)
    {
        return nil;
    }
    
    NSString * baseUrl = @"netease-xyqcbg://show_equip/";
    NSString * url = [NSString stringWithFormat:@"?view_loc=link_qq&ordersn=%@&server_id=%ld&equip_refer=328" ,self.game_ordersn,(long)self.server_id];
    url = [baseUrl stringByAppendingString:url];
    return url;

}

-(CGFloat)price_base_equip
{
    //空号价格
    CGFloat empty = self.plan_xiulian_price +
                    self.plan_chongxiu_price +
                    self.plan_jineng_price +
                    self.plan_jingyan_price +
                    self.plan_qianyuandan_price;
    
    return empty;
}
-(BOOL)planMore_zhaohuan
{
    BOOL more = self.plan_zhaohuanshou_price > 1000;
    return more;
}
-(BOOL)planMore_Equip
{
    BOOL more = self.plan_zhaohuanshou_price > 500;
    return more;
}
- (BOOL)preBuyEquipStatusWithCurrentExtraEquip
{
    if(self.appointed)
    {
        return NO;
    }
    CGFloat earnRate = self.price_rate_latest_plan;
    
    if((earnRate > 8 && self.server_id!=45))
    {
        return YES;
    }
    
    //    if([self.eval_price intValue]/100 > [self.price intValue])
    //    {
    //        return YES;
    //    }
    
    return NO;
}
-(CBGEquipPlanStyle)style
{
    if(_style == CBGEquipPlanStyle_None)
    {
        CBGEquipPlanStyle aStyle = CBGEquipPlanStyle_None;
        NSArray * serverArr = @[@45];
        if(self.appointed || [serverArr containsObject:[NSNumber numberWithInteger:self.server_id]])
        {
            aStyle = CBGEquipPlanStyle_Ingore;
        }else{
            
            CGFloat earnRate = self.price_rate_latest_plan;
            if(earnRate > 8)
            {
                aStyle = CBGEquipPlanStyle_PlanBuy;
            }else if(earnRate > 0){
                aStyle = CBGEquipPlanStyle_Worth;
            }else{
                aStyle = CBGEquipPlanStyle_NotWorth;
            }
        }
        _style = aStyle;
    }
    return _style;
}
-(NSString *)createLatestMoreAppendString
{
    return @"";
    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:[NSNumber numberWithInteger:self.equip_huasheng] forKey:@"equip_huasheng"];
    [dataDic setObject:[NSNumber numberWithInteger:self.equip_price_common] forKey:@"equip_price_common"];
    [dataDic setObject:[NSNumber numberWithInteger:self.appointed] forKey:@"equip_appointed"];
    [dataDic setObject:[NSNumber numberWithInteger:self.errored] forKey:@"equip_errored"];
    
    NSString * jsonStr = [dataDic JSONString];
    return jsonStr;
}
-(void)readDataFromMoreAppendString
{
//    NSDictionary * dic = [self.equip_more_append objectFromJSONString];
//    self.equip_huasheng = [[dic objectForKey:@"equip_huasheng"] integerValue];
//    self.equip_price_common = [[dic objectForKey:@"equip_price_common"] integerValue];
//    self.appointed = [[dic objectForKey:@"equip_appointed"] boolValue];
//    self.errored = [[dic objectForKey:@"equip_errored"] boolValue];

}




@end
