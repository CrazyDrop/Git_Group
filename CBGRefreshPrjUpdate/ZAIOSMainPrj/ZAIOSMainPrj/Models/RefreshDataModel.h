//
//  RefreshDataModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/7.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"
//ZW数据刷新的model

@interface RefreshDataModel : BaseRequestModel

@prop_strong( NSArray *,		productsArr	OUT )

@property (nonatomic,assign) BOOL secondPage;


@end
