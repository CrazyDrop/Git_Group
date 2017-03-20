//
//  DoWhatModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/6.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DoWhatModel.h"
#import "ZADoWhatAPI.h"
@interface DoWhatModel()
@property (nonatomic,strong) ZAHTTPApi * api;
@end
@implementation DoWhatModel
-(void)sendRequest
{
    [self.api cancel];
    self.api = nil;
    
    ZADoWhatAPI * api = [[ZADoWhatAPI alloc] init];
    @weakify(self)
    api.req.warningId = self.warningId;
    api.req.whattodo = self.whattodo;
    
    api.whenUpdate = ^(ZADoWhatModelResponse *resp, id error){
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
