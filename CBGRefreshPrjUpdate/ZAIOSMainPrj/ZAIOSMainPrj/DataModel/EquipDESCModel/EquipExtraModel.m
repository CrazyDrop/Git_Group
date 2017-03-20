//
//  EquipExtraModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "EquipExtraModel.h"
#import "ExtraModel.h"
@implementation EquipExtraModel

#define  YouxibiRateForMoney  1500.0*100

//点一个师门技能 150-180  1.74亿钱   1000块钱
-(NSString *)createExtraPrice
{
    CGFloat totalMoney = 0;
    //修炼
    CGFloat xiulian = [self price_xiulian];
    CGFloat chongxiu = [self price_chongxiu];
    CGFloat qianyuandan = [self price_qianyuandan];
    CGFloat jingyan = [self price_jingyan];
    CGFloat jineng = [self price_jineng];
    CGFloat youxibi = [self price_youxibi];
    CGFloat zhaohuanshou = [self price_zhaohuanshou];

    
    totalMoney = xiulian + chongxiu + qianyuandan + jineng + jingyan + youxibi + zhaohuanshou;
    
    NSString * detaiMoney = [NSString stringWithFormat:@"修炼:%.0f 宠修%.0f 储备:%.0f 召唤兽:%.0f \n乾元丹:%.0f 技能:%.0f 经验 %.0f \n总价:%.0f",xiulian,chongxiu,youxibi,zhaohuanshou,qianyuandan,jineng,jingyan,totalMoney];
    self.detailPrePrice = detaiMoney;
    self.zhaohuanPrice = zhaohuanshou;
    
    return [NSString stringWithFormat:@"%.0f",totalMoney];
}
-(CGFloat)price_zhaohuanshou
{
    CGFloat price = 0;
    
    NSArray * arr = self.AllSummon;
    for (AllSummonModel * eveSummon in arr)
    {
        
        NSInteger skillNum = 0;
        if([eveSummon.all_skills isKindOfClass:[All_skillsModel class]])
        {
            skillNum = [eveSummon.all_skills.skillsArray count];
        }

        //技能大于5技能以上，或者4技能宝宝，计算价格
        if(skillNum >= 5 || (skillNum == 4 && eveSummon.iBaobao) )
        {
            CGFloat evePrice = [self detailSummonPriceForEveSummon:eveSummon];
            price += evePrice;
        }
    }
    
    return price;
}
-(CGFloat)detailSummonPriceForEveSummon:(AllSummonModel *)model
{
    CGFloat price = 0;
    NSInteger skillNum = [model.all_skills.skillsArray count];
    NSInteger dengji = [model.iGrade integerValue];
    NSInteger chengzhang = [model.grow integerValue];
    JinjieModel * jinjie = model.jinjie;//
    NSInteger life = [model.life integerValue];
    if(life == 65432)
    {//神兽
        price = 1000;
        if(chengzhang == 1300)
        {
            price += 300;
        }
        if(skillNum >= 5)
        {
            price += 300;
        }
        
        return price;
    }
    
    //等级
    if(dengji >= 160)
    {//成品  200块
        price += 200;
    }
    
    //不是宝宝，且成长低
    if(![model.iBaobao boolValue] && chengzhang < 1250)
    {
        price -= 200;
    }
    
    
    if(skillNum == 4)
    {
        //变异的300，普通的200
        if([model.iBaobao integerValue] > 1)
        {
            price += 100;
        }
    }else if(skillNum == 5)
    {
        //未进阶的
        price = 400;
        if(jinjie.cnt)
        {
            price += 100;
        }
        
    }else if(skillNum >= 6)
    {
        //未进阶的
        price = 600;
        if(jinjie.cnt)
        {
            price += 200;
        }
    }
    
    return price;
}

-(CGFloat)price_youxibi
{
    CGFloat price = 0;
    
    CGFloat youxibi = [self.iCash floatValue] + [self.iLearnCash floatValue] + [self.iSaving floatValue];
    youxibi = youxibi / 10000.0;
    if(youxibi > 1000){
        price = youxibi / YouxibiRateForMoney;
    }
    
    return price;
}

-(CGFloat)price_xiulian
{
    //iExptSki 人物修炼(攻击 物抗 法术 法抗 猎术)   iMaxExpt人物修炼上线(攻击 物抗 法术 法抗)     CGFloat money = 0;
    CGFloat money = 0;
    
    NSInteger wuliNum = [self.iExptSki1 integerValue];
    if([self.iMaxExpt1 integerValue]< 25)
    {
        wuliNum -= (25 - [self.iMaxExpt1 integerValue]);
    }
    
    NSInteger wukangNum = [self.iExptSki2 integerValue];
    if([self.iMaxExpt2 integerValue]< 25)
    {
        wukangNum -= (25 - [self.iMaxExpt2 integerValue]);
    }
    
    NSInteger fashuNum = [self.iExptSki3 integerValue];
    if([self.iMaxExpt3 integerValue]< 25)
    {
        fashuNum -= (25 - [self.iMaxExpt3 integerValue]);
    }
    
    NSInteger fakangNum = [self.iExptSki4 integerValue];
    if([self.iMaxExpt4 integerValue]< 25)
    {
        fakangNum -= (25 - [self.iMaxExpt4 integerValue]);
    }
    
    
    CGFloat wuli = [self xiulian_price_countForEveNum:wuliNum withAdd:YES];
    if(wuli == 0)
    {
        wuli = [self xiulian_price_countForEveNum:[self.iMaxExpt1 integerValue] withAdd:YES];
    }
    CGFloat wukang = [self xiulian_price_countForEveNum:wukangNum withAdd:NO];
    if(wukang == 0)
    {
        wukang = [self xiulian_price_countForEveNum:[self.iMaxExpt2 integerValue] withAdd:NO];
    }
    CGFloat fashu = [self xiulian_price_countForEveNum:fashuNum withAdd:YES];
    if(fashu == 0)
    {
        fashu = [self xiulian_price_countForEveNum:[self.iMaxExpt3 integerValue] withAdd:YES];
    }
    CGFloat fakang = [self xiulian_price_countForEveNum:fakangNum withAdd:NO];
    if(fakang == 0)
    {
        fakang = [self xiulian_price_countForEveNum:[self.iMaxExpt4 integerValue] withAdd:NO];
    }
    
    money = wuli + wukang + fashu + fakang;
    
    return money;
}
-(CGFloat)xiulian_price_countForEveNum:(NSInteger)number withAdd:(BOOL)more
{
    NSInteger countNum = 15;
    if(number <= countNum)
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
    
    price = xiulian/YouxibiRateForMoney;
    
    return price;
}

-(CGFloat)price_chongxiu
{
//    13级以上计算价格
// iBeastSki宝宝修(攻击 物抗 法术 法抗)  "221":20育兽术 all_skills 内
    CGFloat money = 0;
//    宠修20-25  204个修炼果
//@"150,210,290,390,510,650,810,990,1190,1410,1650,1910,2190,2490,2810,3150,3510,3890,4290,4710,5150,5610,6090,6590,7110"
    NSArray * baobaoArr = @[
                            self.iBeastSki1,
                            self.iBeastSki2,
                            self.iBeastSki3,
                            self.iBeastSki4,
                            ];
    
    for (NSInteger index = 0; index < [baobaoArr count]; index++)
    {
        NSInteger number = [[baobaoArr objectAtIndex:index] integerValue];
        CGFloat eveMoney = [self chongxiu_price_countForEveNum:number];
        money += eveMoney;
    }
    
    return money;
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
    youxibi *= 0.7;
    price = youxibi/YouxibiRateForMoney;
    
    return price;
}

-(CGFloat)price_qianyuandan
{
//    TA_iAllNewPoint新版乾元丹 5个以上算钱
    NSInteger number = [self.TA_iAllNewPoint integerValue];
    
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
    
    CGFloat youxibi = qianyuandan;
    price = youxibi/YouxibiRateForMoney;
    
    return price;
}
-(CGFloat)price_jingyan
{
    CGFloat price = 0;
//    sum_exp总经验
    if([self.sum_exp integerValue] < 200)
    {
        price = - 500.0;
    }
    NSInteger qiannengguo = [self.iNutsNum integerValue];
    if(qiannengguo < 120)
    {
        price -= 500;
    }else if(qiannengguo > 170){
        price += 500;
    }else if(qiannengguo > 150){
        price += 300;
    }
    
    return price;
}
-(CGFloat)price_jineng
{
    //217熔炼  231淬灵   209追捕技巧  216巧匠之术   204打造技巧  205裁缝技巧  207炼金之术  212健身  206中药医理
    //211养生之道  210逃离技巧  230强壮 237神速 203暗器技巧  202冥想 208烹饪技巧  218灵石技巧 201强身
    //154变化之术  153丹元济会   160仙灵店铺  158奇门遁甲 161宝石工艺  （155 220 164)火眼金睛  154打坐 170妙手空空
    
    CGFloat money = 0;
    NSMutableArray * shimenArr = [NSMutableArray array];
    NSMutableArray * othersArr = [NSMutableArray array];
    
    for (NSInteger index = 0 ;index < [self.all_skills.skillsArray count] ;index ++ )
    {
        ExtraModel * model = [self.all_skills.skillsArray objectAtIndex:index];
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
    for (ExtraModel * model in shimenArr)
    {
        CGFloat eveMoney = [self jineng_price_countForEveShiMenNum:[model.extraValue integerValue]];
        money += eveMoney;
    }
    for (ExtraModel * model in othersArr)
    {
        CGFloat eveMoney = [self jineng_price_countForEveShenghuoKeyNum:model.extraTag andskillNum:[model.extraValue integerValue]];
        money += eveMoney;
    }
    
    return money;
}
//25级各级需要修炼点 13级以上计算价格
-(CGFloat)jineng_price_countForEveShiMenNum:(NSInteger)number
{
    if(number > 155)
    {
        NSInteger countNum = 155;
        if(number <= countNum)
        {
            return 0;
        }
        
        NSInteger addNum = number - countNum;
        CGFloat price = 0;
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
        
        CGFloat youxibi = shiMenJN * 0.9;
        price = youxibi/YouxibiRateForMoney;
        
        return price;

    }else
    {
        CGFloat price = 0;
        if(number < 148)
        {
            price = - 300.0;
        }
        return price;
    }
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
            skillNum = 700;
        }else if(skillNum >= 35)
        {
            skillNum = 600;
        }else if(skillNum >= 30){
            skillNum = 400;
        }else if(skillNum >= 20){
            skillNum = 100;
        }
        
    }else
    {
        if(skillNum > 130)
        {
            money = 200;
        }else if(skillNum > 110)
        {
            money = 150;
        }
    }
    
    return money;
}



-(NSString *)extraDes
{
    NSMutableString * extra = [NSMutableString string];
    
    if(self.buyPrice)
    {
        [extra appendFormat:@"%@",self.buyPrice];
    }
    
    [extra appendFormat:@"门派%lu",(unsigned long)[self.changesch count]];
    [extra appendFormat:@"召唤%lu",(unsigned long)[self.AllSummon count]];
    [extra appendFormat:@"装备%lu",(unsigned long)[self.AllEquip.modelsArray count]];
    [extra appendFormat:@"技能%lu",(unsigned long)[self.all_skills.skillsArray count]];
    [extra appendFormat:@"法宝%lu",(unsigned long)[self.fabao.fabaoModelsArray count]];


    return extra;
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
    // fabao
    if ([key isEqualToString:@"fabao"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[FabaoModel alloc] initWithDictionary:value];
    }

    // AllEquip
    if ([key isEqualToString:@"AllEquip"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[AllEquipModel alloc] initWithDictionary:value];
    }

    // ExAvt
    if ([key isEqualToString:@"ExAvt"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[ExAvtModel alloc] initWithDictionary:value];
    }

    // HugeHorse
    if ([key isEqualToString:@"HugeHorse"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[HugeHorseModel alloc] initWithDictionary:value];
    }

    // more_attr
    if ([key isEqualToString:@"more_attr"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[More_attrModel alloc] initWithDictionary:value];
    }

    // AllRider
    if ([key isEqualToString:@"AllRider"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[AllRiderModel alloc] initWithDictionary:value];
    }

    // all_skills
    if ([key isEqualToString:@"all_skills"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[All_skillsModel alloc] initWithDictionary:value];
    }

    // child
    if ([key isEqualToString:@"child"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[ChildModel alloc] initWithDictionary:value];
    }

    // child2
    if ([key isEqualToString:@"child2"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[ChildModel alloc] initWithDictionary:value];
    }
    
    // propKept
    if ([key isEqualToString:@"propKept"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[PropKeptModel alloc] initWithDictionary:value];
    }

    // changesch
    if ([key isEqualToString:@"changesch"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            ChangeschModel *model = [[ChangeschModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    // pet
    if ([key isEqualToString:@"pet"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            PetModel *model = [[PetModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    // AllSummon
    if ([key isEqualToString:@"AllSummon"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            AllSummonModel *model = [[AllSummonModel alloc] initWithDictionary:dictionary];
            [dataArray addObject:model];
        }
        
        value = dataArray;
    }

    // idbid_desc
    if ([key isEqualToString:@"idbid_desc"] && [value isKindOfClass:[NSArray class]]) {
        
        NSArray        *array     = value;
        NSMutableArray *dataArray = [NSMutableArray array];
        
        for (NSDictionary *dictionary in array) {
            
            Idbid_descModel *model = [[Idbid_descModel alloc] initWithDictionary:dictionary];
            
            [dataArray addObject:model];
        }
        
        value = dataArray;
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

