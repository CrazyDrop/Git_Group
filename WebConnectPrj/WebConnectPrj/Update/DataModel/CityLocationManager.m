//
//  CityLocationManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/24.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "CityLocationManager.h"
#import "ZALocationLocalModel.h"
@interface CityLocationManager()<CLLocationManagerDelegate>
{
//    CityRequestModel * _cityModel;
    BOOL isInRequesting;
}
@property (nonatomic,strong) CLLocationManager * locManager;

@end

@implementation CityLocationManager
+(instancetype)sharedInstanceManager
{
    static CityLocationManager *_sharedManagerClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManagerClient = [[CityLocationManager alloc] init];
        
    });
    return _sharedManagerClient;
}


+(BOOL)cityLocationNeedRefresh
{
    //未使用过定位
    if([ZALocation locationStatusNeverSetting])
    {
        return NO;
    }
    
    //当无定位权限，不调用
    if(![ZALocation locationStatusEnableInBackground])
    {
        return NO;
    }
    
    
    //当有位置信息，且时间不足30分钟，不调用
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * city = total.locationCity;
    NSDate * date = total.cityDate;
    
    //有城市信息，并且时间在30分钟内
    if(city && [city length]>0 && date)
    {
        NSTimeInterval count = 30 * 60;
        NSDate * endDate = [NSDate dateWithTimeInterval:count sinceDate:date];
        NSDate * now = [NSDate date];
        NSComparisonResult result = [now compare:endDate];
        return result == NSOrderedDescending;
        return NO;
    }
    
    
    return YES;
}

+(BOOL)cityListContainCurrentCity
{
    NSArray * list = [NSArray arrayWithObjects:@"北京",@"上海",@"浙江",nil];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * city = total.locationCity;

    if(!city || [city length]==0) return NO;
    
    
    //针对里面的每一个城市，进行查找，如果包含，则执行
    __block BOOL result = NO;
    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * str = (NSString *)obj;
        if([city containsString:str])
        {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}


-(CLLocationManager *)locManager
{
    if(!_locManager)
    {
        
        CLLocationManager * manager = [[CLLocationManager alloc] init];
        manager.delegate = self;
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        manager.distanceFilter = kCLDistanceFilterNone;
        manager.pausesLocationUpdatesAutomatically = YES;

        self.locManager = manager;
    }
    return _locManager;
}


-(void)startCityLocationUpdate
{
    if(self.isUpdating) return;
    
    isInRequesting = NO;
    self.isUpdating = YES;
    //启动位置定位
//    [self.locManager startUpdatingLocation];
}
-(void)startLastestLocationUpdate
{
    ZALocationLocalModel * latestModel = [[ZALocationLocalModelManager sharedInstance] latestLocationModel];
//    CityRequestModel * model = (CityRequestModel *) _cityModel;
//    if(!model){
//        model = [[CityRequestModel alloc] init];
//        [model addSignalResponder:self];
//        _cityModel = model;
//    }
//    //    39.983424,116.322987
//    model.longtitude = latestModel.longtitude;
//    model.latitude = latestModel.latitude;
//    [model sendRequest];
}


-(void)startCityModelRequestWithLocations:(NSArray *)arr
{
    if(!arr || [arr count]==0) return;

    if(isInRequesting) return;
    isInRequesting = YES;
 
    CLLocation * loc = [arr lastObject];
    
    NSString * longStr = [NSString stringWithFormat:@"%.10f", loc.coordinate.longitude];
    NSString * latStr = [NSString stringWithFormat:@"%.10f", loc.coordinate.latitude];
    
//    CityRequestModel * model = (CityRequestModel *) _cityModel;
//    if(!model){
//        model = [[CityRequestModel alloc] init];
//        [model addSignalResponder:self];
//        _cityModel = model;
//    }
//    //    39.983424,116.322987
//    model.longtitude = longStr;
//    model.latitude = latStr;
//    [model sendRequest];
    
    
    [self.locManager stopUpdatingLocation];
    self.isUpdating = NO;
}
#pragma mark CityRequestModel
handleSignal( CityRequestModel, requestError )
{
    isInRequesting = NO;
    
    //清空位置信息里的详情部分
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.locationAddress = nil;
    total.locationAddress_des = nil;
    [total localSave];
    
    [self finishedCityUpload];
}
handleSignal( CityRequestModel, requestLoading )
{
    
}
handleSignal( CityRequestModel, requestLoaded )
{
    isInRequesting = NO;
//    CityRequestModel * model = (CityRequestModel *) _cityModel;
//    NSString * city = model.cityName;
//    NSString * add = model.address;
//    NSString * des = model.address_des;
//    //保存城市名称、时间
//    if(city && [city length]>0)
//    {
//        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//        total.locationCity = city;
//        total.locationAddress = add;
//        total.locationAddress_des = des;
//        total.cityDate = [NSDate date];
//        [total localSave];
//    }
    [self finishedCityUpload];
}
-(void)finishedCityUpload
{
    //发送位置信息更新结束消息
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOAD_CITY_LOCATION_STATE object:nil];
    
}

#pragma mark -
#pragma mark ---


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%s,didUpdateLocations ",__FUNCTION__);
    [self startCityModelRequestWithLocations:locations];

    
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"%s,didFailWithError ",__FUNCTION__);
    [self startCityModelRequestWithLocations:nil];
}



@end
