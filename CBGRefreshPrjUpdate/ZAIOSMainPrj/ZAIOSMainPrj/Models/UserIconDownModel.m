//
//  UserIconDownModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/10.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "UserIconDownModel.h"
#import "UserIconDownModelAPI.h"

@interface UserIconDownModel()
@property (nonatomic,strong) STIHTTPApi * api;
@end

@implementation UserIconDownModel

-(void)sendRequest
{
    
    [self.api cancel];
    self.api = nil;
    self.iconData = nil;
    
    UserIconDownModelAPI *api = [[UserIconDownModelAPI alloc] init];
    
    @weakify(self)
    
    
    api.whenUpdate = ^(UserIconDownModelResponse *resp, id error){
        @strongify(self)
        
        NSData * data  = self.api.responseObject;
        UIImage * img = [UIImage imageWithData:data];
        if(img)
        {
            self.iconData = data;
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
