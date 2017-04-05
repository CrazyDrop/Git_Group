//
//  Account.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/12.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseDataModel.h"

@interface Account : BaseDataModel

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *acctInfoComplete;
@property (nonatomic, copy) NSString *isRegister;
-(BOOL)isInfoCompleted;
@end
