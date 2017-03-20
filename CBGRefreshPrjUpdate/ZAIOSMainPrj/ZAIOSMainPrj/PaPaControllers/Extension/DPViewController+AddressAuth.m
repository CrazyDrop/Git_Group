//
//  DPViewController+AddressAuth.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/2/29.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController+AddressAuth.h"
#import "ZAAuthorityController.h"
#import "ZAAddressController.h"
@implementation DPViewController (AddressAuth)

ADD_DYNAMIC_PROPERTY(ZAAuthorityController*, OBJC_ASSOCIATION_RETAIN, showAuthVC, setShowAuthVC);


-(void)startShowAddressAuthorityViewWithBlock:(void(^)(BOOL enable))block
{
//    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
//    if(!model.address_Authority_Showed)//暂不使用此参数，使用系统权限做判定
    {
//        model.address_Authority_Showed = YES;
//        [model localSave];
        
        __weak typeof(self) weakSelf = self;
        ZAAuthorityController * tip = [[ZAAuthorityController alloc] init];
        tip.type = ZAAuthorityCheckType_Address;
        tip.TapedOnAuthorityBtnBlock = ^(ZAAuthoritySelectType type)
        {
            [ZAAddressController startAddressAddWithBlock:^(BOOL enable){
                [weakSelf.showAuthVC checkUpAuthorityResultForSelectedType:type];
                [weakSelf.showAuthVC.view removeFromSuperview];
                weakSelf.showAuthVC = nil;
                block(enable);
            }];
        };
        tip.TapedOnCloseAuthorityBtnBlock = ^()
        {
            [weakSelf.showAuthVC.view removeFromSuperview];
            weakSelf.showAuthVC = nil;
        };
        [self.view addSubview:tip.view];
        self.showAuthVC = tip;
    }
}

@end
