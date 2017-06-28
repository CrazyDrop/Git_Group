//
//  CBGWebDBUploadModel.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/28.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGWebDBUploadModel.h"
#import "ZALocationHTTPApi.h"

@interface CBGWebDBUploadModel()
@property (nonatomic,strong) ZALocationHTTPApi * api;
@end

@implementation CBGWebDBUploadModel


-(void)sendRequest
{
    //    NSAssert(!self.latitude||!self.longtitude, @"经纬度坐标，不可以为空");
    
    
    [self.api cancel];
    self.api = nil;
    
    ZALocationHTTPApi *api = [[ZALocationHTTPApi alloc] init];
    @weakify(self)
    
    
    
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
    [api sendUploadRequest];
    
    [self sendSignal:self.requestLoading];
}




@end
