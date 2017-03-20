//
//  ZWDataDetailModelManager.h
//  ZAIOSMainPrj
//
//  Created by Apple on 16/12/12.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZWDataDetailModel;
@interface ZWDataDetailModelManager : NSObject
//存储数据，进行数据分析计算

+(instancetype)sharedInstance;

+(NSArray *)ZWSystemSellNormalProductsRateOnlyCurrent;
+(NSArray *)ZWSystemSellNormalProductsRateAndHistoryArray;
+(NSArray *)ZWDetailRateAddMoreArray;

@property (nonatomic,strong,readonly) NSArray * systemSellArray;
@property (nonatomic,strong) ZWDataDetailModel * startModel;

-(ZWDataDetailModel *)zwStartDataDetailModel;



@end
