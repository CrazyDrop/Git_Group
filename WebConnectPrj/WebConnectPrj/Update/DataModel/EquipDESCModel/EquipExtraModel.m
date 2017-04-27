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
#import "JSONKit.h"
@implementation EquipExtraModel

#define  YouxibiRateForMoney  1300.0*100

-(void)detailSubCheck
{
    //修炼  抗1000  修1500
    NSInteger number = 25;
    NSInteger xiulian = [self xiulian_price_countForEveNum:number withAdd:YES];
    NSInteger kangxing = [self xiulian_price_countForEveNum:number withAdd:NO];
    NSLog(@"修炼单项:");
    NSLog(@"攻击%ld 价格:%ld 抗性%ld %ld  3修%ld %ld ",(long)number,xiulian,number,kangxing,(long)number,xiulian+kangxing*2);
//    25的  1000  1500
    
    number = 20;
    xiulian = [self xiulian_price_countForEveNum:number withAdd:YES];
    kangxing = [self xiulian_price_countForEveNum:number withAdd:NO];
    NSLog(@"攻击%ld 价格:%ld 抗性%ld %ld  3修%ld %ld ",(long)number,xiulian,number,kangxing,(long)number,xiulian+kangxing*2);
//    20的  400  600
    
    //宠修估价
    number = 20;
    xiulian = [self chongxiu_price_countForEveNum:number];
    NSLog(@"宠修单项:");
    NSLog(@"宠修%ld 价格:%ld ",(long)number,xiulian);
//    25的  1800
    
    number = 25;
    xiulian = [self chongxiu_price_countForEveNum:number];
    NSLog(@"宠修%ld 价格:%ld ",(long)number,xiulian);
//    20的  800
    
    number = 180;
    xiulian = [self jineng_price_countForEveShiMenNum:number];
    NSLog(@"师门技能%ld 价格:%ld ",(long)number,xiulian);
    
}

//增加潜能果、历史门派价格矫正
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
    CGFloat zhuangbei = [self price_zhuangbei];

    //法系赚钱账号，不计算经验扣减
    if(jingyan < 0 && xiulian > 1500 && ([self.iSchool integerValue] == 7)){
        jingyan = 0;//仅高修炼LG，不计算经验
    }
    
    self.xiulianPrice = xiulian;
    self.chongxiuPrice = chongxiu;
    self.qianyuandanPrice = qianyuandan;
    self.jingyanPrice = jingyan;
    self.jinengPrice = jineng;
    self.youxibiPrice = youxibi;
    self.zhaohuanPrice = zhaohuanshou;
    self.zhuangbeiPrice = zhuangbei;
    
    totalMoney = (int)xiulian + (int)chongxiu + (int)qianyuandan + (int)jineng + (int)jingyan + (int)youxibi + (int)zhaohuanshou + (int)zhuangbei;
    if(totalMoney == 0)
    {
        totalMoney = -1;
    }
    
    
    NSString * detaiMoney = [NSString stringWithFormat:@"修炼:%.0f 宠修%.0f 储备:%.0f 召唤兽:%.0f \n乾元丹:%.0f 技能:%.0f 经验 %.0f 装备:%.0f \n总价:%.0f",xiulian,chongxiu,youxibi,zhaohuanshou,qianyuandan,jineng,jingyan,zhuangbei,totalMoney];
    self.detailPrePrice = detaiMoney;
    self.zhaohuanPrice = zhaohuanshou;
    self.totalPrice = totalMoney;
    
    return [NSString stringWithFormat:@"%.0f",totalMoney];
}
-(CGFloat)price_zhuangbei
{
    CGFloat price = 0;
    //装备价格，当前仅进行判定  8段以上估价  统一10块
    NSArray * detailEquipArr = [self.AllEquip modelsArray];
    for (ExtraModel * eve in detailEquipArr)
    {
        CGFloat evemoney = [self detailCheckEquipSummonPriceWithSubSummon:eve];
        price += evemoney;
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
        if(skillNum >=4)
        {
            if([eveSummon.iBaobao boolValue]){
                CGFloat evePrice = [self detailSummonPriceForEveSummon:eveSummon];
                price += evePrice;
//                NSLog(@"%ld %.0f ",skillNum,evePrice);
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
    
    NSMutableArray * skillsNumArr = [NSMutableArray array];
    for (NSInteger index = 0;index < [model.all_skills.skillsArray count] ;index ++ )
    {
        ExtraModel * eveExtra = [model.all_skills.skillsArray objectAtIndex:index];
        [skillsNumArr addObject:eveExtra.extraTag];
    }

    
    NSInteger gongji = [model.iAtt_all intValue];
    NSInteger fangyu = [model.iDef_All intValue];
    NSInteger sudu = [model.iDex_All intValue];
    NSInteger lingli = [model.iMagDef_all intValue];
    
    NSInteger liliang = [model.iStr_all intValue];
    NSInteger fali = [model.iMag_all intValue];
    NSInteger tili = [model.iCor_all intValue];
    NSInteger naili = [model.iRes_all intValue];
    NSInteger minjie = [model.iSpe_all intValue];
    NSArray * addNumArr = [NSArray arrayWithObjects:model.iStr_all,model.iMag_all,model.iCor_all,model.iRes_all,model.iSpe_all, nil];
    NSInteger maxAddNum = [self maxAddNumberFromCurrentArray:addNumArr];
    
    //判定是否为
    
    
    //攻击红书
    NSArray * moreAddNum  = [NSArray arrayWithObjects:@"416",@"404",@"425",@"411",@"434",@"401",@"408",nil];
    //高比  高吸  高偷 高神 高强 高夜 高感知   前面3个  一个 150 后面一个80  有力劈 * 1.3  高连+300
    NSInteger gongjiMoreNum = 0;
    for(NSString * eve in moreAddNum)
    {
        if([skillsNumArr containsObject:eve])
        {
            gongjiMoreNum += 1;
        }
    }
    
    //法宠辅助
    moreAddNum  = [NSArray arrayWithObjects:@"424",@"573",@"577",@"578",@"411",@"422",@"408",nil];
    //    高魔心 高法连 高法波 高法爆  高神  高敏  前面4个  一个100 后面一个  50  没须弥  50  20
    NSInteger fashuMore = 0;
    for(NSString * eve in moreAddNum)
    {
        if([skillsNumArr containsObject:eve])
        {
            fashuMore += 1;
        }
    }
    
    //血宠辅助
    
//    @"579",@"552" 法防  死亡
    moreAddNum  = [NSArray arrayWithObjects:@"414",@"422",@"417",@"403",nil];
    //     高毒  高敏捷  高幸运 高反震  前面两个 一个100 两个300  后面一个100 或 50
    NSInteger xuedunMore = 0;
    for(NSString * eve in moreAddNum)
    {
        if([skillsNumArr containsObject:eve])
        {
            xuedunMore += 1;
        }
    }
    NSInteger skillPrice = 0;
    
    
    BOOL containSpecial = NO;
    //善恶、力劈
    if([skillsNumArr containsObject:@"571"] || [skillsNumArr containsObject:@"554"])
    {
    
        containSpecial = YES;
        if(gongjiMoreNum >= 3)
        {
            skillPrice += (gongjiMoreNum * 150);
        }else if(gongjiMoreNum > 1){
            skillPrice += (gongjiMoreNum * 80);
        }

        NSArray * heighSkillArr = [NSArray arrayWithObjects:@"416",@"404",@"425",nil];
        for (NSString * eve in heighSkillArr )
        {
            //高级技能，一个加50
            if([skillsNumArr containsObject:eve])
            {
                skillPrice += 50;
            }
        }
        
        
        //蓝书 力劈
        if(gongjiMoreNum == 0)
        {
            if(skillNum > 4)
            {
                skillPrice += 200;
            }else{
                skillPrice += 100;
            }
        }else {
            
        }
        
//        if(skillNum > 6 && gongjiMoreNum > 3){
//            skillPrice += 500;
//        }
        
        if([skillsNumArr containsObject:@"571"] && skillPrice > 300){
            skillPrice *= 1.3;
        }
        
    }else if([skillsNumArr containsObject:@"405"] || [skillsNumArr containsObject:@"595"])
    {//高连、壁垒
        
        if(gongjiMoreNum >= 4)
        {
            skillPrice += (gongjiMoreNum * 200);
        }else if(gongjiMoreNum > 1){
            skillPrice += (gongjiMoreNum * 80);
        }
        
        NSArray * heighSkillArr = [NSArray arrayWithObjects:@"416",@"404",@"425",@"411",nil];
        for (NSString * eve in heighSkillArr )
        {
            //高级技能，一个加50
            if([skillsNumArr containsObject:eve])
            {
                skillPrice += 50;
            }
        }
        
        
        //蓝书 力劈
        if(gongjiMoreNum == 0)
        {
            if(skillNum > 4)
            {
                skillPrice += 200;
            }else{
                if([skillsNumArr containsObject:@"405"])
                {
                    skillPrice += 100;
                }else{
                    skillPrice += 10;
                }
            }
        }else {
            //高连、壁垒，没高比
            if(![skillsNumArr containsObject:@"416"])
            {
                //壁垒，没高比  -200；
                skillPrice -= 300;
                if(skillPrice < 0)
                {
                    skillPrice = 10;
                }
            }
            
        }
        
//        if(skillNum >= 6 && gongjiMoreNum > 3)
//        {
//            skillPrice += 500;
//        }
        
        if([skillsNumArr containsObject:@"595"] && skillPrice > 300){
            skillPrice *= 1.1;
        }
    }else if([skillsNumArr containsObject:@"661"] || [skillsNumArr containsObject:@"426"] || [skillsNumArr containsObject:@"427"] || [skillsNumArr containsObject:@"428"] || [skillsNumArr containsObject:@"429"])
    {//须弥  大法
        
        //有须弥
        if([skillsNumArr containsObject:@"661"])
        {
            containSpecial = YES;
            if(fashuMore >= 4)
            {
                skillPrice += (fashuMore * 300);
            }else if(gongjiMoreNum > 1){
                skillPrice += (fashuMore * 150);
            }
            
            //大法书
            BOOL containMax = NO;
            NSArray * bigSkillArr = [NSArray arrayWithObjects:@"426",@"427",@"428",@"429",nil];
            for (NSString * eve in bigSkillArr )
            {
                //高级技能，一个加50
                if([skillsNumArr containsObject:eve])
                {
                    containMax = YES;
                    break;
                }
            }
            
            //大红法书
            NSArray * heighSkillArr = [NSArray arrayWithObjects:@"424",@"573",@"577",@"578",nil];
            for (NSString * eve in heighSkillArr )
            {
                //高级技能，一个加50
                if([skillsNumArr containsObject:eve])
                {
                    skillPrice += 50;
                }
            }
            
            //蓝书 力劈
            if(fashuMore == 0)
            {
                //大法
                if(containMax)
                {
                    if(skillNum > 4)
                    {
                        skillPrice += 400;
                    }else{
                        skillPrice += 100;
                    }

                }else
                {
                    if(skillNum > 4)
                    {
                        skillPrice += 200;
                    }else{
                        skillPrice += 50;
                    }
                }
            }else {
                
            }
            
        }else
        {
            
            //大红法书
            NSArray * heighSkillArr = [NSArray arrayWithObjects:@"424",@"573",@"577",@"578",nil];
            for (NSString * eve in heighSkillArr )
            {
                //高级技能，一个加50
                if([skillsNumArr containsObject:eve])
                {
                    skillPrice += 30;
                }
            }
            
            if(fashuMore <= 2)
            {
                skillPrice = 20 * fashuMore;
            }
            
        }

    }else if([skillsNumArr containsObject:@"579"] || [skillsNumArr containsObject:@"552"]){
        //法防  死亡
        containSpecial = YES;
        //同时有，
        if([skillsNumArr containsObject:@"579"] && [skillsNumArr containsObject:@"552"])
        {
            skillPrice += 100;
            if(xuedunMore >= 2){
                skillPrice += (xuedunMore * 50);
            }else{
                skillPrice += ((skillNum -2) * 10);
            }
            
        }else if([skillsNumArr containsObject:@"579"])
        {
            //只有法防
            skillPrice += 30;
            if(xuedunMore >= 2){
                skillPrice += (xuedunMore * 30);
            }else if([skillsNumArr containsObject:@"411"])
            {
                //高神法防  50块  4技能
                skillPrice = 50 + xuedunMore * 20;
            }else
            {
                //垃圾法防
                skillPrice = 10;
            }
            
        }else{
            //只有死亡
            //死亡攻宠
            if(maxAddNum == liliang || gongji > 1500)
            {
                skillPrice =  gongjiMoreNum * 50 + 100;

            }else{
                skillPrice = 20;
            }
            
        }
        
        
    }else if(gongjiMoreNum + fashuMore + xuedunMore > 0)
    {
        //有红书
        if(gongjiMoreNum > 1)
        {
            if(gongjiMoreNum >= 4)
            {
                skillPrice = gongjiMoreNum * 50;
                NSArray * heighSkillArr = [NSArray arrayWithObjects:@"416",@"404",@"425",nil];
                for (NSString * eve in heighSkillArr )
                {
                    if([skillsNumArr containsObject:eve])
                    {
                        skillPrice += 50;
                    }
                }
                
                if(![skillsNumArr containsObject:@"416"])
                {
                    skillPrice -= 200;
                }
            }else if(gongjiMoreNum >= 2)
            {
                skillPrice = gongjiMoreNum * 30;
            }
            else
            {
                //未打书 胚子，或者蓝书
                skillPrice = 20;
            }
            
        }else if(fashuMore > 0)
        {
            if(fashuMore >= 2)
            {
                BOOL bigSkill = NO;
                //大法书
                NSArray * bigSkillArr = [NSArray arrayWithObjects:@"426",@"427",@"428",@"429",nil];
                for (NSString * eve in bigSkillArr )
                {
                    //高级技能，一个加50
                    if([skillsNumArr containsObject:eve])
                    {
                        bigSkill = YES;
                    }
                }
                if(bigSkill && fashuMore >= 2){
                    skillPrice = 50;
                }
                
            }else
            {
                if(xuedunMore > 2)
                {
                    skillPrice = 50;
                }else
                {
                    //未打书 胚子
                    skillPrice = 10;
                }
            }


        }else{
            skillPrice = 20;

        }
        
    }else{
        //无特殊技能
        if(dengji > 160)
        {
            skillPrice = 20;
        }else{
            skillPrice = 10;
        }
        
    }
    
    //    Tag   cdes
    //内丹价格，仅看内丹数量
    NSInteger coreNum =  [model.summon_core.sumonModelsArray count];
    switch (coreNum) {
        case 4:
        {//4内丹  非特殊技能宠，打折
            skillPrice *= 0.8;
        }
            break;
        case 5:
        {//5内丹  非特殊技能宠，打折
            skillPrice *= 0.9;
        }
            break;
        case 6:
        {
            skillPrice *= 1.1;
        }
            break;
        default:
        {
            skillPrice *= 0.6;
        }
            break;
    }
    price += skillPrice;
    
    
    //灵性价格
    NSInteger lingxing = [jinjie.lx integerValue];
    NSInteger lingxingPrice = 0;
    if(lingxing == 110)
    {
        lingxingPrice += 500;
    }else if(lingxing > 10)
    {
        if(skillPrice < 50)
        {
            lingxingPrice += 20;
        }else{
            lingxingPrice += 50;
        }
    }else{
        
    }
    
    if(jinjie.core.name)
    {
        lingxing += 100;
    }

    
    
    price += lingxingPrice;
    
    NSInteger zhuangPrice = 0;
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
                zhuangPrice += 200;
                
            }else if([compareStr containsString:@"死亡"] || [compareStr containsString:@"力劈"]||[compareStr containsString:@"善恶"] )
            {
                zhuangPrice += 200;
                if(price > 1000)
                {
                    zhuangPrice += 100;
                }
            }else if([compareStr containsString:@"高级"] && ![compareStr containsString:@"吸收"])
            {
                zhuangPrice += 50;
            }
            else{
                zhuangPrice += 20;
            }
            
            NSInteger level1 = [self subBaobaoZhuangDengJiFromDesc:model.summon_equip1.cDesc];
            NSInteger level2 = [self subBaobaoZhuangDengJiFromDesc:model.summon_equip2.cDesc];
            NSInteger level3 = [self subBaobaoZhuangDengJiFromDesc:model.summon_equip3.cDesc];
            NSInteger totalLevel = level1 + level2 + level3;
            if(totalLevel >= 21)
            {//全部7段以上
                zhuangPrice += 500;
            }else if(totalLevel >= 15){
                //5段
                zhuangPrice += 100;
            }else if(totalLevel >= 10){
                //3段
                zhuangPrice += 20;
            }
            
        }
    }
    price += zhuangPrice;
    

    // 1476|1411|1200|1131|4903|1942
    //防御 攻击 速度  躲闪  体力  法力
    NSArray * detailArr = [model.csavezz componentsSeparatedByString:@"|"];
    NSInteger zizhiPrice = 0;
    //仅针对高书较多的宝宝
    if((gongjiMoreNum > 3 && [skillsNumArr containsObject:@"416"]) || containSpecial )
    {
        if(gongjiMoreNum > 3)
        {
            NSInteger gongji = [[detailArr objectAtIndex:1] integerValue];
            if(gongji > 1600)
            {
                zizhiPrice += 400;
            }else if(gongji > 1550){
                zizhiPrice += 200;
            }else if(gongji > 1480){
                zizhiPrice += 100;
            }
            
            if(containSpecial){
                zizhiPrice *= 1.2;
            }
        }
        
        if(fashuMore > 3)
        {
            NSInteger fashu = [[detailArr objectAtIndex:5] integerValue];
            if(fashu > 3000)
            {
                zizhiPrice += 200;
            }else if(fashu > 2500){
                zizhiPrice += 100;
            }else if(fashu > 2000)
            {
                zizhiPrice += 500;
            }
            if(containSpecial){
                zizhiPrice *= 2;
            }
        }
    }
    
    price += zizhiPrice;
    
//    //是否有锁判定
//    if([model.iLock integerValue] > 0)
//    {
//        if(price > 1000){
////            price += 300;//有锁的高级宝宝加钱
//        }else if(price > 300){
//            price *= 0.7;
//        }else if(price > 100){
//            //有锁的垃圾宝宝扣钱
//            price *= 0.5;
//        }else{
//            //有锁的垃圾宝宝扣钱
//            price = 0;
//        }
//    }
    
    
    return price;
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


-(CGFloat)price_youxibi
{
    CGFloat price = 0;
    
    CGFloat youxibi = [self.iCash floatValue] + [self.iLearnCash floatValue] + [self.iSaving floatValue];
    youxibi = youxibi / 10000.0;
    if(youxibi > 1000){
        price = youxibi / YouxibiRateForMoney ;
    }
    price *= 0.8;
    
    
    //房子，无房子扣钱
    CGFloat fangziPrice = 0;
    if(!self.rent||[self.rent integerValue] == 0)
    {
        fangziPrice -= 300;
    }else if([self.rent integerValue] < 3){
        fangziPrice -= 100;
    }
    
    
    price += fangziPrice;
    
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
    
    //存在可能，20/22  价格没有  18/22高
    CGFloat wuli = [self xiulian_price_countForEveNum:wuliNum withAdd:YES];
    if(wuli == 0)
    {
        //仅上线没实质的，
        wuli = [self xiulian_price_countForEveNum:[self.iMaxExpt1 integerValue] -5 withAdd:YES];
    }
    CGFloat wukang = [self xiulian_price_countForEveNum:wukangNum withAdd:NO];
    if(wukang == 0)
    {
        wukang = [self xiulian_price_countForEveNum:[self.iMaxExpt2 integerValue]-5 withAdd:NO];
    }
    CGFloat fashu = [self xiulian_price_countForEveNum:fashuNum withAdd:YES];
    if(fashu == 0)
    {
        fashu = [self xiulian_price_countForEveNum:[self.iMaxExpt3 integerValue]-5 withAdd:YES];
    }
    CGFloat fakang = [self xiulian_price_countForEveNum:fakangNum withAdd:NO];
    if(fakang == 0)
    {
        fakang = [self xiulian_price_countForEveNum:[self.iMaxExpt4 integerValue]-5 withAdd:NO];
    }
    
    money = wuli + wukang + fashu + fakang;
    
    return money;
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
    
    price = xiulian/YouxibiRateForMoney;
//    if(addNum > 3)
    {//修炼上限提升 需要5000W  3修3000块，上限为本区域扣减
//        price *= 1.2;
    }
    price *= 1.2;
    
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
    
    
    NSInteger yushouNum = 0;
    for (ExtraModel * model in self.all_skills.skillsArray)
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
    
    //宠修高  经验过低时，宠修估价0.7即宠修
    if(money > 4000 && [self.sum_exp integerValue] < 300)
    {
        money *= 0.8;
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
    price = youxibi/YouxibiRateForMoney;
    if(number > 20){
        price *= 0.58;
    }else{
        price *= 0.65;
    }
    
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
    
    CGFloat youxibi = qianyuandan ;
    price = youxibi/YouxibiRateForMoney;
    price *= 0.65;
    
    return price;
}
-(CGFloat)price_jingyan
{
    CGFloat price = 100;
//    sum_exp总经验
    NSInteger sup_total = [self.sum_exp integerValue];
    if(sup_total < 100)
    {
        price -= 1000.0;
    }else if(sup_total < 160){
        price -= 500;
    }else if(sup_total < 200){
        price += 100;
    }else if(sup_total < 300){
        price += 200;
    }else if(sup_total < 400){
        NSInteger countNum = MIN(330, sup_total);
        NSInteger sub = (countNum - 330) * 5 + 200;
        sub = MIN(600, sub);
        price += sub;

    }else if(sup_total < 500)
    {
        price += 1000;
    }else{
        price += 2000;
    }
    
    
    if(sup_total > 160)
    {
        NSInteger qiannengguo = [self.iNutsNum integerValue];
        if(qiannengguo < 80){
            price -= 1000;
        }
        else if(qiannengguo < 120)
        {
            price -= 500;
        }else if(qiannengguo < 160){
            price -= 200;
        }else if(qiannengguo < 190){
            price -= 100;
        }else{
            price += 200;
        }
    }
    
    
    //所有后续门派 等级满级 + 200
    //门派加钱,DT  HS ST减500
// 龙宫  MW  神木  可以抓持国  法系持国 + 500  (LG + 700 )
//      FC PS 挂机 200
//    PT  五开  500

    //等级加钱
    NSInteger levelNum = 0;
    if([self.iGrade intValue] == 175)
    {
        levelNum = 300;
    }
    price += levelNum;
    
    
    NSInteger school = [self.iSchool intValue];
    NSInteger schoolNum = [self countSchoolPriceForSchoolNum:school];
    //判定历史门派
    NSArray * history = self.changesch;
    
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
    if( [history count] > 0 && maxHistory > schoolNum){
        schoolNum = MAX(maxHistory - 300, schoolNum);
    }
    
    if(schoolNum < 0 && [self.iNutsNum intValue] > 170)
    {
        schoolNum = 0;
    }
    
    
    price += schoolNum;

    return price;
}
-(BOOL)checkHistorySchoolEffectiveWithPreSchool:(NSInteger)number
{
    BOOL effective = NO;
    NSArray * school1Arr = @[@1,@2,@3,@4,@13];
    NSArray * school2Arr = @[@5,@6,@7,@8,@14];
    NSArray * school3Arr = @[@9,@10,@11,@12,@15];
    NSNumber * latestNum = self.iSchool;
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
        NSArray * containArr = self.propKept.proKeptModelsArray;
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
            schoolNum = 400;
        }
            break;
        case 10:
        case 13:
        {
            schoolNum = 0;
        }
            break;
        case 7:
        {
            schoolNum = 700;
        }
            break;
        case 1:
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
    
    NSArray * removeArr = [self.AllEquip equipAddedSkillsNumberArrayFromEquipModel];
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
    
    if(mainSkill > 4000 && [self.sum_exp integerValue] < 300)
    {
        mainSkill *= 0.8;
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
        
        CGFloat youxibi = shiMenJN ;
        price = youxibi/YouxibiRateForMoney;
        price *= 0.8;
        
        return price;

    }else
    {
        CGFloat price = 0;
        if(number < 150)
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
            skillNum = 1000;
        }else if(skillNum >= 35)
        {
            skillNum = 700;
        }else if(skillNum >= 30){
            skillNum = 400;
        }else if(skillNum >= 20){
            skillNum = 100;
        }
        
    }else
    {
        if(skillNum >= 155)
        {
            money = 100;
        }else if(skillNum > 140)
        {
            money = 40;
        }else if(skillNum > 110){
            money = 10;
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

