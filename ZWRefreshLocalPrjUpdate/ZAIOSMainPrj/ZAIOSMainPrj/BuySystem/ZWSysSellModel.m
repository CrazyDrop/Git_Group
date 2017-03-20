//
//  ZWSysSellModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/11.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWSysSellModel.h"

@implementation ZWSysSellModel
-(instancetype)initWithSellBackDic:(NSDictionary *)dic{
    self = [super init];
    if(self)
    {
        self.sell_date = [NSDate unixDate];
        self.name = [dic valueForKey:@"name"];
        self.annual_rate_str = [dic valueForKey:@"annual_rate_str"];
        self.duration_str = [dic valueForKey:@"duration_str"];
        self.due_date_str = [dic valueForKey:@"due_date_str"];
        self.product_id = [NSString stringWithFormat:@"%ld",[[dic valueForKey:@"product_id"] integerValue]];
        self.updated_at = [dic valueForKey:@"updated_at"];
        self.start_date = [dic valueForKey:@"start_date"];
        self.sold_amount = [dic valueForKey:@"sold_amount"];
        self.total_amount = [dic valueForKey:@"total_amount"];
        
        self.month_order_count = [NSString stringWithFormat:@"%ld ",[[dic valueForKey:@"month_order_count"] integerValue]];
        self.can_sell = [dic valueForKey:@"can_sell"];
        self.is_sell_out = [dic valueForKey:@"is_sell_out"];
        
    }
    return self;
}
+(NSArray *)systemSellModelArrayFromLatestArray:(NSArray *)input
{
    if(!input) return nil;
    NSLog(@"%s %d",__FUNCTION__,[input count]);
    NSMutableArray * data = [NSMutableArray array];
    for (NSDictionary * eve in input )
    {
        ZWSysSellModel * eveModel = [[ZWSysSellModel alloc] initWithSellBackDic:eve];
        [data addObject:eveModel];
    }
    
    return data;
}

@end
