//
//  RegisterModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"

@interface RegisterModel : BaseRequestModel

@prop_strong( PaPaUserInfoModel *,		info	OUT )

//@property (nonatomic,copy) NSString * username;
//@property (nonatomic,copy) NSString * password;
@property (nonatomic,copy) NSString * mobile;
@property (nonatomic,copy) NSString * vcode;


@end
