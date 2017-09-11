//
//  ZWProxyRefreshModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/9/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPNProxyModel.h"

@class ZWProxyRefreshModel;
@protocol ZWProxyCheckRefreshModelDelegate <NSObject>

-(void)proxyCheckRefreshModel:(ZWProxyRefreshModel *)model finishedCheckWithSuccess:(NSArray *)success andFail:(NSArray *)fail;

@end

//代理刷新、检查、更新、控制model
@interface ZWProxyRefreshModel : NSObject

@property (nonatomic, assign, readonly) BOOL isFinished;
@property (nonatomic, strong) NSArray<VPNProxyModel *> * checkArr;   //传入的数组为VPNProxyModel
@property (nonatomic, assign) NSInteger maxSubNum;

@property (nonatomic, assign) id<ZWProxyCheckRefreshModelDelegate> resultDelegate;

-(void)startProxyRefreshCheck;
-(void)cancelLatestProxyRefreshCheck;



@end
