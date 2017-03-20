//
//  ZWDataDetailModelManager.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/12/12.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWDataDetailModelManager.h"
#import "ZWDataDetailModel.h"

@interface ZWDataDetailModelManager()
{
    
}
@property (nonatomic,strong) NSArray * systemSellArray;
@end

@implementation ZWDataDetailModelManager

+(NSArray *)ZWDetailRateAddMoreArray
{
    NSArray * rateAdd = [NSArray arrayWithObjects:
                         @"0.0",
                         @"0.3",
                         @"0.5",
                         @"0.7",
                         @"0.75",
                         @"1.00",
                         @"1.50",
                         @"1.80",
                         nil];
    return rateAdd;
}
+(NSArray *)ZWSystemSellNormalProductsRateAndHistoryArray
{
    NSArray * sellArray = @[
                            @{@"365":@"930"},
                            @{@"365":@"880"},
                            @{@"365":@"830"},
                            @{@"365":@"800"},
                            @{@"540":@"960"},
                            @{@"540":@"930"},
                            @{@"540":@"900"},
                            @{@"540":@"860"},
                            @{@"540":@"830"},
                            @{@"720":@"1000"},
                            @{@"180":@"700"},
                            ];
    return sellArray;
}
+(NSArray *)ZWSystemSellNormalProductsRateOnlyCurrent
{
    NSArray * sellArray = @[
                            //                            @{@"365":@"930"},
                            //                            @{@"365":@"880"},
                            //                            @{@"365":@"830"},
                            @{@"365":@"800"},
                            //                            @{@"540":@"960"},
                            //                            @{@"540":@"930"},
                            //                            @{@"540":@"900"},
                            //                            @{@"540":@"860"},
                            @{@"540":@"830"},
                            @{@"720":@"1000"},
                            @{@"180":@"700"},
                            ];
    return sellArray;
}


+(instancetype)sharedInstance
{
    static ZWDataDetailModelManager *shareZWDetailCheckManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWDetailCheckManagerInstance = [[[self class] alloc] init];
    });
    return shareZWDetailCheckManagerInstance;
}
-(id)init
{
    self = [super init];
    return self;
}

-(NSArray *)systemSellArray
{
    if(!_systemSellArray)
    {
        _systemSellArray = [self createSystemSellArray];
    }
    return _systemSellArray;
}
-(NSArray *)createSystemSellArray
{
    //根据已知利率，总时长，计算可能本金数
    NSArray * rateAddArray = [ZWDataDetailModelManager ZWDetailRateAddMoreArray];
    
    NSArray * rateHistory = [ZWDataDetailModelManager ZWSystemSellNormalProductsRateAndHistoryArray];
    
    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary];
    
    //变现金额 * (1+变现利率*剩余天数)  / (1+ 购买利率 /365*总天数) =  本金
    
    
    [rateHistory enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         NSDictionary * systemDic = (NSDictionary *)obj;
         NSString * days = [[systemDic allKeys] lastObject];
         NSString * rate = [systemDic valueForKey:days];
         
         [rateAddArray enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1)
          {
              ZWDataDetailModel * model = [[ZWDataDetailModel alloc] init];
              model.duration_total = days;
              model.startRate = [NSString stringWithFormat:@"%.2f",[obj1 floatValue] + [rate floatValue]/100];
              
              NSString * rateKey = [NSString stringWithFormat:@"%@_%@",model.duration_total,model.startRate];
              CGFloat addRate = [obj1 floatValue];
              if([days isEqualToString:@"720"])
              {
                  if((addRate == 0.0 || addRate == 1.8))
                  {
                      [dataDic setObject:model forKey:rateKey];
                  }
              }else{
                  [dataDic setObject:model forKey:rateKey];
              }

          }];
     }];
    
    NSArray * dataArr = [dataDic allValues];
    return dataArr;
}

//猜测 本金
+(NSString *)startMoneyFromTotalMoney:(NSString *)money
{
    NSString * total = money;
    NSInteger number = [total integerValue];
    
    //取整计算
    NSInteger scaleNum = 10;
    CGFloat numScale = number/(scaleNum + 0.0);
    while (numScale>1)
    {
        scaleNum = scaleNum * 10;
        numScale = number/(scaleNum + 0.0);
    }
    
    scaleNum = scaleNum/10;
    NSInteger headNum = number/scaleNum;
    NSString * result = [NSString stringWithFormat:@"%d",scaleNum * headNum];
    return result;
    return total;
}

-(ZWDataDetailModel *)zwStartDataDetailModel
{
    //计算model，通过穷举系统利率天数，得出本金detail model
    ZWDataDetailModel * systemModel = [self matchingSystemDetailModel];

    //    系统model校验，本金为整数或本金金额大于10W
    if([systemModel.startMoney integerValue]%100 == 0 || [systemModel.startMoney integerValue] > 5 * 10000)
    {
        return systemModel;
    }
    
    ZWDataDetailModel * customer = [self customerSellForDetailModel];
    if(!customer)
    {
        return systemModel;
    }
    if(!systemModel)
    {
        return customer;
    }
    
    if([customer.duration_total integerValue] < [systemModel.duration_total integerValue])
    {
        return customer;
    }
    return systemModel;
}

-(ZWDataDetailModel *)matchingSystemDetailModel
{
    if(!self.startModel) return nil;
        
    //优先选择整数本金，没有则选择整数偏差最小的
    NSMutableDictionary * matchDic = [NSMutableDictionary dictionary];
    
    __block ZWDataDetailModel * selectModel = nil;
    __block CGFloat minNum = MAXFLOAT;
    
    NSArray * system = [self systemSellArray];
    [system enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        ZWDataDetailModel * model = (ZWDataDetailModel *)[obj copy];
        if([model.duration_total integerValue] > [self.startModel.duration_str integerValue])
        {
            model.total_money = self.startModel.total_money;
            model.annual_rate_str = self.startModel.annual_rate_str;
            model.duration_str = self.startModel.duration_str;

            model.startMoney = [model resultTotalMoneyFromCurrentRate];
            
            CGFloat start = [model.startMoney floatValue];
            NSInteger startInt = (int)start;
            NSInteger leftNum = startInt%100;
            NSInteger realNum = MIN(leftNum, (100 - leftNum));
            if(minNum >= realNum)
            {
                minNum = realNum;
                selectModel = model;
                
                NSString * keyNum = [NSString stringWithFormat:@"%ld",(long)realNum];
                NSArray * preArr = [matchDic objectForKey:keyNum];
                NSMutableArray * updateArr = [NSMutableArray array];
                if(preArr)
                {
                    [updateArr addObjectsFromArray:preArr];
                }
                [updateArr addObject:model];
                [matchDic setObject:updateArr forKey:keyNum];
            }
        }
    }];
    NSString * keyNum = [NSString stringWithFormat:@"%ld",(long)minNum];
    NSArray * matchArray = [matchDic objectForKey:keyNum];
    
    if([matchArray count] > 1)
    {
        NSMutableDictionary * daysDic = [NSMutableDictionary dictionary];
        __block NSInteger minDays = NSIntegerMax;
        
        [matchArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZWDataDetailModel * model = (ZWDataDetailModel *)obj;
            NSInteger modelDays = [model.duration_total integerValue];
            if(minDays >= modelDays)
            {
                minDays = modelDays;
                NSString * daysKey = [NSString stringWithFormat:@"%ld",(long)minDays];
                ZWDataDetailModel * preData = [daysDic objectForKey:daysKey];
                
                if(!preData || [preData.startRate floatValue] < [model.startRate floatValue])
                {
                    [daysDic setObject:model forKey:daysKey];
                }
            }
        }];
        
        NSString * minDaysString = [NSString stringWithFormat:@"%ld",(long)minDays];
        selectModel = [daysDic objectForKey:minDaysString];
    }
    selectModel.startMoney = [self updateDetailStartMoneyForLatest:selectModel.startMoney];
    
    return selectModel;
}
-(NSString *)updateDetailStartMoneyForLatest:(NSString * )current
{
    NSString * finishStartMoney = nil;
    CGFloat money = [current floatValue];
    NSInteger moneyInt = (int)money;
    NSInteger moneyLeft = moneyInt %100;
    if(moneyLeft == 0) return current;
    NSInteger realNum = MIN(moneyLeft, (100 - moneyLeft));
    
    if(realNum <= 2)
    {
        //计算成整百
        for(NSInteger index = -2;index<=2;index ++)
        {
            NSInteger finish = moneyInt + index;
            if(finish%100 == 0)
            {
                finishStartMoney = [NSString stringWithFormat:@"%ld",(long)finish];
                break;
            }
        }
    }else{
        finishStartMoney = [NSString stringWithFormat:@"%ld",(long)(money +0.5)];
    }
    return finishStartMoney;
}

-(ZWDataDetailModel *)customerSellForDetailModel
{
    //此种计算出的起始利率增加!以示标记
    //优先选择利率较低、天数较短的
    
    NSArray * system = [self systemSellArray];
    NSMutableDictionary * daysDic = [NSMutableDictionary dictionary];
    
    [system enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         ZWDataDetailModel * model = (ZWDataDetailModel *)[obj copy];
         
         if(![daysDic objectForKey:model.duration_total] && [model.duration_total integerValue] > [self.startModel.duration_str integerValue])
         {
             //只有系统天数大于当前天数的才有尝试必要
             model.startMoney = [ZWDataDetailModelManager startMoneyFromTotalMoney:self.startModel.total_money];
             model.duration_str = self.startModel.duration_str;
             model.total_money = self.startModel.total_money;
             model.annual_rate_str = self.startModel.annual_rate_str;
             
             model.startRate = [NSString stringWithFormat:@"%@!",[model startRateFromCurrentStartMoney]];
             if([model.startRate floatValue]<11.5 && [model.startRate floatValue] > 6.0)
             {
                 [daysDic setObject:model forKey:model.duration_total];
             }
         }
     }];
    
    NSArray * matchArr = [daysDic allValues];
    if([matchArr count] == 0){
        return nil;
    }
    
    if([matchArr count] == 1)
    {
        return [matchArr lastObject];
    }

    
    __block CGFloat minRate = MAXFLOAT;
    __block ZWDataDetailModel * selectModel = nil;
    [matchArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel * model = (ZWDataDetailModel *)obj;
        if(minRate > [model.startRate floatValue])
        {
            minRate = [model.startRate floatValue];
            selectModel = model;
        }
    }];
    return selectModel;

    return nil;
}




@end
