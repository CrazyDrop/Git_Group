//
//  WarningModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "WarningModel.h"
#import "WarningModelAPI.h"

@implementation WarningModel
-(void)sendRequest
{
    WarningModelAPI *api = [[WarningModelAPI alloc] init];
//    api.timingId = self.timingId;
    //去掉API对timingId的赋值
    api.type = self.type;
    @weakify(self)
    
    api.req.scene = self.scene;
    api.whenUpdate = ^(WarningModelResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
            [self sendSignal:self.requestLoaded withObject:resp];
        }else{
            [self sendSignal:self.requestError];
        }
    };
    
    [api send];
    
    [self sendSignal:self.requestLoading];
}


@end
