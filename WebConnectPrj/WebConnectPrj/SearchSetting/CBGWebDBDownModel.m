//
//  CBGWebDBDownModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGWebDBDownModel.h"
#import "ZALocationHTTPApi.h"

@interface CBGWebDBDownModel()
@property (nonatomic,strong) ZALocationHTTPApi * api;
@end

@implementation CBGWebDBDownModel

-(void)sendRequest
{
    //    NSAssert(!self.latitude||!self.longtitude, @"经纬度坐标，不可以为空");
    
    
    [self.api cancel];
    self.api = nil;
    
    ZALocationHTTPApi *api = [[ZALocationHTTPApi alloc] init];
    @weakify(self)
    //    Account *account = [[AccountManager sharedInstance] account];
    //    if(account == nil)
    //    {
    //        [self sendSignal:self.requestError];
    //        return;
    //    }
    //    api.req.longtitude = self.longtitude;
    //    api.req.latitude = self.latitude;
    

    api.whenUpdate = ^(ZALocationHTTPResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
            [self sendSignal:self.requestLoaded withObject:resp];
        }else{
            [self sendSignal:self.requestError];
        }
    };
    self.api = api;
    [api send];
    
    [self sendSignal:self.requestLoading];
}

@end
