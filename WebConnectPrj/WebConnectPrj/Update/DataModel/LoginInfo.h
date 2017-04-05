//
//  LoginInfo.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseDataModel.h"

@interface LoginInfo : BaseDataModel

@property (nonatomic, copy) NSString *phoneNo;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *otherToken;
@property (nonatomic, strong) NSNumber *otherTokenType;

@end
