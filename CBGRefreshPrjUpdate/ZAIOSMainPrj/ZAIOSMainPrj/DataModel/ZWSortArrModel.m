//
//  ZWSortArrModel.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/4/26.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWSortArrModel.h"
#import "ZWDataDetailModel.h"
@implementation ZWSortArrModel

-(id)init
{
    self = [super init];
    if(self)
    {
        self.daysArr = [NSMutableArray array];
    }
    return self;
}

//变现数据统计
-(id)sortArrModelFromDetailArray:(NSArray *)arr
{
    if (!arr || [arr count]==0) {
        return nil;
    }
    
    __block NSString * date = nil;;
    __block CGFloat money = 0.0;
    ZWSortArrModel * sort = [[ZWSortArrModel alloc] init];
    sort.daysArr = [NSMutableArray arrayWithArray:arr];
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel * eve = (ZWDataDetailModel *)obj;
        money += ([eve.total_money floatValue]);
        if(!date && eve.finishedDate)
        {
//            2016-04-26 13:02,2016-04-26 05:15:56 +0000
            NSLog(@"eve.start_sell_date,eve.finishedDate %@ %@",eve.start_sell_date,eve.finishedDate);
            date = eve.finishedDate;
        }
    }];
    
    NSString * showMoney = nil;
    if(money >= 10000 * 1000)
    {
        showMoney = [NSString stringWithFormat:@"%d千万",((int)money)/(10000 * 1000)];
    }else if(money >= 10000)
    {
        showMoney = [NSString stringWithFormat:@"%d万",((int)money)/10000];
    }else{
        showMoney = [NSString stringWithFormat:@"%.01f万",money/10000.0];
    }
    sort.sortDateStr = date;
    sort.totalMoneyStr = showMoney;
    
    return sort;
    return nil;
}

+(NSArray *)totalSortModelArrayFromTotalDetailArray:(NSArray *)array
{
    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary];
//    2016-04-26 05:15:56 +0000
//    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        ZWDataDetailModel * eve = (ZWDataDetailModel *)obj;
//        NSString * date = eve.finishedDate?:eve.start_sell_date;
//        NSString * tagStr = @"#";
//        if(date && [date length]>10)
//        {
//            tagStr = [date substringToIndex:[@"2016-04-26" length]];
//        }
//        
//        ZWSortArrModel * sort = [dataDic objectForKey:tagStr];
//        if(!sort){
//            sort = [[ZWSortArrModel alloc] init];
//            sort.sortDateStr = tagStr;
//            [dataDic setObject:sort forKey:tagStr];
//        }
//        
//        sort.money += ([eve.total_money floatValue]);
//        [sort.daysArr addObject:eve];
//        
//    }];
    for (NSInteger index = 0;index < [array count] ;index ++ )
    {
        ZWDataDetailModel * eve = (ZWDataDetailModel *)[array objectAtIndex:index];
        NSString * date = eve.finishedDate?:eve.start_sell_date;
        NSString * tagStr = @"#";
        if(date && [date length]>10)
        {
            tagStr = [date substringToIndex:[@"2016-04-26" length]];
        }
        
        ZWSortArrModel * sort = [dataDic objectForKey:tagStr];
        if(!sort){
            sort = [[ZWSortArrModel alloc] init];
            sort.sortDateStr = tagStr;
            [dataDic setObject:sort forKey:tagStr];
        }

        
        sort.money += ([eve.total_money floatValue]);
        [sort.daysArr addObject:eve];
    }
    
    
    return [dataDic allValues];
    return nil;
}
-(NSString *)totalMoneyStr
{
    CGFloat aMoney = self.money;
    NSString * showMoney = nil;
    if(aMoney >= 10000 * 1000)
    {
        showMoney = [NSString stringWithFormat:@"%d千万",((int)aMoney)/(10000 * 1000)];
    }else if(aMoney >= 10000)
    {
        showMoney = [NSString stringWithFormat:@"%d万",((int)aMoney)/10000];
    }else{
        showMoney = [NSString stringWithFormat:@"%.01f万",aMoney/10000.0];
    }
    return showMoney;
}


-(NSString *)description
{
    NSMutableString * show = [NSMutableString string];
    [show appendFormat:@"%@ ",self.sortDateStr];
    [show appendFormat:@" %@ ",self.totalMoneyStr];
    return show;
}


@end
