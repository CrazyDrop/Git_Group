//
//  QuickWarningModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "QuickWarningModel.h"
#import "ZAQuickWarningAPI.h"

@interface QuickWarningModel()
@property (nonatomic,strong) ZAHTTPApi * api;
@end
@implementation QuickWarningModel
-(void)sendRequest
{
    [self.api cancel];
    self.api = nil;
    
    ZAQuickWarningAPI * api = [[ZAQuickWarningAPI alloc] init];
    api.req.scene = self.scene;
    api.req.duration = self.duration;
    
    @weakify(self)
    
    api.whenUpdate = ^(ZAQuickWarningResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
            self.timeId = [resp.returnData id];
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