//
//  RefreshEquipDetailDataManager.h
//  ZAIOSMainPrj
//
//  Created by Apple on 17/1/19.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWDefaultRequestModel.h"
//处理详情数据网络请求，进行批量请求，每次数据返回单独回调
@class EquipModel;
@interface RefreshEquipDetailDataManager : ZWDefaultRequestModel

@property (nonatomic,strong) NSString * listUrl;

@prop_strong( EquipModel *,		detailModel	OUT )


@end
