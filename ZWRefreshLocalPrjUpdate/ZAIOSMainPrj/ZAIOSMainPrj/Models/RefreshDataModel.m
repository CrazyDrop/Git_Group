//
//  RefreshDataModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/7.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "RefreshDataModel.h"
#import "ZWDataRefreshAPI.h"

@interface RefreshDataModel()
@property (nonatomic,strong) ZWDataRefreshHTTPApi * api;
@end

@implementation RefreshDataModel

-(ZWDataRefreshHTTPApi * )api
{
    if(!_api)
    {
       ZWDataRefreshHTTPApi * http = [[ZWDataRefreshHTTPApi alloc] init];
        self.api = http;
    }
    return _api;
}

-(void)sendRequest
{
    //    NSAssert(!self.latitude||!self.longtitude, @"经纬度坐标，不可以为空");
    
    
    [self.api cancel];
    
    self.productsArr = nil;
    ZWDataRefreshHTTPApi *api = self.api;
    api.nextPage = self.secondPage;
    @weakify(self)
    //    Account *account = [[AccountManager sharedInstance] account];
    //    if(account == nil)
    //    {
    //        [self sendSignal:self.requestError];
    //        return;
    //    }
    //    api.req.longtitude = self.longtitude;
    //    api.req.latitude = self.latitude;
    
    api.whenUpdate = ^(ZWDataRefreshHTTPResponse *resp, id error){
        @strongify(self)
        if(resp||YES)
        {
//            NSDictionary * dic = self.api.responseObject;
            self.productsArr = self.api.responseObject;
            
            
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
