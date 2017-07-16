//
//  CBGPlanZhuangbeiModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/30.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanZhuangbeiModel.h"
#import "ExtraModel.h"

@implementation CBGPlanZhuangbeiModel

+(CBGPlanZhuangbeiModel  *)planZhuangbeiPriceModelFromAllEquipModel:(AllEquipModel *)equipModel
{
    NSInteger total = 0;
    NSMutableArray * planArr = [NSMutableArray array];
    CBGPlanZhuangbeiModel * planModel =[[CBGPlanZhuangbeiModel alloc] init];
    NSArray * zhaugnbeiArr = equipModel.modelsArray;
    for (NSInteger index = 0 ;index < [zhaugnbeiArr count];index ++)
    {
        
        ExtraModel * extra = [zhaugnbeiArr objectAtIndex:index];
        
        CGFloat evePrice  = 0 ;
        
        NSInteger baoshi = [extra equipLatestAddLevel] ;
        NSInteger error = [extra equipErrorTimes];
        if(baoshi == 8 && error < 2)
        {
            evePrice = 100;
        }else if(baoshi > 8 && error != 3){
            evePrice = 100;
        }
        total += evePrice;
        
        NSString * zhaohuankey = [NSString stringWithFormat:@"%ld(%ld)",baoshi,error];
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
