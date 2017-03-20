//
//  ZWSortArrModel.h
//  ZAIOSMainPrj
//
//  Created by Apple on 16/4/26.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"

@interface ZWSortArrModel : BaseRequestModel

@property (nonatomic,strong) NSString * sortDateStr;
@property (nonatomic,strong) NSMutableArray * daysArr;
@property (nonatomic,strong) NSString * totalMoneyStr;
@property (nonatomic,assign) CGFloat money;

//变现数据统计
//-(id)sortArrModelFromDetailArray:(NSArray *)arr;

+(NSArray *)totalSortModelArrayFromTotalDetailArray:(NSArray *)array;

@end
