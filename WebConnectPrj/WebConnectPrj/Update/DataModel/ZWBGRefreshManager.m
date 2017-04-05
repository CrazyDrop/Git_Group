//
//  ZWBGRefreshManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/14.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWBGRefreshManager.h"
#import "RefreshDataModel.h"
#import "ZALocationLocalModel.h"
#import "ZWDataDetailModel.h"

@interface ZWBGRefreshManager()
{
    BaseRequestModel * _dpModel;
}
@property (nonatomic,copy) void(^doneRefreshWebRequestBlock)(UIBackgroundFetchResult result);
@end

@implementation ZWBGRefreshManager

+(instancetype)sharedInstance
{
    static ZWBGRefreshManager *shareZWBGRefreshManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWBGRefreshManagerInstance = [[[self class] alloc] init];
    });
    return shareZWBGRefreshManagerInstance;
}


-(void)startZWBGRefreshWithFinishBlock:(void (^)(UIBackgroundFetchResult result))block
{
    self.doneRefreshWebRequestBlock = block;
    [self startRefreshDataModelRequest];
}

-(void)doneBlockWithResult:(UIBackgroundFetchResult)result{
    if(self.doneRefreshWebRequestBlock){
        self.doneRefreshWebRequestBlock(result);
    }
}


-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        [self doneBlockWithResult:UIBackgroundFetchResultFailed];
        return;
    }
//    [[UIApplication sharedInstance] setMinimumBackgroundFetchInterval:<#(NSTimeInterval)#>]
    //    [KMStatis staticQuickCancelViewEvent:StaticQuickCancelEventType_Request];
    
    //数据上传，通知解除
    RefreshDataModel * model = (RefreshDataModel *) _dpModel;
    if(!model){
        model = [[RefreshDataModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    [model sendRequest];
}


#pragma mark RefreshDataModel
handleSignal( RefreshDataModel, requestError )
{
    //    [self hideLoading];
    
    [self doneBlockWithResult:UIBackgroundFetchResultNoData];
}
handleSignal( RefreshDataModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
}

handleSignal( RefreshDataModel, requestLoaded )
{
    //    [self hideLoading];
    
    RefreshDataModel * model = (RefreshDataModel *) _dpModel;
    NSArray * array  = model.productsArr;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ///数组查找填充
        ZWDataDetailModel  * model = (ZWDataDetailModel *)obj;
        NSString * rate = model.earnRate;
        if(rate && [rate floatValue]>14)
        {
            ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
            BOOL firstAdd = [manager localSaveCurrentLocation:obj];
            if(firstAdd && [model.total_money intValue]>5000)
            {
                [self vibrate];
            }
        }
        
    }];
    [self doneBlockWithResult:UIBackgroundFetchResultNewData];
}
- (void)vibrate
{
    AudioServicesPlaySystemSound(1320);
    //    1327
}




@end
