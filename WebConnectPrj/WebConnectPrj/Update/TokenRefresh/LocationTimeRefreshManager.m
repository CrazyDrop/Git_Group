//
//  LocationTimeRefreshManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "LocationTimeRefreshManager.h"
#import "ZALocation.h"
#import "ZALocationLocalModel.h"
@interface LocationTimeRefreshManager()
{
//    LocationModel * _updateModel;
//    LocalLocationsModel * _locations;
    BOOL isUploading;
}
@end
@implementation LocationTimeRefreshManager


+(instancetype)sharedInstance
{
    static LocationTimeRefreshManager *shareLocationTimeRefreshManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareLocationTimeRefreshManagerInstance = [[[self class] alloc] init];
    });
    return shareLocationTimeRefreshManagerInstance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        __weak LocationTimeRefreshManager * weakSelf = self;
        self.userDefaultIndentifyStr = @"TimeRefreshManager_Location";
        
        self.refreshInterval = LocationTimeRefreshManager_Time_Count_Normal;
        self.functionInterval = LocationTimeRefreshManager_Time_Count_Normal;
        self.funcBlock = ^(void)
        {
            [[ZALocation sharedInstance] startLocationUpdateWithEndBlock:^(CLLocation *location){
                [weakSelf backLocationDataWithString:location];
                [weakSelf finishFunctionAndSaveCurrentTime];
                [weakSelf stopAutoRefresh];//鉴于定位功能可以自动刷新，关闭timer事件
            }];
        };
        isUploading = NO;
        self.scene = @"1";
        self.priority = @"0";
        
        [self endAutoRefreshAndClearTime];
    }
    return self;
}


-(BOOL)localTimeNeedRefreshCheck
{
    BOOL result = [super localTimeNeedRefreshCheck];
    
    //如果时间判定通过
    if(result)
    {
        //检查定位单利状态
        BOOL work =  [[ZALocation sharedInstance] isInWorking];
        return !work;
    }
    
    return result;
}


//位置数据返回处理，进行数据处理，上传
-(void)backLocationDataWithString:(CLLocation *)loc
{
//        [self startReqeustWithCurrentLocation:loc];
    if(!loc) return;
    [self startLocalLocationsModelRequestWithCurrent:loc];
}
-(void)startLocalLocationsModelRequestWithCurrent:(CLLocation *)loc
{
    NSLog(@"%s VACC:%f HACC:%f speed:%f",__FUNCTION__,loc.verticalAccuracy,loc.horizontalAccuracy,loc.speed);

    //检查本地，如果不为空，则一起发送
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    
    //发送前进行处理
    ZALocationLocalModel * model = [[ZALocationLocalModel alloc] init];
    model.longtitude = [NSString stringWithFormat:@"%.10f", loc.coordinate.longitude];
    model.latitude = [NSString stringWithFormat:@"%.10f", loc.coordinate.latitude];
    model.altitude = [NSString stringWithFormat:@"%.10f", loc.altitude];
    model.scene = self.scene;
    model.priority = self.priority;
    model.date = loc.timestamp;
    model.timestamp = [model.date toString:@"yyyy-MM-dd HH:mm:ss"];
    
    
    [manager localSaveCurrentLocation:model];

    
    if(isUploading) return;
    isUploading = YES;
    
    //当本地无token，不继续发送
    NSString * token = nil;
    if(!token||[token length]==0){
        return;
    }
    
    NSArray * array = [manager localLocationsArrayForCurrent];
    array = [array sortedArrayUsingComparator:^NSComparisonResult(id loc1, id loc2){
        
        NSDate * obj1 = [(ZALocationLocalModel *)loc1 date];
        NSDate * obj2 = [(ZALocationLocalModel *)loc2 date];
        
        return [obj1 compare:obj2];
    }];
//    LocalLocationsModel * requestModel = _locations;
//    if(!requestModel)
//    {
//        requestModel = [[LocalLocationsModel alloc] init];
//        [requestModel addSignalResponder:self];
//        _locations = requestModel;
//    }
//    
//    requestModel.locations = array;
//    [requestModel sendRequest];
    
}
-(void)refreshLocalLocationsModelRequestBack
{
    //进行数据处理，
    //如果成功，则删除
    //如果失败，则保留，不处理
    
//    NSArray * array = [_locations.locations copy];
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
//    [manager clearUploadedLocations:array];
    
    
}
#pragma mark LocalLocationsModel
handleSignal( LocalLocationsModel, requestError )
{
    isUploading = NO;
//    [self refreshLocalLocationsModelRequestBack];
    //    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( LocalLocationsModel, requestLoading )
{
    
}

handleSignal( LocalLocationsModel, requestLoaded )
{
    [self refreshLocalLocationsModelRequestBack];
    isUploading = NO;
    //    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    
}
#pragma mark - PrivateLocationModel
-(void)startReqeustWithCurrentLocation:(CLLocation *)loc
{
    //    NSLog(@"backLocationDataWithString %f %f %f",loc.speed,loc.horizontalAccuracy,loc.verticalAccuracy);
//    LocationModel * model = _updateModel;
//    if(!model)
//    {
//        model = [[LocationModel alloc] init];
//        [model addSignalResponder:self];
//        _updateModel = model;
//    }
    NSLog(@"%s VACC:%f HACC:%f speed:%f",__FUNCTION__,loc.verticalAccuracy,loc.horizontalAccuracy,loc.speed);
    //进行数据填充
//    model.longtitude = [NSString stringWithFormat:@"%.10f", loc.coordinate.longitude];
//    model.latitude = [NSString stringWithFormat:@"%.10f", loc.coordinate.latitude];
//    model.altitude = [NSString stringWithFormat:@"%.10f", loc.altitude];
//    model.scene = self.scene;
//    model.priority = self.priority;
//    
//    [model sendRequest];
}

-(void)refreshStateForUpdateLocalLocation
{
    //可以考虑进行数据保存
    
    //更新状态，以便定义能继续
}

#pragma mark LocationModel
handleSignal( LocationModel, requestError )
{
    [self refreshStateForUpdateLocalLocation];
//    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( LocationModel, requestLoading )
{

}

handleSignal( LocationModel, requestLoaded )
{
    
    [self refreshStateForUpdateLocalLocation];
//    if([DZUtils checkAndNoticeErrorWithSignal:signal])

}
#pragma mark -
//清空起始时间，并结束
-(void)endAutoRefreshAndClearTime
{
    //清空更新时间记录
    [super endAutoRefreshAndClearTime];
    [[ZALocation sharedInstance] stopUpdateLocation];
//    [[ZALocationLocalModelManager sharedInstance] clearTotalLocations];
    
}

-(void)restartRefreshTimeWithCurrentSetting
{
//    self.scene = 
    
    [self stopAutoRefresh];
    [self saveCurrentAndStartAutoRefresh];
}
-(void)refreshRefreshTimeWithHeighPriority
{
    self.functionInterval = LocationTimeRefreshManager_Time_Count_Heigh;
    self.refreshInterval = LocationTimeRefreshManager_Time_Count_Heigh;
    [self restartRefreshTimeWithCurrentSetting];
}

-(void)refreshRefreshTimeWithNormalPriority
{
    self.functionInterval = LocationTimeRefreshManager_Time_Count_Normal;
    self.refreshInterval = LocationTimeRefreshManager_Time_Count_Normal;
    [self restartRefreshTimeWithCurrentSetting];
}

@end
