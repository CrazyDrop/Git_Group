//
//  ModifyUserInfoModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ModifyUserInfoModel.h"
#import "ModifyUserInfoModelAPI.h"
@implementation ModifyUserInfoModel
-(void)sendRequest
{
    
   ModifyUserInfoModelAPI *api = [[ModifyUserInfoModelAPI alloc] init];
    @weakify(self)
    api.req.username = self.username;
    api.req.password = self.password;
    api.whenUpdate = ^(ModifyUserInfoModelResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
            [self sendSignal:self.requestLoaded withObject:resp];
        }else{
            [self sendSignal:self.requestError];
        }
    };
    
    [api send];
    
    [self sendSignal:self.requestLoading];
}
@end
