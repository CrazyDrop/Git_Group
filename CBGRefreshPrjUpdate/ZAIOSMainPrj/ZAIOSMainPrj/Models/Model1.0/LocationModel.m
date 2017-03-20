//
//  LocationModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "LocationModel.h"
#import "ZALocationModelAPI.h"

@implementation LocationModel

- (void)sendRequest
{
    ZALocationModelAPI *api = [[ZALocationModelAPI alloc] init];
    @weakify(self)
//    Account *account = [[AccountManager sharedInstance] account];
//    if(account == nil)
//    {
//        [self sendSignal:self.requestError];
//        return;
//    }
    api.req.longtitude = self.longtitude;
    api.req.latitude = self.latitude;
    api.req.altitude = self.altitude;
    api.req.scene = self.scene;
    api.req.priority = self.priority;
    
    api.whenUpdate = ^(ZALocationModelResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
//            AccountInfo *info = [[AccountInfo alloc] init];
//            info.realName = resp.userName;
//            info.certificateType = resp.certificateType;
//            info.certificateNo = resp.certificateNo;
//            info.gender = resp.gender;
//            info.birthday = resp.birthday;
//            info.phoneNo = resp.phoneNo;
//            self.accountInfo = info;
//            [[AccountManager sharedInstance] saveAccountInfo:info];
            [self sendSignal:self.requestLoaded withObject:resp];
        }else{
            [self sendSignal:self.requestError];
        }
    };
    
    [api send];
    
    [self sendSignal:self.requestLoading];
}



@end
