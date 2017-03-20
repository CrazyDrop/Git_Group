//
//  CityRequestModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/23.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "CityRequestModel.h"
#import "ZALocationHTTPApi.h"

@interface CityRequestModel()
@property (nonatomic,strong) ZALocationHTTPApi * api;
@end

@implementation CityRequestModel

-(void)sendRequest
{
//    NSAssert(!self.latitude||!self.longtitude, @"经纬度坐标，不可以为空");
    
    
    [self.api cancel];
    self.api = nil;
    self.cityName = nil;
    self.address = nil;
    self.address_des = nil;
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

    NSString * locationStr  = [NSString stringWithFormat:@"%@,%@",self.latitude,self.longtitude];
    api.req.location = locationStr;
    api.whenUpdate = ^(ZALocationHTTPResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
            NSDictionary * dic = self.api.responseObject;
            
            NSString * add = nil;
            NSString * name = nil;
            NSString * des = nil;
            if(dic && [dic isKindOfClass:[NSDictionary class]])
            {
                add = [dic valueForKeyPath:@"result.formatted_address"];
                name = [dic valueForKeyPath:@"result.addressComponent.city"];
                des = [dic valueForKeyPath:@"result.sematic_description"];
            }
            self.address = add;
            self.address_des = des;
            self.cityName = name;
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
