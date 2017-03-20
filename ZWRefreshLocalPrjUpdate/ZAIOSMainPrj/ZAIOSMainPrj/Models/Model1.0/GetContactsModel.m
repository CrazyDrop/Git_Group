//
//  GetContactsModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "GetContactsModel.h"
#import "GetContactsModelAPI.h"
@interface GetContactsModel ()
@property (nonatomic, strong) STIHTTPApi * api;
@end

@implementation GetContactsModel

- (id)init
{
    self = [super init];
    if ( self )
    {
       
    }
    return self;
}

-(void)sendRequest
{
    [self.api cancel];
     self.contacts = [NSMutableArray array];
    
    self.isInRequesting = YES;
    
    GetContactsModelAPI *api = [[GetContactsModelAPI alloc] init];
    @weakify(self)
    //    Account *account = [[AccountManager sharedInstance] account];
    //    if(account == nil)
    //    {
    //        [self sendSignal:self.requestError];
    //        return;
    //    }
    
    api.whenUpdate = ^(GetContactsModelResponse *resp, id error){
        @strongify(self)
        self.isInRequesting = NO;
        if(resp)
        {

            [self.contacts addObjectsFromArray:resp.returnData];
            
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
