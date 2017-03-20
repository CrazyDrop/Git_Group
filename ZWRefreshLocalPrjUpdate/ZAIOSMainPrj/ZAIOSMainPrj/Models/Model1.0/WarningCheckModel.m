//
//  WarningCheckModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/8/19.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "WarningCheckModel.h"
#import "WarningModelAPI.h"

@interface WarningCheckModel ()
@property (nonatomic, strong) STIHTTPApi * api;
@end

@implementation WarningCheckModel

-(void)sendRequest
{
    WarningModelAPI *api = [[WarningModelAPI alloc] init];
    @weakify(self)
    
    [self.api cancel];
    self.warnModel = nil;
    api.whenUpdate = ^(WarningModelResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
            self.warnModel = resp.returnData;
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
