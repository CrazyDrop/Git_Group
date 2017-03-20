//
//  RefreshListDataManager.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/7/19.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RefreshListDataManager : BaseRequestModel
{
    
}

//@property (nonatomic,  copy) void (^DoneTotalRefreshForRequestSuccess)(NSArray * array);
-(NSArray *)totalRefreshListDataForBackDataDic:(NSDictionary *)dic;


-(NSArray *)defaultSortArray;
@prop_strong( NSArray *,		productsArr	OUT )

-(void)cancel;

@end
