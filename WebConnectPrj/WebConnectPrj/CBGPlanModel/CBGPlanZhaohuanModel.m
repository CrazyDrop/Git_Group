//
//  CBGPlanZhaohuanModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/30.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanZhaohuanModel.h"

@implementation CBGPlanZhaohuanModel

+(CBGPlanZhaohuanModel  *)planZhaohuanPriceModelFromEquipModelSummonArr:(NSArray<AllSummonModel *> *)zhaohuanArr
{
    NSInteger total = 0;
    NSMutableArray * planArr = [NSMutableArray array];
    CBGPlanZhaohuanModel * planModel =[[CBGPlanZhaohuanModel alloc] init];
    for (NSInteger index = 0 ;index < [zhaohuanArr count];index ++)
    {
        CGFloat evePrice  = 0 ;
        AllSummonModel * eveSummon  = [zhaohuanArr objectAtIndex:index];
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
                evePrice = [eveSummon summonPlanPriceForTotal];
                total += evePrice;
            }else{
                
                if(skillNum > 5 && [eveSummon.iGrade integerValue] > 160)
                {
                    evePrice = 20;
                    total += evePrice;
                }
                
            }
        }
        NSString * zhaohuankey = [NSString stringWithFormat:@"%@-%ld",eveSummon.grow,skillNum];
        [planArr addObject:@{zhaohuankey:[NSNumber numberWithInt:evePrice]}];
    }
    planModel.priceArr = planArr;
    planModel.total_price = total;
    
    return planModel;
}

-(NSString *)description
{
    NSMutableString * edit = [NSMutableString string];
    [edit appendFormat:@"总价 %.0ld ",(long)self.total_price];
    [edit appendString:@"("];
    for (NSInteger index = 0;index < [self.priceArr count] ;index ++ )
    {
        NSDictionary * eveDic = [self.priceArr objectAtIndex:index];
        [edit appendFormat:@"%@:%@|",[[eveDic allKeys] firstObject],[[eveDic allValues] firstObject]];
    }
    [edit appendString:@")"];
    return edit;
}


@end
