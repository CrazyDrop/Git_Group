//
//  RefreshListDataManager.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/7/19.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
//用来管理一组数据的网络请求
@interface RefreshListDataManager : BaseRequestModel
{
    
}

-(NSArray *)defaultSortArray;
@prop_strong( NSArray *,		productsArr	OUT )
@prop_strong( NSArray *,		systemArr	OUT )
@prop_strong( NSArray *,		topArr	OUT )

-(void)cancel;

@end
