//
//  DPViewController+AddressAuth.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/2/29.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"
@class ZAAuthorityController;
@interface DPViewController (AddressAuth)

@property (nonatomic,strong) ZAAuthorityController * showAuthVC;

//权限弹框
-(void)startShowAddressAuthorityViewWithBlock:(void(^)(BOOL enable))block;



@end
