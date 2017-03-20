//
//  LocalLocationsModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "LocalLocationsModel.h"
#import "ZALocationsModelAPI.h"
@interface LocalLocationsModel()
@property (nonatomic, strong) STIHTTPApi * api;
@end
@implementation LocalLocationsModel

- (void)sendRequest
{
    
    [self.api cancel];
    self.api = nil;
    
    ZALocationsModelAPI *api = [[ZALocationsModelAPI alloc] init];
    @weakify(self)
    //    Account *account = [[AccountManager sharedInstance] account];
    //    if(account == nil)
    //    {
    //        [self sendSignal:self.requestError];
    //        return;
    //    }
    
    NSMutableArray * array = [NSMutableArray array];
    [self.locations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary * eveDic = [NSMutableDictionary dictionaryWithDictionary:[obj dictionaryRepresentation]];
        if([eveDic valueForKey:@"date"])
        {
            [eveDic removeObjectForKey:@"date"];
        }
        [array addObject:eveDic];

    }];
    
    api.req.locationList = array;
    
    api.whenUpdate = ^(ZALocationsModelResponse *resp, id error){
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
