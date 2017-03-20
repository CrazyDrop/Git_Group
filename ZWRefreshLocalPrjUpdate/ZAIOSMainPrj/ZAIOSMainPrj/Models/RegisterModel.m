//
//  RegisterModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "RegisterModel.h"
#import "RegisterModelAPI.h"
@implementation RegisterModel
-(void)sendRequest
{
    
    RegisterModelAPI *api = [[RegisterModelAPI alloc] init];
    @weakify(self)
    
    api.req.mobile = self.mobile;
    api.req.vcode = self.vcode;
    self.info = nil;
    
    api.whenUpdate = ^(RegisterModelResponse *resp, id error){
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
