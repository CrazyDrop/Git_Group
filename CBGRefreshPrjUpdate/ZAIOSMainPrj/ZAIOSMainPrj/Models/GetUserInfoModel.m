//
//  GetUserInfoModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "GetUserInfoModel.h"
#import "GetUserInfoModelAPI.h"
@implementation GetUserInfoModel
-(void)sendRequest
{
    
    GetUserInfoModelAPI *api = [[GetUserInfoModelAPI alloc] init];
    @weakify(self)
    self.info = nil;
    
    api.whenUpdate = ^(GetUserInfoModelResponse *resp, id error){
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
