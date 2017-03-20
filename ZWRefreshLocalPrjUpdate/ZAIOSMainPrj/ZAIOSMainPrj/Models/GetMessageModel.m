//
//  GetMessageModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "GetMessageModel.h"
#import "GetMessageModelAPI.h"
@implementation GetMessageModel

-(void)sendRequest
{
    
    GetMessageModelAPI *api = [[GetMessageModelAPI alloc] init];
    @weakify(self)
    //    Account *account = [[AccountManager sharedInstance] account];
    //    if(account == nil)
    //    {
    //        [self sendSignal:self.requestError];
    //        return;
    //    }
    api.req.mobile = self.mobile;
    
    api.whenUpdate = ^(GetMessageModelResponse *resp, id error){
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
