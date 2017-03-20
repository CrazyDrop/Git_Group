//
//  LoginModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "LoginModel.h"
#import "LoginModelAPI.h"
@implementation LoginModel
-(void)sendRequest
{
    
    LoginModelAPI *api = [[LoginModelAPI alloc] init];
    @weakify(self)
    self.info = nil;
    
    api.req.mobile = self.mobile;
    api.req.vcode = self.vcode;
    
    api.whenUpdate = ^(LoginModelResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
            self.info = resp.returnData;
            [self sendSignal:self.requestLoaded withObject:resp];
        }else{
            [self sendSignal:self.requestError];
        }
    };
    
    [api send];
    
    [self sendSignal:self.requestLoading];
}
@end
