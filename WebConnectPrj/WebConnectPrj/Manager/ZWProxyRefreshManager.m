//
//  ZWProxyRefreshManager.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/10.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWProxyRefreshManager.h"
#import "VPNProxyModel.h"
@interface ZWProxyRefreshManager()
@property (nonatomic, strong) NSArray * proxySubCache;
@end
@implementation ZWProxyRefreshManager

+(instancetype)sharedInstance
{
    static ZWProxyRefreshManager *shareZWDetailCheckManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWDetailCheckManagerInstance = [[[self class] alloc] init];
    });
    return shareZWDetailCheckManagerInstance;
}

-(NSArray *)proxySubCache
{
    if(!_proxySubCache)
    {
        NSMutableArray * edit = [NSMutableArray arrayWithArray:self.proxyArrCache];
        [edit sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber * number1 = [NSNumber numberWithInteger:[(VPNProxyModel * )obj1 errorNum]];
            NSNumber * number2 = [NSNumber numberWithInteger:[(VPNProxyModel * )obj2 errorNum]];
            
            return [number1 compare:number2];
        }];
        
        NSArray * sub = nil;
        if([edit count] > 300){
           sub = [edit subarrayWithRange:NSMakeRange(0, 300)];
        }else{
            sub = edit;
        }
        _proxySubCache = edit;
    }
    return _proxySubCache;
}
-(void)clearProxySubCache
{
    self.proxySubCache = nil;
}


@end
