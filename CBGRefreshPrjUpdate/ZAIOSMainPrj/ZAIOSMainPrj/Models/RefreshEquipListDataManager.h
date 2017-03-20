//
//  RefreshEquipListDataManager.h
//  ZAIOSMainPrj
//
//  Created by Apple on 17/1/19.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWDefaultRequestModel.h"
//列表数据请求接口，当前仅进行单一网络请求
@interface RefreshEquipListDataManager : ZWDefaultRequestModel

@property (nonatomic,strong) NSString * listUrl;

@prop_strong( NSArray *,		listArray	OUT )



@end
