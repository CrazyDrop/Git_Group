//
//  GetUserInfoModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"
@class PaPaUserInfoModel;
@interface GetUserInfoModel : BaseRequestModel

@prop_strong( PaPaUserInfoModel *,		info	OUT )

@end
