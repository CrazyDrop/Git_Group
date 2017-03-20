//
//  GetContactsModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"
//获取紧急联系人列表
@interface GetContactsModel : BaseRequestModel
//获取ContactsModel列表

@prop_strong( NSMutableArray *,		contacts	OUT )

@property (nonatomic, assign) BOOL isInRequesting;

@end
