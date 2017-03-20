//
//  DelContactsModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DelContactsModel.h"
#import "DelContactsModelAPI.h"

@implementation DelContactsModel
-(void)sendRequest
{
    DelContactsModelAPI *api = [[DelContactsModelAPI alloc] init];
    api.contanctId = self.id;
    @weakify(self)
    //    Account *account = [[AccountManager sharedInstance] account];
    //    if(account == nil)
    //    {
    //        [self sendSignal:self.requestError];
    //        return;
    //    }
    api.req.id = self.id;
    
    api.whenUpdate = ^(DelContactsModelResponse *resp, id error){
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
