//
//  ZAAddressController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"
//实现通讯录列表，页面展示，选择，以及搜索

//点击详情,直接进入
@interface ZAAddressController : DPViewController

@property (nonatomic,copy) void(^TapedOnSelectAddressPerson)(id obj);


+(BOOL)addressBookAuthNeverStarted;
+(BOOL)addressBookAuthStateEnable;

+(void)startAddressAddWithBlock:(void(^)(BOOL enable))block;


+(BOOL)addContactToUserAddressList;



@end
