//
//  OpenTimesModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "OpenTimesModel.h"
#import "ZAOpenTimesAPI.h"

@interface OpenTimesModel()
@property (nonatomic,strong) ZAHTTPApi * api;
@end
@implementation OpenTimesModel
-(void)sendRequest
{
    [self.api cancel];
    self.api = nil;
    
    ZAOpenTimesAPI * api = [[ZAOpenTimesAPI alloc] initWithWarnTimingId:self.warnId];
    @weakify(self)
    
    api.whenUpdate = ^(ZAOpenTimesResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
            self.times = resp.returnData.opentimes;
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