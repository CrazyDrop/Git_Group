//
//  LoginModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"

@interface LoginModel : BaseRequestModel

@prop_strong( PaPaUserInfoModel *,		info	OUT )

@property (nonatomic,copy) NSString * mobile;
@property (nonatomic,copy) NSString * vcode;

@end
