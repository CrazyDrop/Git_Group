//
//  ContactTellModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/17.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ContactTellModel.h"
#import "ZAContactTellAPI.h"
@interface ContactTellModel()
@property (nonatomic,strong) ZAHTTPApi * api;
@end
@implementation ContactTellModel

-(void)sendRequest
{
    
    [self.api cancel];
    self.api = nil;
    
    ZAContactTellAPI * api = [[ZAContactTellAPI alloc] initWithContactedId:self.contactId];
    
    @weakify(self)

    
    api.whenUpdate = ^(ZAContactTellResponse *resp, id error){
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
