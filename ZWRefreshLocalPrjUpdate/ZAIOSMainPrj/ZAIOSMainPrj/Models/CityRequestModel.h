//
//  CityRequestModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/23.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"
//城市信息的请求model
@interface CityRequestModel : BaseRequestModel

@prop_strong( NSString *,		cityName	OUT )
@prop_strong( NSString *,		address	OUT )
@prop_strong( NSString *,		address_des	OUT )

@property (nonatomic,copy) NSString * longtitude;
@property (nonatomic,copy) NSString * latitude;


@end
