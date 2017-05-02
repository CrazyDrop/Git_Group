//
//  AllSummonModel.m
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import "AllSummonModel.h"
#import "ExtraModel.h"

#define HEIGH_SKILLS_COMBINE_STRING @"552|554|661|579|571|595|639|424|573|578|577|415|426|427|428|429|416|404|405|425|401|434|411|435|422|408|403|421|409|417|402|407|413|414|412"
//红书技能数组
@interface AllSummonModel()
@property (nonatomic, strong) NSArray * skillNumArr;
@end


@implementation AllSummonModel

//统计的全部为宝宝、4技能以上
-(CGFloat)summonPlanPriceForTotal
{
    //价格计算
    //技能  资质+成长  进阶+特性  等级  宝宝装备  神兽+变异+宝宝
    //是否时间锁  特殊技能
    AllSummonModel * model = self;
    
    CGFloat price = 0;
    
//    CGFloat zizhiPrice = [self zizhiPrice_baobao];
    //仅当资质有价值时，技能有效(仅针对有特殊技能的)
    
    CGFloat skillPrice = [self skillPrice_baobao];
    CGFloat neidanPrice = [self neidanPrice_baobao];//内丹折扣
    if(neidanPrice > 0)
    {
        skillPrice *= neidanPrice;
    }
    
    CGFloat texingPrice = [self texingPrice_baobao];
    
    CGFloat zhuangPrice = [self zhuangPrice_baobao];
    
    
    price = skillPrice + texingPrice + zhuangPrice;
    
    if([model.iLockNew integerValue] > 0)
    {
        price *= 0.8;
    }
    NSLog(@"价格 %.0f %@  %@",price,[self.skillNumArr componentsJoinedByString:@"|"],self.grow);
    
    return price;

}
-(NSArray *)skillNumArr
{
    if(!_skillNumArr)
    {
        NSMutableArray * editArr = [NSMutableArray array];
        NSArray * skills = self.all_skills.skillsArray;
        for (NSInteger index = 0;index < [skills count] ;index ++ )
        {
            ExtraModel * eveExtra = [skills objectAtIndex:index];
            [editArr addObject:eveExtra.extraTag];
        }
        _skillNumArr = editArr;
    }
    return _skillNumArr;
}


-(CGFloat)skillPrice_baobao
{
    CGFloat price = 0;
    
    NSInteger life = [self.life integerValue];
    if(life == 65432)
    {//神兽
        price = 1500;
    }
    
    AllSummonModel * model = self;
    JinjieModel * jinjie = model.jinjie;//
//    NSArray * heighSkillArr = [NSArray arrayWithObjects:
//                               @"552",@"554",@"661",@"579",@"571",@"595",@"639",
//                               @"424",@"573",@"578",@"577",@"415",@"426",@"427",@"428",@"429",
//                               @"416",@"404",@"405",@"425",@"401",@"434",                               @"411",@"435",@"422",@"408",@"403",@"421",@"409",@"417",@"402",@"407",@"413",@"414",@"412",
//                               nil];
    NSString * combineSkill = HEIGH_SKILLS_COMBINE_STRING;

    
    NSArray * skillsNumArr = self.skillNumArr;
    NSInteger totalSkillNum = [skillsNumArr count];
    NSInteger redSkillNum = 0;
    for (NSInteger index = 0; index < [skillsNumArr count] ;index ++ )
    {
        NSString * subSkill = [skillsNumArr objectAtIndex:index];
        NSRange range = [combineSkill rangeOfString:subSkill];
        if(range.length > 0)
        {
            redSkillNum ++;
        }
    }
    NSInteger dengji = [model.iGrade integerValue];
    
    //红书技能数量
    
    //蓝书
    //混合
    //全红技能
    
    //有特殊技能
    //须弥、力劈、法防、死亡
    //(壁垒、高连 +高必杀) 或 无特殊技能
    
    //法书辅助书
    NSInteger fashuSkillNum = 0;
    NSArray * fashuSkillArr = [NSArray arrayWithObjects:@"411",@"424",@"573",@"577",@"578",nil];
    for (NSString * eve in fashuSkillArr )
    {
        if([fashuSkillArr containsObject:eve])
        {
            fashuSkillNum ++;
        }
    }
    
    NSInteger gongjiSkillNum = 0;
    NSArray * gognjiSkillArr = [NSArray arrayWithObjects:@"416",@"404",@"405",@"425",@"401",@"434",nil];
    for (NSString * eve in gognjiSkillArr )
    {
        //高级技能，一个加50
        if([skillsNumArr containsObject:eve])
        {
            gongjiSkillNum ++;
        }
    }
    
    //法宠
    //须弥  大法须弥  1000块
    if([skillsNumArr containsObject:@"661"])
    {
        if([skillsNumArr containsObject:@"426"] || [skillsNumArr containsObject:@"427"] || [skillsNumArr containsObject:@"428"] || [skillsNumArr containsObject:@"429"])
        {
            price += 300;
            
            if(redSkillNum == totalSkillNum)
            {//全红须弥
                if(fashuSkillNum >= 3)
                {
                    price += (1000 * (redSkillNum -2));
                }else if(fashuSkillNum == 2){
                    price += (800 * (redSkillNum -2));
                }else{
                    price += (600 * (redSkillNum -2));
                }
                
            }else{
                //有杂书
                if(fashuSkillNum >= 3)
                {
                    price += (1000 * (redSkillNum -2));
                    price += (600 * (totalSkillNum - redSkillNum - 2));
                }else{
                    
                    price += (600 * fashuSkillNum);
                    price += ((redSkillNum - fashuSkillNum) * 400);
                    price += ((totalSkillNum - redSkillNum)*200);
                }
            }
        }else
        {
            //胚子须弥和资质有关，需要再次处理
            //成长、体资 法资
            //视为胚子、包含大书视为400
            if(totalSkillNum >= 8)
            {
                price += (600 * (totalSkillNum -2));

            }else if(totalSkillNum == 7){
                price += (450 * (totalSkillNum -2));
            }else{
                price += (300 * (totalSkillNum -2));
            }
        }
        
        CGFloat priceRate = 1;
        if([self zizhiPrice_baobao] == 0)
        {
            //资质差
            priceRate = 0.5;
        }
        price *= priceRate;
        
    }else if([skillsNumArr containsObject:@"571"]||[skillsNumArr containsObject:@"554"])
    { //力劈、善恶半价
        price += 100;
        if(redSkillNum == totalSkillNum)
        {
            if(gongjiSkillNum >= 4)
            {
                price += (600 * redSkillNum);
            }else if(gongjiSkillNum >= 2){
                price += (400 * redSkillNum);
            }else{
                price += (200 * redSkillNum);
            }
        }else{
            //有杂书
            if(gongjiSkillNum >= 4)
            {
                price += (600 * redSkillNum);
                price += (200 * (totalSkillNum - redSkillNum));
            }else if(gongjiSkillNum >= 2){
                price += (600 * gongjiSkillNum);
                price += ((redSkillNum - gongjiSkillNum) * 400);
                price += ((totalSkillNum - redSkillNum)*100);
            }else{
                if(totalSkillNum > 5){
                    price += (totalSkillNum*30) + 0;
                }else
                {
                    price += 0;
                }
            }
        }

        if(gongjiSkillNum >= 4)
        {
            if(![skillsNumArr containsObject:@"416"])
            {
                price -= 700;
            }
            if(![skillsNumArr containsObject:@"404"])
            {
                price -= 700;
            }
        }
        
        CGFloat priceRate = 1;
        if([self zizhiPrice_baobao] == 0)
        {
            //资质差
            priceRate *= 0.5;
        }
        if([skillsNumArr containsObject:@"554"]){
            priceRate *= 0.5;
        }
        
        price *= priceRate;
    }else if([skillsNumArr containsObject:@"579"]||[skillsNumArr containsObject:@"552"])
    { //法防、死亡
        
        if([self zizhiPrice_baobao] > 0)
        {
            if([skillsNumArr containsObject:@"579"]&&[skillsNumArr containsObject:@"552"]){
                price += 300;
            }else if([skillsNumArr containsObject:@"579"] )
            {
                price += 100;
            }
        }else if([skillsNumArr containsObject:@"579"]&&[skillsNumArr containsObject:@"552"]){
            price += 50;
        }else if([skillsNumArr containsObject:@"579"]){
            price += 10;
        }
    }else if([skillsNumArr containsObject:@"405"])
    {//高连
        price += 100;

        if(redSkillNum == totalSkillNum)
        {//全红
            if(gongjiSkillNum >= 4)
            {
                price += (500 * redSkillNum);
                if([skillsNumArr containsObject:@"407"])
                {//高隐身视为不存在
                    price -= 800;
                }
            }else if(gongjiSkillNum >= 2){
                price += (200 * redSkillNum);
            }else{
                price += (150 * redSkillNum);
            }
        }else{
            //有杂书
            if(gongjiSkillNum >= 4)
            {
                price += (500 * redSkillNum);
                price += (150 * (totalSkillNum - redSkillNum));
                if([skillsNumArr containsObject:@"407"])
                {//高隐身视为不存在
                    price -= 800;
                }
            }else if(gongjiSkillNum >= 2){
                price += (500 * gongjiSkillNum);
                price += ((redSkillNum - gongjiSkillNum) * 100);
                price += ((totalSkillNum - redSkillNum) * 80);
            }else{
                if(totalSkillNum > 4)
                {
                    price += (totalSkillNum*30) + 0;
                }else
                {
                    price = 20;
                }
            }
        }
        
        if(gongjiSkillNum >= 4)
        {
            if(![skillsNumArr containsObject:@"416"])
            {
                price -= 600;
            }
            if(![skillsNumArr containsObject:@"404"])
            {
                price -= 600;
            }
        }else if(gongjiSkillNum >= 2){
            if(![skillsNumArr containsObject:@"416"])
            {
                price -= 300;
            }
            if(![skillsNumArr containsObject:@"404"])
            {
                price -= 300;
            }
        }
        
        if(gongjiSkillNum >= 2)
        {
            if([skillsNumArr containsObject:@"407"])
            {//高隐身视为不存在
                price -= 800;
            }
        }


    }else if([skillsNumArr containsObject:@"595"]){//壁垒
        price += 100;
        
        if(redSkillNum == totalSkillNum)
        {//全红
            if(gongjiSkillNum >= 6)
            {
                price += (400 * redSkillNum);
                if([skillsNumArr containsObject:@"407"])
                {//高隐身视为不存在
                    price -= 800;
                }
            }else if(gongjiSkillNum >= 2){
                price += (200 * redSkillNum);
            }else{
                price += (150 * redSkillNum);
            }
        }else{
            //有杂书
            if(gongjiSkillNum >= 6)
            {
                price += (500 * redSkillNum);
                price += (150 * (totalSkillNum - redSkillNum));
                if([skillsNumArr containsObject:@"407"])
                {//高隐身视为不存在
                    price -= 800;
                }
            }else if(gongjiSkillNum >= 2){
                price += (500 * gongjiSkillNum);
                price += ((redSkillNum - gongjiSkillNum) * 100);
                price += ((totalSkillNum - redSkillNum) * 80);
            }else{
                if(totalSkillNum > 4)
                {
                    price += (totalSkillNum*30) + 0;
                }else
                {
                    price = 20;
                }
            }
        }
        
        if(gongjiSkillNum >= 6)
        {
            if(![skillsNumArr containsObject:@"416"])
            {
                price -= 600;
            }
            if(![skillsNumArr containsObject:@"404"])
            {
                price -= 600;
            }
        }else if(gongjiSkillNum >= 2){
            if(![skillsNumArr containsObject:@"416"])
            {
                price -= 300;
            }
            if(![skillsNumArr containsObject:@"404"])
            {
                price -= 300;
            }
        }
        
        if(gongjiSkillNum >= 2)
        {
            if([skillsNumArr containsObject:@"407"])
            {//高隐身视为不存在
                price -= 800;
            }
        }
        
    }
    else if([skillsNumArr containsObject:@"426"] || [skillsNumArr containsObject:@"427"] || [skillsNumArr containsObject:@"428"] || [skillsNumArr containsObject:@"429"])
    {
        //仅大法
        //技能  30 - 150之间   大法平宠  180块
        //垃圾的30,成品100
        if(fashuSkillNum >= 3){
            price += 150;
        }else
        {
            price = fashuSkillNum * 10 + 20;
        }
        
    }else if(gongjiSkillNum >= 2)
    {//两本以上垃圾红书
        price += (200 * gongjiSkillNum);
        price += ((totalSkillNum - gongjiSkillNum) * 50);
        if(![skillsNumArr containsObject:@"416"])
        {
            price -= 200;
        }
        if(![skillsNumArr containsObject:@"404"])
        {
            price -= 200;
        }

    }else
    {
        //垃圾的30,成品50
        if(totalSkillNum > 4 && dengji > 160)
        {
            price += 50 + gongjiSkillNum * 50;
        }else {
            price = 10;
        }
    }

    return price;
}
-(CGFloat)texingPrice_baobao
{
    CGFloat price = 0;
    //灵性价格
    JinjieModel * jinjie = self.jinjie;//

    NSInteger lingxing = [jinjie.lx integerValue];
    if(lingxing == 110)
    {
        price += 500;
    }else if(lingxing > 10)
    {
        price += 30;//内丹钱
    }else{
        
    }

    //特性
    NSString * texing = jinjie.core.name;
    if(texing)
    {//截取   名字 百分数
//        #Y使用药品效果上升#G3.1%#Y；受到的所有伤害增加#R10%#Y。
//        #R10%#Y
//        NSLog(@"texing %@ %@",texing,jinjie.core.effect);
//        NSString * numberStr = nil;
//        price += 50;
        
        if([texing isEqualToString:@"力破"] || [texing isEqualToString:@"瞬法"] ||  [texing isEqualToString:@"瞬击"])
        {
            price += 100;
        }else if([texing isEqualToString:@"顺势"]|| [texing isEqualToString:@"灵刃"]){
            price += 50;
        }else if([texing isEqualToString:@"逆境"]){
            price += 200;
        }
    }

    return price;
}
-(CGFloat)zizhiPrice_baobao
{
    CGFloat price = 0;//仅范围0 1两种，区别特殊技能的资质是否有效
    // 1476|1411|1200|1131|4903|1942
    //防御 攻击 速度  躲闪  体力  法力
    
    AllSummonModel * model = self;
    if([model.csavezz rangeOfString:@"|"].length == 0)
    {
        return price;
    }
    NSArray * detailArr = [model.csavezz componentsSeparatedByString:@"|"];
    NSInteger skillNum = [model.all_skills.skillsArray count];
    CGFloat chengzhang = [model.grow floatValue];
    CGFloat dengji = [model.iGrade integerValue];
    NSInteger coreNum =  [model.summon_core.sumonModelsArray count];
    //默认
    NSInteger gongji = [[detailArr objectAtIndex:1] integerValue];
    NSInteger fashu = [[detailArr objectAtIndex:5] integerValue];
    NSInteger fangyu = [[detailArr objectAtIndex:0] integerValue];
    NSInteger tizhi = [[detailArr objectAtIndex:4] integerValue];
    
    //内丹数量
    //资质和技能数量、成长有关
    
    NSArray * skills = self.skillNumArr ;
    if(chengzhang > 1200)
    {
        //            552死亡  554善恶 661须弥  579法防 571力劈
        if([skills containsObject:@"661"]){
            //包含须弥
            if(fashu > 1800 && tizhi > 3000)
            {
                price = 1;
            }
        }else if([skills containsObject:@"571"] || [skills containsObject:@"554"]){
            //力劈、善恶
            if(fangyu > 1100 && gongji > 1250 && tizhi > 3000)
            {
                price = 1;
            }
        }else if([skills containsObject:@"552"] && [skills containsObject:@"579"]){
            //法防、死亡
            if(fangyu > 1200 && tizhi > 3500)
            {
                price = 1;
            }
        }else if([skills containsObject:@"579"] && dengji > 150)
        {
            //法防
            if(fangyu > 1300 && tizhi > 3500)
            {
                price = 1;
            }
        }
    }


    return price;
}
-(CGFloat)zhuangPrice_baobao
{
    CGFloat price = 0;
    
    AllSummonModel * model = self;
    if(model.summon_equip1 && model.summon_equip2 && model.summon_equip3)
    {
        //套装
        NSString * compareStr = [self subBaobaoZhuangSkillFromDesc:model.summon_equip1.cDesc];
        NSString * compare2 = [self subBaobaoZhuangSkillFromDesc:model.summon_equip2.cDesc];
        NSString * compare3 = [self subBaobaoZhuangSkillFromDesc:model.summon_equip3.cDesc];
        if(compareStr && [compare2 isEqualToString:compareStr] && [compare3 isEqualToString:compareStr])
        {
            if([compareStr containsString:@"高级"] && ([compareStr containsString:@"必杀"] || [compareStr containsString:@"偷袭"] || [compareStr containsString:@"法术"] || [compareStr containsString:@"魔之心"] || [compareStr containsString:@"吸血"]|| [compareStr containsString:@"隐身"]))
            {
                price += 100;
                
            }else if([compareStr containsString:@"死亡"] || [compareStr containsString:@"力劈"]||[compareStr containsString:@"善恶"] )
            {
                price += 200;
            }else if([compareStr containsString:@"高级"] && ![compareStr containsString:@"吸收"])
            {
                price += 50;
            }
            else{
                price += 10;
            }
            
            NSInteger level1 = [self subBaobaoZhuangDengJiFromDesc:model.summon_equip1.cDesc];
            NSInteger level2 = [self subBaobaoZhuangDengJiFromDesc:model.summon_equip2.cDesc];
            NSInteger level3 = [self subBaobaoZhuangDengJiFromDesc:model.summon_equip3.cDesc];
            NSInteger totalLevel = level1 + level2 + level3;
            if(totalLevel >= 25)
            {//全部7段以上
                price += 500;
            }else if(totalLevel >= 20){
                //5段
                price += 100;
            }else if(totalLevel >= 15){
                //3段
                price += 20;
            }
            
        }
    }

    return price;
}
-(CGFloat)neidanPrice_baobao
{
    //当前无计算
    CGFloat price = 0;
    //    Tag   cdes
    //内丹价格，仅看内丹数量，通过内丹看宝宝等级
    AllSummonModel * model = self;
    CGFloat skillPrice = 1;
    //未成年的不计算
    CGFloat dengji = [model.iGrade integerValue];
    if(dengji > 160)
    {
        NSInteger coreNum =  [model.summon_core.sumonModelsArray count];
        switch (coreNum) {
            case 3:
            {//4内丹  非特殊技能宠，打折
                skillPrice *= 0.85;
            }
                break;
                
            case 4:
            {//4内丹  非特殊技能宠，打折
                skillPrice *= 0.9;
            }
                break;
            case 5:
            {//5内丹  非特殊技能宠，打折
                skillPrice *= 1;
            }
                break;
            case 6:
            {
                skillPrice *= 1.1;
            }
                break;
            case 1:
            {
                skillPrice *= 0.5;
            }
                break;
            case 2:
            {
                skillPrice *= 0.7;
            }
                break;

            default:
            {
                skillPrice *= 0.85;
            }
                break;
        }
    }
    
    price += skillPrice;

    return price;
}



-(void)checkDetailZhaohuanSkill
{

    //     552死亡  554善恶 661须弥  579法防 571力劈 595壁垒 639灵灯
    //法术//     424高魔心 573高法连 578高法爆 577高法波  415高冥想 //大法 426奔雷咒 429地狱烈火
    //攻宠//     416高必 404高吸血 405高连 425高偷 401高夜  434高强力
    //辅助//     411高神 435高防御 422高敏 408高感知 403高反震 421高永恒  409高再生 417高幸运  402高反击 407高隐  413高驱 414高毒  412高鬼魂
    //     308感知 301夜战 316必杀 303反震 304吸血 325偷袭   510法连 575法爆  305连击  319神迹
    //     322敏捷 309再生 328水攻 306飞行 327落岩 307隐身 311小神
    NSArray * heighSkillArr = [NSArray arrayWithObjects:
                               @"552",@"554",@"661",@"579",@"571",@"595",@"639",
                               @"424",@"573",@"578",@"577",@"415",@"426",@"427",@"428",@"429",
                               @"416",@"404",@"405",@"425",@"401",@"434",                               @"411",@"435",@"422",@"408",@"403",@"421",@"409",@"417",@"402",@"407",@"413",@"414",@"412",
                               nil];
    NSString * combineSkill = [heighSkillArr componentsJoinedByString:@"|"];
    NSLog(@"combineSkill %@",combineSkill);

    
    
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
-(NSInteger)subBaobaoZhuangDengJiFromDesc:(NSString *)desc
{
    NSInteger level = 0;
    NSString * result = nil;
    NSString * startTxt = @"镶嵌等级：";
    NSRange startRange = [desc rangeOfString:startTxt];
    if(startRange.length > 0)
    {
        NSInteger startIndex = startRange.location + startRange.length;
        NSInteger length = 2;
        NSInteger maxLength = [desc length];
        length = MIN(length, maxLength - startIndex);
        result = [desc substringWithRange:NSMakeRange(startIndex,length)];
        level = [result integerValue];
    }
    
    return level;
}
-(NSString *)subBaobaoZhuangSkillFromDesc:(NSString *)desc
{
    NSString * result = nil;
    NSString * startTxt = @"套装效果：附加状态";
    NSString * finishTxt = @"制造者";
    NSRange startRange = [desc rangeOfString:startTxt];
    NSRange endRange = [desc rangeOfString:finishTxt];
    if(startRange.length > 0 && endRange.length > 0){
        NSInteger startIndex = startRange.location + startRange.length;
        NSInteger endIndex = endRange.location - startIndex;
        result = [desc substringWithRange:NSMakeRange(startIndex,endIndex)];
    }
    
    return  result;
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
    // summon_equip1
    if ([key isEqualToString:@"summon_equip1"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[Summon_equip1Model alloc] initWithDictionary:value];
    }

    // all_skills
    if ([key isEqualToString:@"all_skills"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[All_skillsModel alloc] initWithDictionary:value];
    }

    // summon_core
    if ([key isEqualToString:@"summon_core"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[Summon_coreModel alloc] initWithDictionary:value];
    }

    // summon_equip2
    if ([key isEqualToString:@"summon_equip2"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[Summon_equip2Model alloc] initWithDictionary:value];
    }

    // jinjie
    if ([key isEqualToString:@"jinjie"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[JinjieModel alloc] initWithDictionary:value];
    }

    // summon_equip3
    if ([key isEqualToString:@"summon_equip3"] && [value isKindOfClass:[NSDictionary class]]) {
        
        value = [[Summon_equip3Model alloc] initWithDictionary:value];
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

