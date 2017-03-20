//
//  AccountInfo.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/12.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseDataModel.h"

@interface AccountInfo : BaseDataModel

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *realName;
@property (nonatomic, copy) NSString *certificateNo;
@property (nonatomic, copy) NSString *certificateType;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *birthday;



@end
