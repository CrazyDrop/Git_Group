//
//  StartedLogModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/13.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "StartedLogModel.h"
#import "ZAStartLogAPI.h"

@interface StartedLogModel()
@property (nonatomic,strong) ZAHTTPApi * api;
@end
@implementation StartedLogModel
-(void)sendRequest
{
    [self.api cancel];
    self.api = nil;
    
    ZAStartLogAPI * api = [[ZAStartLogAPI alloc] init];
    @weakify(self)
    
    api.whenUpdate = ^(ZAStartLogResponse *resp, id error){
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
