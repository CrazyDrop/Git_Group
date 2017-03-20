//
//  RefreshTokenModel.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/19.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "RefreshTokenModel.h"

@interface RefreshTokenModel()

@property (nonatomic, assign) BOOL isRefresh;

@end

@implementation RefreshTokenModel
@synthesize isRefresh;

//- (void)modelSave
//{
//    Account *account = [[AccountManager sharedInstance] account];
//    [[AccountManager sharedInstance] saveAccount:account];
//}

//- (void)sendRequest
//{
//    Account *account = [[AccountManager sharedInstance] account];
//    if(account == nil)
//    {
//        [self sendSignal:self.requestError];
//        return;
//    }
//    
//    if(self.isRefresh)
//        return;
//    RefreshTokenAPI *api = [[RefreshTokenAPI alloc] init];
//    @weakify(self)
//    api.req.token = account.token;
//    api.whenUpdate = ^(RefreshTokenResponse *resp, id error){
//        @strongify(self)
//        if(resp)
//        {
//            self.isRefresh = NO;
//            if(resp.token)
//            {
//                Account *account = [[AccountManager sharedInstance] account];
//                account.token = resp.token;
//                [self modelSave];
//            }
//            [self sendSignal:self.requestLoaded withObject:resp];
//        }else{
//            [self sendSignal:self.requestError];
//        }
//    };
//    
//    self.isRefresh = YES;
//    [api send];
//    
//    [self sendSignal:self.requestLoading];
//}


//static RefreshTokenModel *sharedInstance = nil;
//+ (RefreshTokenModel *)sharedInstance
//{
//    static dispatch_once_t token;
//    dispatch_once(&token, ^{
//        sharedInstance = [[[self class] alloc] init];
//    });
//    return sharedInstance;
//}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.isRefresh = NO;
    }
    return self;
}

@end
