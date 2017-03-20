//
//  WarnTimingModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "WarnTimingModel.h"
#import "WarnTimingModelAPI.h"
#import "AutoCoding.h"
#import "NSObject+AutoCoding.h"
@interface WarnTimingModel()
@property (nonatomic,strong) STIHTTPApi * api;
@end

@implementation WarnTimingModel

-(void)sendRequest
{
    [self.api cancel];
    self.api = nil;
    
    WarnTimingModelAPI *api = [[WarnTimingModelAPI alloc] init];
    @weakify(self)
    
    self.isInRequesting = YES;
    api.req.scene = self.scene;
    api.req.duration = self.duration;

    api.whenUpdate = ^(WarnTimingModelResponse *resp, id error){
        @strongify(self)
        self.isInRequesting = NO;
        if(resp)
        {
            self.timeId = [resp.returnData id];
            [self sendSignal:self.requestLoaded withObject:resp];
        }else{
            [self sendSignal:self.requestError];
        }
    };
    
    self.api = api;
    [self.api send];
    [self sendSignal:self.requestLoading];
}



@end
