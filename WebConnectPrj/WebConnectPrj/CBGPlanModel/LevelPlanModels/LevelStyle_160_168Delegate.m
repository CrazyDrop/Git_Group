//
//  LevelStyle_160_168Delegate.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "LevelStyle_160_168Delegate.h"
#import "EquipExtraModel.h"
@interface LevelStyle_160_168Delegate ()
@property (nonatomic, strong) EquipExtraModel * extraObj;
@end
@implementation LevelStyle_160_168Delegate

-(CGFloat)price_qianyuandan
{
    //    TA_iAllNewPoint新版乾元丹 5个以上算钱
    NSInteger number = [self.extraObj.TA_iAllNewPoint integerValue];
    
    NSInteger countNum = 2;
    if(number <= countNum)
    {
        return 0;
    }
    
    CGFloat price = 0;
    NSString * detailStr = @"450,550,690,850,1000,1250,1500,1520,1450";
    
    NSArray * eveArr = [detailStr componentsSeparatedByString:@","];
    if(number > [eveArr count])
    {
        number = [eveArr count] - 1;
    }
    
    CGFloat qianyuandan = 0;
    for (NSInteger index = countNum;index < number;index ++ )
    {
        NSString * eve = [eveArr objectAtIndex:index];
        qianyuandan += [eve floatValue];
    }
    
    CGFloat youxibi = qianyuandan ;
    price = youxibi/LevelPlanModelBaseYouxibiRateForMoney;
    price *= 0.65;
    
    return price;
}

-(CGFloat)price_jingyan
{
    CGFloat price = 0;
    //    sum_exp总经验
    NSInteger sup_total = [self.extraObj.sum_exp integerValue];
    if(sup_total < 180 ){
        price -= 200;
    }else {
        price = 0;
    }

    
    return price;
}

-(CGFloat)price_zhuangbei
{
    CGFloat price = 0;
    //装备价格，当前仅进行判定  8段以上估价  统一100块
    NSArray * detailEquipArr = [self.extraObj.AllEquip modelsArray];
    for (ExtraModel * eve in detailEquipArr)
    {
        CGFloat evemoney = [self detailCheckEquipSummonPriceWithSubSummon:eve];
        price += evemoney;
    }
    
    
    return price;
}
-(CGFloat)price_zhaohuanshou
{
    CGFloat price = 0;
    
    NSArray * arr = self.extraObj.AllSummon;
    for (AllSummonModel * eveSummon in arr)
    {
        NSInteger skillNum = 0;
        if([eveSummon.all_skills isKindOfClass:[All_skillsModel class]])
        {
            skillNum = [eveSummon.all_skills.skillsArray count];
        }
        
        //技能大于5技能以上，或者4技能宝宝，计算价格
        if(skillNum >=4)
        {
            if([eveSummon.iBaobao boolValue])
            {
                CGFloat evePrice = [eveSummon summonPlanPriceForTotal];
                price += evePrice;
            }else{
                
                if(skillNum > 5 && [eveSummon.iGrade integerValue] > 160)
                {
                    CGFloat evePrice = 20;
                    price += evePrice;
                }
                
            }
        }
    }
    
    return price;
}



-(CGFloat)price_youxibi
{
    CGFloat price = 0;
    
    CGFloat youxibi = [self.extraObj.iCash floatValue] + [self.extraObj.iLearnCash floatValue] + [self.extraObj.iSaving floatValue];
    youxibi = youxibi / 10000.0;
    if(youxibi > 1000){
        price = youxibi / LevelPlanModelBaseYouxibiRateForMoney ;
    }
    price *= 0.8;
    
    
    CGFloat xianyuPrice = 0;
    NSInteger xianyu = [self.extraObj.xianyu integerValue];
    if(xianyu > 500){
        xianyuPrice = xianyu/10.0;
        xianyuPrice *= 0.5;
    }
    price += xianyuPrice;
    
    
    return price;
}

-(CGFloat)price_xiulian
{
    //iExptSki 人物修炼(攻击 物抗 法术 法抗 猎术)   iMaxExpt人物修炼上线(攻击 物抗 法术 法抗)     CGFloat money = 0;
    CGFloat money = 0;
    
    NSInteger wuliNum = [self.extraObj.iExptSki1 integerValue];
    if([self.extraObj.iMaxExpt1 integerValue]< 25)
    {
        wuliNum -= (25 - [self.extraObj.iMaxExpt1 integerValue]);
    }
    
    NSInteger wukangNum = [self.extraObj.iExptSki2 integerValue];
    if([self.extraObj.iMaxExpt2 integerValue]< 25)
    {
        wukangNum -= (25 - [self.extraObj.iMaxExpt2 integerValue]);
    }
    
    NSInteger fashuNum = [self.extraObj.iExptSki3 integerValue];
    if([self.extraObj.iMaxExpt3 integerValue]< 25)
    {
        fashuNum -= (25 - [self.extraObj.iMaxExpt3 integerValue]);
    }
    
    NSInteger fakangNum = [self.extraObj.iExptSki4 integerValue];
    if([self.extraObj.iMaxExpt4 integerValue]< 25)
    {
        fakangNum -= (25 - [self.extraObj.iMaxExpt4 integerValue]);
    }
    
    //存在可能，20/22  价格没有  18/22高
    CGFloat wuli = [self xiulian_price_countForEveNum:wuliNum withAdd:YES];
    if(wuli == 0)
    {
        //仅上线没实质的，
        wuli = [self xiulian_price_countForEveNum:[self.extraObj.iMaxExpt1 integerValue] -5 withAdd:YES];
    }
    CGFloat wukang = [self xiulian_price_countForEveNum:wukangNum withAdd:NO];
    if(wukang == 0)
    {
        wukang = [self xiulian_price_countForEveNum:[self.extraObj.iMaxExpt2 integerValue]-5 withAdd:NO];
    }
    CGFloat fashu = [self xiulian_price_countForEveNum:fashuNum withAdd:YES];
    if(fashu == 0)
    {
        fashu = [self xiulian_price_countForEveNum:[self.extraObj.iMaxExpt3 integerValue]-5 withAdd:YES];
    }
    CGFloat fakang = [self xiulian_price_countForEveNum:fakangNum withAdd:NO];
    if(fakang == 0)
    {
        fakang = [self xiulian_price_countForEveNum:[self.extraObj.iMaxExpt4 integerValue]-5 withAdd:NO];
    }
    
    money = wuli + wukang + fashu + fakang;
    
    return money;
}

-(CGFloat)price_chongxiu
{
    //    13级以上计算价格
    // iBeastSki宝宝修(攻击 物抗 法术 法抗)  "221":20育兽术 all_skills 内
    CGFloat money = 0;
    //    宠修20-25  204个修炼果
    //@"150,210,290,390,510,650,810,990,1190,1410,1650,1910,2190,2490,2810,3150,3510,3890,4290,4710,5150,5610,6090,6590,7110"
    NSArray * baobaoArr = @[
                            self.extraObj.iBeastSki1,
                            self.extraObj.iBeastSki2,
                            self.extraObj.iBeastSki3,
                            self.extraObj.iBeastSki4,
                            ];
    
    for (NSInteger index = 0; index < [baobaoArr count]; index++)
    {
        NSInteger number = [[baobaoArr objectAtIndex:index] integerValue];
        CGFloat eveMoney = [self chongxiu_price_countForEveNum:number];
        money += eveMoney;
    }
    
    
    NSInteger yushouNum = 0;
    for (ExtraModel * model in self.extraObj.all_skills.skillsArray)
    {
        NSString * keyNum = model.extraTag;
        if([keyNum integerValue] == 221)
        {
            NSNumber * num = model.extraValue;
            yushouNum = [num integerValue];
            break;
        }
    }
    
    if(yushouNum > 20)
    {
        //35级花费6000W  约400块
        yushouNum *= (19.0/35.0);//视为低级抗
        CGFloat eveMoney = [self xiulian_price_countForEveNum:yushouNum withAdd:NO];
        money += eveMoney;
    }
    
    //    //宠修高  经验过低时，宠修估价0.7即宠修
    //    if(money > 4000 && [self.extraObj.sum_exp integerValue] < 300)
    //    {
    //        money *= 0.9;
    //    }
    //
    
    return money;
}

-(CGFloat)price_jineng
{
    //217熔炼  231淬灵   209追捕技巧  216巧匠之术   204打造技巧  205裁缝技巧  207炼金之术  212健身  206中药医理
    //211养生之道  210逃离技巧  230强壮 237神速 203暗器技巧  202冥想 208烹饪技巧  218灵石技巧 201强身
    //154变化之术  153丹元济会   160仙灵店铺  158奇门遁甲 161宝石工艺  （155 220 164)火眼金睛  154打坐 170妙手空空
    
    CGFloat money = 0;
    NSMutableArray * shimenArr = [NSMutableArray array];
    NSMutableArray * othersArr = [NSMutableArray array];
    
    
    for (NSInteger index = 0 ;index < [self.extraObj.all_skills.skillsArray count] ;index ++ )
    {
        ExtraModel * model = [self.extraObj.all_skills.skillsArray objectAtIndex:index];
        if([model isKindOfClass:[ExtraModel class]]){
            NSString * number = model.extraTag;
            if([number integerValue] < 150)
            {
                [shimenArr addObject:model];
            }else{
                [othersArr addObject:model];
            }
        }
    }
    
    NSArray * removeArr = [self.extraObj.AllEquip equipAddedSkillsNumberArrayFromEquipModel];
    removeArr = [removeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    //1 头盔  2衣服  3鞋子 4链子 5腰带 6武器
    NSMutableArray * levelArray = [NSMutableArray array];
    for (NSInteger index = 0;index <7;index ++)
    {
        NSInteger skillLevel = 0;
        if([shimenArr count] > index)
        {
            ExtraModel * model  = [shimenArr objectAtIndex:index];
            skillLevel = [model.extraValue integerValue];
        }
        [levelArray addObject:[NSNumber numberWithInteger:skillLevel]];
    }
    
    NSArray * skillLevelArr = [levelArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    CGFloat mainSkill = 0;
    
    for (NSInteger index = 0;index <[skillLevelArr count];index ++)
    {
        NSNumber * preLevel = [skillLevelArr objectAtIndex:index];
        NSNumber * removeLevel = [removeArr objectAtIndex:index];
        NSInteger skillLevel = [preLevel intValue] - [removeLevel intValue];
        CGFloat eveMoney = [self jineng_price_countForEveShiMenNum:skillLevel];
        mainSkill += eveMoney;
    }
    
    money += mainSkill;
    
    
    CGFloat othersPrice = 0;
    for (ExtraModel * model in othersArr)
    {
        CGFloat eveMoney = [self jineng_price_countForEveShenghuoKeyNum:model.extraTag andskillNum:[model.extraValue integerValue]];
        othersPrice += eveMoney;
    }
    money += othersPrice;
    
    return money;
}
-(CGFloat)price_qiannengguo
{
    CGFloat price = 0;
    NSInteger sup_total = [self.extraObj.sum_exp integerValue];
    if(sup_total > 300)
    {
        NSInteger qiannengguo = [self.extraObj.iNutsNum integerValue];
        if(qiannengguo < 80){
            price -= 1000;
        }
        else if(qiannengguo < 120)
        {
            price -= 500;
        }else if(qiannengguo < 150){
            price -= 300;
        }else if(qiannengguo < 190){
            price -= 150;
        }else if(qiannengguo < 195){
            price += 0;
        }else{
            price += 100;
        }
    }
    
    return price;
}
-(CGFloat)price_dengji
{
    CGFloat price = 0;
    NSInteger level = [self.extraObj.iGrade integerValue];
    
    return price;
}
-(CGFloat)price_jiyuan
{
    CGFloat price = 0;
    //机缘、减扣    //总数33，不用
    NSInteger maxNum = 36;
    NSInteger totalAdd = [self.extraObj.jiyuan integerValue] + [self.extraObj.addPoint integerValue];
    NSInteger needAdd = maxNum - totalAdd;
    
    if(needAdd > 10)
    {
        price -= (needAdd * 50);
    }else if(needAdd > 3){
        price -= (needAdd * 30);
    }else if(needAdd < 0){
        NSInteger moreNum = ABS(needAdd);
        if(moreNum > 3){
            price += (50) * (moreNum - 3);
        }
    }
    return price;
}
-(CGFloat)price_menpai
{
    CGFloat price = 0;
    NSInteger school = [self.extraObj.iSchool integerValue];
    price = [self countSchoolPriceForSchoolNum:school];
    
    NSArray * history = self.extraObj.changesch;
    
    NSInteger maxHistory = 0;
    for (NSInteger index = 0; index < [history count]; index ++)
    {
        ChangeschModel * eve = [history objectAtIndex:index];
        NSInteger eveNum = [self countSchoolPriceForSchoolNum:[eve.intNum integerValue]];
        
        //判定历史门派是否有效，主要验证龙宫是否有魔属性
        BOOL effective = [self checkHistorySchoolEffectiveWithPreSchool:[eve.intNum integerValue]];
        if(effective)
        {
            if(maxHistory < eveNum){
                maxHistory = eveNum;
            }
        }
    }
    
    price = MAX(price, maxHistory - 200);
    
    return price;
}
-(CGFloat)price_fangwu
{
    CGFloat price = 0;
    NSInteger fangwu = [self.extraObj.rent_level integerValue];
    NSInteger muchang = [self.extraObj.farm_level integerValue];
    
    //房子，无房子扣钱
    CGFloat fangziPrice = 0;
    if(fangwu == 0)
    {
        fangziPrice -= 300;
    }else if(fangwu < 3){
        fangziPrice -= 100;
    }else if(muchang >= 3){
        fangziPrice += 100;
    }
    
    
    return price;
}
-(CGFloat)price_xianjin
{
    //    1点点卡=1点仙玉=10精力 0.1元，500精力=50仙玉=50点卡 = 5块钱
    CGFloat price = 0;
    
    CGFloat youxibi = [self.extraObj.iCash floatValue] + [self.extraObj.iLearnCash floatValue] + [self.extraObj.iSaving floatValue];
    youxibi = youxibi / 10000.0;
    if(youxibi > 1000){
        price = youxibi / LevelPlanModelBaseYouxibiRateForMoney ;
    }
    price *= 0.8;
    
    
    CGFloat xianyuPrice = 0;
    NSInteger xianyu = [self.extraObj.xianyu integerValue];
    if(xianyu > 500){
        xianyuPrice = xianyu/10.0;  //50仙玉=5块钱
        xianyuPrice *= 0.5;//仙玉半价
    }
    price += xianyuPrice;
    
    //精力
    CGFloat jingliPrice = 0;
    NSInteger jingli = [self.extraObj.energy integerValue];
    if(jingli > 5000){
        jingliPrice = jingli/100.0;//500精力= 5块钱
        jingliPrice *= 0.2;//精力2折
    }
    price += jingliPrice;
    
    
    return price;
}
-(CGFloat)price_haizi{
    CGFloat price = 0;
    
    NSMutableArray * childArr = [NSMutableArray array];
    if(self.extraObj.child){
        [childArr addObject:self.extraObj.child];
    }
    if(self.extraObj.child2){
        [childArr addObject:self.extraObj.child2];
    }
    
    for (NSInteger index = 0;index < [childArr count] ;index++ )
    {
        ChildModel * aChild = [childArr objectAtIndex:index];
        if([aChild.grow integerValue] > 1280){
            NSArray * arr = aChild.all_skills.skillsArray;
            NSMutableArray * skills = [NSMutableArray array];
            for (NSInteger eve = 0;eve < [arr count] ;eve++)
            {
                ExtraModel * eta = [arr objectAtIndex:eve];
                [skills addObject:eta.extraTag];
            }
            
            // 581  556  //针灸、蚩尤
            //648、636、649  金刚不坏、地涌金莲、
            //  |568|585|560   推拿、杨柳甘露、五行学说、
            //635金身舍利
            //631清心
            //569还魂
            //            NSLog(@"ChildModelSkill %@",[skills componentsJoinedByString:@"|"]);
            if([skills count] >= 6 && [skills containsObject:@"411"])
            {
                //加血技能、拉人技能、解封
                if([skills containsObject:@"569"] || [skills containsObject:@"631"] || [skills containsObject:@"560"])
                {
                    price += 80;
                }
            }
        }
    }
    
    
    
    
    return price;
}

-(CGFloat)price_xiangrui{
    CGFloat price = 0;
    NSArray  * xiangruiArr = self.extraObj.HugeHorse.zuoJiModelsArray;
    
    for (NSInteger index = 0;index < [xiangruiArr count] ;index ++ )
    {
        ExtraModel * eveExtra = [xiangruiArr objectAtIndex:index];
        if(![eveExtra.extraTag isEqualToString:@"113"]){
            price += 10;
        }
    }
    
    if([xiangruiArr count] == 0)
    {
        price -= 200;
    }else if(price == 0){
        price -= 150;
    }
    
    //成就价格、混合在祥瑞价格内
    NSInteger addNum = [self.extraObj.AchPointTotal integerValue];
    NSInteger chengjiu = 0;
    if(addNum > 4500)
    {
        chengjiu += (addNum - 4000) * 1.2;
        
    }else if(addNum > 3900){
        chengjiu += (addNum - 3900) * 1;
    }
    
    price += chengjiu;
    
    NSInteger special = 0;
    NSArray * specialArr = @[@"神行小驴",
                             @"七彩小驴",
                             @"粉红小驴",
                             @"飞天猪猪",
                             @"九尾冰狐",
                             @"飞天猪猪",
                             @"幽骨战龙",
                             @"甜蜜猪猪",
                             @""];
    for (NSInteger index = 0;index < [xiangruiArr count] ;index ++ )
    {
        ExtraModel * eveExtra = [xiangruiArr objectAtIndex:index];
        if([specialArr containsObject:eveExtra.cName])
        {
            special += 500;
        }
    }
    
    if(addNum > 6000){
        special *= 0.35;
    }else if(addNum > 5000){
        special *= 0.5;
    }
    
    
    price += special;
    
    return price;
}
-(CGFloat)price_zuoji{
    
    CGFloat price = 0;
    //    self.extraObj.AllRider
    NSArray  * xiangruiArr = self.extraObj.AllRider.riderModelsArray;
    
    for (NSInteger index = 0;index < [xiangruiArr count] ;index ++ )
    {
        ExtraModel * eveExtra = [xiangruiArr objectAtIndex:index];
        if([eveExtra.exgrow integerValue] > 23000){
            price += 100;
        }
    }
    
    if(price == 0){
        price -= 100;
    }
    
    return price;
}
//抵扣乾元丹的钱
-(CGFloat)price_fabao{
    CGFloat price = 0;
    //    self.extraObj.fabao;
    //17笛子  23附灵玉
    //物理 4级物理法宝
    NSArray  * fabaoArr = self.extraObj.fabao.fabaoModelsArray;
    
    //总法宝数量
    if([fabaoArr count] >= 15)
    {
        //必须法宝检查
        NSInteger school = [self.extraObj.iSchool integerValue];
        BOOL faxi = NO;
        BOOL wuli = NO;
        if(school == 7 || school == 10 || school == 13 || school == 5 ){
            faxi = YES;
        }
        if(school == 1 || school == 8 || school == 9 || school == 11 || school == 14){
            wuli = YES;
        }
        
        NSMutableArray * tagArr = [NSMutableArray array];
        for (NSInteger index = 0;index < [fabaoArr count] ;index ++ )
        {
            ExtraModel * eveExtra = [fabaoArr objectAtIndex:index];
            [tagArr addObject:[NSString stringWithFormat:@"%ld",[eveExtra.iType integerValue]]];
        }
        
        //6096落星飞鸿  6097流影云笛  6073附灵玉
        //6068神行飞剑  6020七杀  6088盘龙玉璧
        //必带 6063混元伞  6063七宝玲珑灯  6033乾坤玄火塔  6072降魔斗篷  6082重明战鼓
        if(faxi && (![tagArr containsObject:@"6073"] || ![tagArr containsObject:@"6097"])){
            if(![tagArr containsObject:@"6073"]){
                price -= 200;
            }
            if(![tagArr containsObject:@"6097"]){
                price -= 300;
            }
            
        }else if(wuli && (![tagArr containsObject:@"6096"])){
            price -= 200;
        }else if(![tagArr containsObject:@"6082"]){
            price -= 200;
        }
        
        //乾坤塔
        if(![tagArr containsObject:@"6033"]){
            price -= 200;
        }
        
    }else
    {
        price -= 500;
    }
    
    return price;
}
//25级各级需要修炼点 13级以上计算价格
-(CGFloat)chongxiu_price_countForEveNum:(NSInteger)number
{
    NSInteger countNum = 13;
    if(number <= countNum)
    {
        return 0;
    }
    CGFloat price = 0;
    NSString * detailStr = @"150,210,290,390,510,650,810,990,1190,1410,1650,1910,2190,2490,2810,3150,3510,3890,4290,4710,5150,5610,6090,6590,7110";
    
    NSArray * eveArr = [detailStr componentsSeparatedByString:@","];
    CGFloat baobao = 0;
    for (NSInteger index = countNum;index < number;index ++ )
    {
        NSString * eve = [eveArr objectAtIndex:index];
        baobao += [eve floatValue];
    }
    
    NSString * chongxiu_max = @"413,509,769,1276,2111";
    NSArray * maxArr = [chongxiu_max componentsSeparatedByString:@","];
    CGFloat max_price = 0;
    if(number > 20)
    {
        NSInteger addMax = number - 20;
        for (NSInteger index = 0; index < addMax; index ++ )
        {
            NSString * eve = [maxArr objectAtIndex:index];
            max_price += ([eve floatValue]);
        }
        
    }
    
    CGFloat youxibi = baobao /100.0 * 65 + max_price;
    price = youxibi/LevelPlanModelBaseYouxibiRateForMoney;
    if(number > 20){
        price *= 0.58;
    }else{
        price *= 0.65;
    }
    
    return price;
}
-(CGFloat)detailCheckEquipSummonPriceWithSubSummon:(ExtraModel *)extra
{
    //取出对应数字
    CGFloat price = 0;
    
    //    锻炼等级 3  镶嵌宝石
    NSInteger baoshi = [extra equipLatestAddLevel] ;
    NSInteger error = [extra equipErrorTimes];
    if(baoshi == 8 && error < 2)
    {
        price = 100;
    }else if(baoshi > 8 && error != 3){
        price = 100;
    }
    
    return price;
}

-(void)checkDetailZhaohuanSkill
{
    //        高反震 高招架 高雷吸  高土吸
    //    "403":1,"430":1,"432":1,"420":1,
    
    
    //      高法爆 高法波
    //    "578":1,"577":1,
    
    //     552死亡  554善恶 661须弥  579法防 571力劈 639灵灯 573高法连 595壁垒
    //     413高驱 424高魔心 414高毒 426奔雷咒 429地狱烈火  422高敏  412高鬼魂 415高冥想
    //     416高必 404高吸血 405高连 425高偷 401高夜  408高感知 411高神 434高强力
    //     435高防御 403高反震 421高永恒  409高再生 417高幸运  402高反击 407高隐
    //     308感知 301夜战 316必杀 303反震 304吸血 325偷袭   510法连 575法爆  305连击  319神迹
    //     322敏捷 309再生 328水攻 306飞行 327落岩 307隐身 311小神
    
}

-(CGFloat)xiulian_price_countForEveNum:(NSInteger)number withAdd:(BOOL)more
{
    NSInteger countNum = 15;
    if(number <= countNum || number > 25)
    {
        return 0;
    }
    NSInteger addNum = number - countNum;
    
    CGFloat price = 0;
    //562,630,702,778,858,942,1030,1122,1218,1318,1422
    //15到25级修炼所需要的消耗
    NSString * detailStr = @"562,630,702,778,858,942,1030,1122,1218,1318,1422";
    NSArray * eveArr = [detailStr componentsSeparatedByString:@","];
    
    CGFloat xiulian = 0;
    for (NSInteger index = 0;index <= addNum;index ++ )
    {
        NSString * eve = [eveArr objectAtIndex:index];
        CGFloat eveMoney = [eve floatValue];
        if(more)
        {
            eveMoney *= 1.5;
        }
        xiulian += eveMoney;
    }
    
    price = xiulian/LevelPlanModelBaseYouxibiRateForMoney;
    //    if(addNum > 3)
    {//修炼上限提升 需要5000W  3修3000块，上限为本区域扣减
        //        price *= 1.2;
    }
    price *= 1.2;
    
    return price;
}

-(NSInteger)maxAddNumberFromCurrentArray:(NSArray *)array
{
    NSInteger max = 0;
    for (NSInteger index = 0; index <[array count];index ++ ) {
        NSInteger  num = [[array objectAtIndex:index] intValue];
        if(max < num){
            max = num;
        }
    }
    return max;
}
-(BOOL)checkHistorySchoolEffectiveWithPreSchool:(NSInteger)number
{
    BOOL effective = NO;
    NSArray * school1Arr = @[@1,@2,@3,@4,@13];
    NSArray * school2Arr = @[@5,@6,@7,@8,@14];
    NSArray * school3Arr = @[@9,@10,@11,@12,@15];
    NSNumber * latestNum = self.extraObj.iSchool;
    NSNumber * preSchool = [NSNumber numberWithInteger:number];
    //种族校验
    if([school1Arr containsObject:latestNum] && [school1Arr containsObject:preSchool]){
        effective = YES;
    }
    
    if([school2Arr containsObject:latestNum] && [school2Arr containsObject:preSchool]){
        effective = YES;
    }
    
    if([school3Arr containsObject:latestNum] && [school3Arr containsObject:preSchool]){
        effective = YES;
    }
    
    
    //历史属性校验，仅校验法系魔力属性
    NSArray * faxiArr = @[@7,@13,@10];
    if(effective && [faxiArr containsObject:preSchool])
    {
        BOOL contain = NO;
        NSArray * containArr = self.extraObj.propKept.proKeptModelsArray;
        for (ExtraModel * model in containArr)
        {
            //魔力最大
            //            NSInteger liliang = [model.iStr intValue];
            //            NSInteger tili = [model.iCor intValue];
            //            NSInteger naili = [model.iRes intValue];
            //            NSInteger minjie = [model.iSpe intValue];
            NSInteger fali = [model.iMag intValue];
            
            NSArray * addNumArr = [NSArray arrayWithObjects:model.iStr,model.iMag,model.iCor,model.iRes,model.iSpe, nil];
            NSInteger maxAddNum = [self maxAddNumberFromCurrentArray:addNumArr];
            
            if(maxAddNum == fali && fali > 1000)
            {
                contain = YES;
                break;
            }
        }
        effective = contain;
    }
    
    
    return effective;
}
-(NSInteger)countSchoolPriceForSchoolNum:(NSInteger)school
{
    //    @"1",@"大唐官府",@"2",@"化生寺",@"3",@"女儿村",@"4",@"方寸山",@"5",@"天宫",@"6",@"普陀山",@"7",@"龙宫",@"8",@"五庄观",@"9",@"狮驼岭",@"10",@"魔王寨",@"11",@"阴曹地府",@"12",@"盘丝洞",@"13",@"神木林",@"14",@"凌波城",@"15",@"无底洞"
    NSInteger schoolNum = 0;
    switch (school) {
            //FC PS
        case 12:
        {
            schoolNum = 200;
        }
            break;
        case 6:
        case 15:
        {
            schoolNum = 700;
        }
            break;
        case 10:
        case 13:
        {
            schoolNum = 100;
        }
            break;
        case 7:
        {
            schoolNum = 700;
        }
            break;
        case 1:
        {
            schoolNum = -800;
        }
            break;
        case 3:
        case 5:
        case 8:
        {
            schoolNum = 200;
        }
            break;
        case 2:
        case 9:
        {
            schoolNum = -500;
        }
            break;
        default:
            break;
    }
    
    return schoolNum;
}


//25级各级需要修炼点 13级以上计算价格
-(CGFloat)jineng_price_countForEveShiMenNum:(NSInteger)number
{
    CGFloat price = 0;
    
    if(number >= 160)
    {
        //技能正向加法
        price += 400;
        //        NSLog(@"skillLevel %ld %.0f add %.0f append %.0f",number,price,addPrice,appendPrice);
    }else if(number < 150)
    {
        price -= 150;
    }
    return price;
}
-(CGFloat)jineng_price_addConstPriceForEveNum:(NSInteger)number
{
    CGFloat price = 0;
    NSInteger countNum = 155;
    if(number <= countNum)
    {
        return 0;
    }
    
    NSInteger addNum = number - countNum;
    NSString * detailStr = @"4239607,4344845,4452027,4561177,4672319,450041,4594563,4680138,4766769,4854465,4943226,5033064,5123985,5215995,5309100,7204407,7331490,7460064,7590129,7721700,9818475,9986727,10156893,10328979,12252600";
    NSArray * eveArr = [detailStr componentsSeparatedByString:@","];
    CGFloat shiMenJN = 0;
    for (NSInteger index = 0;index < addNum;index ++ )
    {
        if([eveArr count]>index)
        {
            NSString * eve = [eveArr objectAtIndex:index];
            shiMenJN += ([eve floatValue]/10000);
        }
    }
    
    CGFloat youxibi = shiMenJN ;
    price = youxibi/LevelPlanModelBaseYouxibiRateForMoney;
    price *= 0.8;
    
    return price;
}
-(CGFloat)jineng_price_appendLetfPriceForEveNum:(NSInteger)number
{
    CGFloat price = 0;
    NSInteger countNum = 155;
    if(number <= countNum)
    {
        return 0;
    }
    if(number > 180){
        number = 180;
    }
    
    
    NSInteger appendNum = 180 - number;
    NSString * detailStr = @"4239607,4344845,4452027,4561177,4672319,450041,4594563,4680138,4766769,4854465,4943226,5033064,5123985,5215995,5309100,7204407,7331490,7460064,7590129,7721700,9818475,9986727,10156893,10328979,12252600";
    NSArray * eveArr = [detailStr componentsSeparatedByString:@","];
    CGFloat shiMenJN = 0;
    for (NSInteger index = 0;index < appendNum;index ++ )
    {
        NSInteger constIndex = [eveArr count] - 1 - index;
        NSString * eve = [eveArr objectAtIndex:constIndex];
        shiMenJN += ([eve floatValue]/10000);
    }
    
    CGFloat youxibi = shiMenJN ;
    price = 1000 - youxibi/LevelPlanModelBaseYouxibiRateForMoney;//总价1000,扣除补齐花费即估值
    
    price = MAX(0, price);
    
    return price;
}

-(CGFloat)jineng_price_countForEveShenghuoKeyNum:(NSString *)key andskillNum:(NSInteger)skillNum
{
    CGFloat money = 0;
    //    230强壮 237神速
    //    11-20 2500W 21-30 5000W 31-40 8500W
    if([key isEqualToString:@"237"]||[key isEqualToString:@"230"])
    {
        // 20以上计算价格
        if(skillNum >= 40)
        {
            money = 700;
        }else if(skillNum >= 35)
        {
            money = 400;
        }else if(skillNum >= 30){
            money = 250;
        }else if(skillNum >= 20){
            money = 100;
        }
        
    }else if([key isEqualToString:@"201"] || [key isEqualToString:@"211"]){
        //强壮、养生
        if(skillNum >= 140 ){
            money = 150;
        }else if(skillNum >= 130){
            money = 100;
        }
    }else
    {
        if(skillNum >= 155)
        {
            money = 100;
        }else if(skillNum > 140)
        {
            money = 50;
        }else if(skillNum > 110){
            money = 30;
        }
    }
    
    return money;
}



-(CGFloat)price_xiulianWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_xiulian];
    return 0;
}
-(CGFloat)price_chongxiuWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_chongxiu];
    return 0;
}
-(CGFloat)price_jinengWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_jineng];
    return 0;
}
-(CGFloat)price_jingyanWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_jingyan];
    return 0;
}
-(CGFloat)price_qiannengguoWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_qiannengguo];
    return 0;
}
-(CGFloat)price_qianyuandanWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_qianyuandan];
    return 0;
}
-(CGFloat)price_dengjiWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_dengji];
    return 0;
}
-(CGFloat)price_jiyuanWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_jiyuan];
    return 0;
}
-(CGFloat)price_menpaiWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_menpai];
    return 0;
}
-(CGFloat)price_fangwuWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_fangwu];
    return 0;
}
-(CGFloat)price_xianjinWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_xianjin];
    return 0;
}
-(CGFloat)price_haiziWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_haizi];
    return 0;
}
-(CGFloat)price_xiangruiWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_xiangrui];
    return 0;
}
-(CGFloat)price_zuojiWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_zuoji];
    return 0;
}
-(CGFloat)price_fabaoWithExtraModel:(EquipExtraModel *)extraModel{
    self.extraObj = extraModel;
    return [self price_fabao];
    return 0;
}

@end
