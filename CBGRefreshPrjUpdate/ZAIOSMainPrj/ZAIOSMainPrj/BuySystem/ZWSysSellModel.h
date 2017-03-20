//
//  ZWSysSellModel.h
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/11.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "BaseDataModel.h"

@interface ZWSysSellModel : BaseDataModel
//系统销售记录
@property (nonatomic,strong) NSString * sell_date;//记录时间

//利率
@property (nonatomic,strong) NSString * annual_rate_str;
//时长
@property (nonatomic,strong) NSString * duration_str;
//日期
@property (nonatomic,strong) NSString * due_date_str;//截止时间
//编号
@property (nonatomic,strong) NSString * product_id;
@property (nonatomic,strong) NSString * updated_at;//更新时间
@property (nonatomic,strong) NSString * start_date;//起息时间
@property (nonatomic,strong) NSString * sold_amount;
@property (nonatomic,strong) NSString * total_amount;

@property (nonatomic,strong) NSString * name;
@property (nonatomic,assign) BOOL can_sell;
@property (nonatomic,assign) BOOL is_sell_out;
@property (nonatomic,strong) NSString * month_order_count;//数字



-(instancetype)initWithSellBackDic:(NSDictionary *)dic;
+(NSArray *)systemSellModelArrayFromLatestArray:(NSArray *)array;


@end
