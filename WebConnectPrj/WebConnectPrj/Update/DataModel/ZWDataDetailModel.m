//
//  ZWDataDetailModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/8.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDataDetailModel.h"
#import "ZWDataDetailModelManager.h"


@implementation ZWDataDetailModel

-(id)init
{
    self = [super init];
    if(self){
        self.containDays = @"30天";
    }
    return self;
}
#pragma mark - WebDataCheck
-(id)initWithRefreshDic:(NSDictionary *)dic
{
    self = [self init];
    if(self)
    {
        self.annual_rate_str = [dic valueForKey:@"annual_rate_str"];
        self.duration_str = [dic valueForKey:@"duration_str"];
        self.updated_at = [dic valueForKey:@"updated_at"];
        
        self.product_id = [NSString stringWithFormat:@"%@",[dic valueForKey:@"product_id"]];
        self.created_at = [dic valueForKey:@"created_at"];
        self.start_sell_date = [dic valueForKey:@"start_sell_date"];

        self.disappearNum = 0;
        NSArray * arr = [dic valueForKey:@"prod_intro_tips"];
        if([arr count]>0)
        {
            NSDictionary * tip_dic = [arr firstObject];
            self.total_money = [tip_dic valueForKey:@"value"];
        }
        
        
        arr = [dic valueForKey:@"product_intro_items"];
        if([arr count]>0)
        {
            NSDictionary * tip_dic = [arr firstObject];
            self.left_money = [tip_dic valueForKey:@"value"];
        }
     
//        if(!self.annual_rate_str){
//            self.annual_rate_str = []
//        }
    }
    return self;
}
+(NSArray *)dataArrayFromJsonArray:(NSArray *)array
{
    if(!array || [array isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    
    NSMutableArray * result = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel * detail = [[ZWDataDetailModel alloc] initWithRefreshDic:obj];
        [result addObject:detail];
    }];
    
    return result;
}
#pragma mark - 
#pragma mark - dataModelSell
-(NSString *)sellRate
{
    if(!_sellRate)
    {
        self.sellRate = [self sellRateWithDataTime];
    }
    return _sellRate;
}


-(NSString * )sellRateWithDataTime
{
    NSInteger daysNum = [self.duration_str intValue];
    NSInteger number = 610;
    
    if(daysNum < 60) return nil;
    
    NSInteger contain = 30;
    if(self.containDays){
        contain = [self.containDays intValue];
    }
    
    NSInteger leftDays = daysNum - contain - 15;
    NSInteger months = leftDays / 30;
    
    NSString * yearNumStr = kAPP_YEAR_TOTAL_RATE_NUMBER;
    ZALocalStateTotalModel  * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * rate = total.sellRateStr;
    if(rate && [[rate componentsSeparatedByString:@","] count]==14)
    {
        yearNumStr = rate;
    }
    
    NSArray * arr = [yearNumStr componentsSeparatedByString:@","];
    if(months < 12)
    {
        NSString * str = [arr objectAtIndex:months];
        number = [str intValue];
    }else if(months < 15)
    {
        number = [[arr objectAtIndex:12] intValue];
    }else{
        number = [[arr objectAtIndex:13] intValue];
    }
    NSString * result = [NSString stringWithFormat:@"%ld",number];
    return result;
}

-(NSString *)earnRate
{
    if(!_earnRate)
    {
        self.earnRate = [self earnRateWithDataTime];
    }
    return _earnRate;
    
}

-(NSString * )earnRateWithDataTime
{
    if(!self.sellRate) return @"0";

    NSInteger sellRate = [self.sellRate intValue];
    NSInteger daysNum = [self.duration_str intValue];
    NSInteger buyRate = [self.annual_rate_str floatValue] * 100;

    if(buyRate < sellRate) return nil;
    
    NSInteger contain = 30;
    if(self.containDays){
        contain = [self.containDays intValue];
    }
    
    CGFloat yearDays = 365.0;
    CGFloat loss = 0.5/100.0;
    if(self.rateUpdate){
        loss = 0.8/100.0;
    }
    if(contain > 60){
        loss = 0.2/100.0;
    }
    //总金额
    CGFloat totaMoney = 10000 + daysNum * buyRate/yearDays;
    
    //比率
    CGFloat prepareRate = 1+(daysNum - contain)/yearDays*sellRate/10000.0;
    
    CGFloat result = ((totaMoney * 1/(prepareRate + 0.0))*(1-loss) - 10000)/(contain+0.0) * yearDays/100.0;
    if(result<0) return nil;
    
    
    return [NSString stringWithFormat:@"%02.2f%%",result];
}

+(void)startRateTest
{
    ZWDataDetailModel * detail = [[ZWDataDetailModel alloc] init];
    detail.annual_rate_str = @"9.99%%";
    detail.duration_str = @"180天";
    
    NSString * str = detail.earnRate;
    NSLog(@"%s %@",__FUNCTION__,str);
}
+(void)startDetailManagerTest
{
    ZWDataDetailModel * detail = [[ZWDataDetailModel alloc] init];
    detail.duration_str = @"289";
    detail.annual_rate_str = @"8.40%";
    detail.total_money = @"123880.74";
    
    [detail refreshStartState];
    NSLog(@"%s %@ %@",__FUNCTION__,detail.startRate,detail.startMoney);
    
}
-(DetailModelSaveType)currentModelState
{
    DetailModelSaveType type = DetailModelSaveType_NoUse;
    CGFloat earnRate = [self.earnRate floatValue];
    NSInteger days = [self.duration_str intValue];
    CGFloat buyRate = [self.annual_rate_str floatValue];
    
    //新增统计部分
    if(earnRate>14)
    {
        type = DetailModelSaveType_Buy;
        if([self.total_money floatValue]<=2000)
        {
            type = DetailModelSaveType_Notice;
        }
    }else{
        //
        if(days <= 100 && buyRate>9.5){
            //天数少，且利率较高
            type = DetailModelSaveType_Notice;
            
        }else if(days <= 200 && buyRate>9.7)
        {
            type = DetailModelSaveType_Notice;
        }else if(buyRate>9.8)
        {
            type = DetailModelSaveType_Notice;
        }
    }
    
    if(type == DetailModelSaveType_NoUse && earnRate > 13){
        type = DetailModelSaveType_Save;
    }
    
    return type;
}
#pragma mark - 
#pragma mark - DetailAndHistoryShow

-(NSArray *)zwResultArrayForDifferentSellRate
{
    //预计数据数组，针对变化的销售利率
    NSMutableArray * array = [NSMutableArray array];
    
    ZWDataDetailModel * model = [[ZWDataDetailModel alloc] init];
    model.annual_rate_str = self.annual_rate_str;
    model.duration_str = self.duration_str;
    model.sellRate = self.sellRate;
    
    NSString * sellRate = [model sellRate];
    NSString * earnRate = model.earnRate;
    BOOL needNext = NO;
    if(earnRate && [earnRate floatValue]>10)
    {
        needNext = YES;
    }
    
    NSString * desResult =  [model currentEarnResultForSell];
    if(!desResult){
        [array addObject:desResult];
    }
    
    while (needNext)
    {
        sellRate = [NSString stringWithFormat:@"%d",[sellRate intValue] + 5];
        model.sellRate = sellRate;
        model.earnRate = nil;
        earnRate = model.earnRate;
        desResult =  [model currentEarnResultForSell];
        [array addObject:desResult];
        
        needNext = NO;
        if(earnRate && [earnRate floatValue]>15)
        {
            needNext = YES;
        }
    }
    return array;
}

-(NSString * )currentEarnResultForSell
{
    
    NSString * earnRate = self.earnRate;
    NSMutableString * result = [NSMutableString string];
    [result appendFormat:@"盈利%@ 销售%.2f%% 天数%d天 购买%@%%",earnRate,[self.sellRate floatValue]/100.0,[self.duration_str intValue] - [self.containDays intValue],[NSString stringWithFormat:@"%.2f",[self.annual_rate_str floatValue]]];
    
    return result;
}


+(NSArray *)systemArrayFromLocalSave
{
    NSMutableArray * array = [NSMutableArray array];

    NSArray * rateAdd = [ZWDataDetailModelManager ZWDetailRateAddMoreArray];

    NSArray * systemArr = [ZWDataDetailModelManager ZWSystemSellNormalProductsRateOnlyCurrent];

    [systemArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        NSDictionary * dataDic = (NSDictionary *)obj;
        NSArray * keys = [dataDic allKeys];
        NSString * key = [keys lastObject];
        for (NSInteger index = 0;index<[rateAdd count];index++ )
        {
            NSString * add = [rateAdd objectAtIndex:index];
            NSInteger buyRate = [key integerValue];
            buyRate = (buyRate + (int)([add floatValue] * 100));
            
            ZWDataDetailModel * detail = [[ZWDataDetailModel alloc] init];
            detail.duration_str = [NSString stringWithFormat:@"%@天",obj];
            detail.annual_rate_str = [NSString stringWithFormat:@"%.2f",buyRate/100.0];
            detail.total_money = [NSString stringWithFormat:@"%@%% + %@%%",[NSString stringWithFormat:@"%.2f",[key integerValue]/100.0],add];
            [array addObject:detail];
        }
    }];
    
    return array;
}

+(NSArray *)zwResultArrayForContainDifferentDaysAndEarnRateWithModel:(id)dataModel withRefresh:(BOOL)refresh
{
    //天数变化，动态得出收益利率
    //预计数据数组，针对变化的销售利率
    NSMutableArray * array = [NSMutableArray array];
    
    ZWDataDetailModel * detail = (ZWDataDetailModel *)dataModel;
    
    ZWDataDetailModel * model = [detail copy];
    model.earnRate = nil;
    model.rateUpdate = refresh;
    
    NSInteger leftDays = [detail.duration_str intValue] - [detail.containDays intValue];
    NSString * earnRate = model.earnRate;
    BOOL needNext = NO;
    if(earnRate && [earnRate floatValue]>10&&leftDays>30)
    {
        needNext = YES;
    }
    
    [array addObject:model];
    
    NSString * containLength = model.containDays;
    
    while (needNext)
    {
        containLength = [NSString stringWithFormat:@"%ld天",[containLength integerValue] + 5];

        ZWDataDetailModel * eveModel = [model copy];
        eveModel.containDays = containLength;
        eveModel.earnRate = nil;
        leftDays = [eveModel.duration_str intValue] - [eveModel.containDays intValue];

        [array addObject:eveModel];
        
        NSString * earnRate = eveModel.earnRate;
        needNext = NO;
        if(earnRate && [earnRate floatValue]>10 && leftDays>30)
        {
            needNext = YES;
        }
        
        
    }
    return array;
}
#pragma mark -

-(void)refreshStartState
{
    ZWDataDetailModel * perhaps = [self perhapsDetailModelFromCurrent];
    self.startRate = perhaps.startRate;
    self.startMoney = perhaps.startMoney;
    self.duration_total = perhaps.duration_total;
    
}

-(ZWDataDetailModel *)perhapsDetailModelFromCurrent
{
    ZWDataDetailModelManager * manager = [ZWDataDetailModelManager sharedInstance];
    manager.startModel = self;
    ZWDataDetailModel * detail = [manager zwStartDataDetailModel];
    return detail;
}
//变现金额 * (1+变现利率*剩余天数)  / (1+ 购买利率 /365*总天数) =  本金
-(NSString *)resultTotalMoneyFromCurrentRate
{
    CGFloat leftTotal = [self.total_money floatValue] * (1.0 + [self.annual_rate_str floatValue] /100.0 /365.0 * [self.duration_str integerValue] );
    
    CGFloat bottom = (1.0 + [self.startRate floatValue] / 100.0 / 365.0 * [self.duration_total intValue]);
    
    CGFloat result = leftTotal/(0.0 + bottom);
    return [NSString stringWithFormat:@"%.2f",result];
    return nil;
}

//变现金额 * (1+变现利率*剩余天数)  / (1+ 购买利率 /365*总天数)  = 本金
//变现金额 * (1+变现利率*剩余天数)  / 本金 =  (1+ 购买利率 /365*总天数)
-(NSString *)startRateFromCurrentStartMoney
{
    CGFloat leftTotal = [self.total_money floatValue] * (1.0 + [self.annual_rate_str floatValue] /100.0 /365.0 * [self.duration_str integerValue] )/([self.startMoney integerValue] + 0.0);
    
    CGFloat result = (leftTotal - 1.0) * 365 / ([self.duration_total integerValue] + 0.0);
    return [NSString stringWithFormat:@"%.2f",result * 100];
    return nil;
}



@end
