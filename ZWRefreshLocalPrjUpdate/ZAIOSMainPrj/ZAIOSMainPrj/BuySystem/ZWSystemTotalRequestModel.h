//
//  ZWSystemTotalRequestModel.h
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/25.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWSystemTotalRequestModel : BaseRequestModel

@property (nonatomic,strong)  NSMutableArray * dataArr;
@prop_strong( NSArray *,		sysArr	OUT )


-(void)checkWebResponseWithResultDic:(NSDictionary *)data;
-(NSArray *)defaultSortArray;


@end
