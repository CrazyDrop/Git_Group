//
//  LogoutModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "LogoutModel.h"
#import "LogoutModelAPI.h"
@implementation LogoutModel
-(void)sendRequest
{
    
   LogoutModelAPI *api = [[LogoutModelAPI alloc] init];
    @weakify(self)
    
    api.whenUpdate = ^(LogoutModelResponse *resp, id error){
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
