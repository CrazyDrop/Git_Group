//
//  ZALocation.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/9.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocation.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface ZALocation()<CLLocationManagerDelegate>
{
//    CLLocationManager * _locationManager;
//    LocationDoneBlock  _endBlock;
    NSDate * preDate;
    CLLocation * preLocation;
}

@property (nonatomic,assign) BOOL inUpdating;
@property (nonatomic,strong) NSArray * locArray;
@property (nonatomic,strong) CLLocationManager * locManager;
@property (nonatomic,copy) LocationDoneBlock endBlock;
@end

@implementation ZALocation
@synthesize inWorking = _inWorking;
@synthesize locManager= _locationManager;
@synthesize inUpdating = _inUpdating;
+(instancetype)sharedInstance
{
    static ZALocation * _sharedZALocation = nil;
    if(!_sharedZALocation)
    {
        _sharedZALocation = [[ZALocation alloc] init];
    }
    return _sharedZALocation;
}
-(id)init
{
    self = [super init];
    if(self)
    {
//        CLCircularRegion
//        CLRegion
        
        CLLocationManager * manager = [[CLLocationManager alloc] init];
        manager.delegate = self;
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        manager.distanceFilter = kCLDistanceFilterNone;
        manager.pausesLocationUpdatesAutomatically = NO;
        if(iOS9_constant_or_later)
        {
            if([manager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]){
                 manager.allowsBackgroundLocationUpdates = YES;
            }
        }
        
        
        
        _inWorking = NO;
        _inUpdating = NO;
        _locationManager = manager;
        
        preDate = nil;
        preLocation = nil;
    }
    return self;
}


+(BOOL)locationStatusNeverSetting
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if(status == kCLAuthorizationStatusNotDetermined)
    {
        return YES;
    }
    return NO;
}

//定位功能，是否支持前台启动
+(BOOL)locationStatusEnableInForground
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if(iOS8_constant_or_later){
        if(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            return YES;
        }
        return NO;
    }
    ALAuthorizationStatus status2 = [ALAssetsLibrary authorizationStatus];
    //如果用户同意
    if(status2 == ALAuthorizationStatusAuthorized)
    {
        return YES;
    }
    return NO;
}


//定位功能，是否支持后台运行
+(BOOL)locationStatusEnableInBackground
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if(iOS8_constant_or_later){
        if(status == kCLAuthorizationStatusAuthorizedAlways)
        {
            return YES;
        }
            return NO;
    }
    ALAuthorizationStatus status2 = [ALAssetsLibrary authorizationStatus];
    //如果用户同意
    if(status2 == ALAuthorizationStatusAuthorized)
    {
        return YES;
    }
    return NO;
}

-(void)startLocationRequestUserAuthorization
{
    if(iOS8_constant_or_later){
        [_locationManager requestAlwaysAuthorization];
        
        
    }

    
//    _inWorking = YES;
    [_locationManager startUpdatingLocation];
}



//1、启动定位功能，并返回启动结果    用户是否允许
//3、启动定位功能，通过block，返回定位结果
//返回结果为，开启成功与否
-(BOOL)startLocationUpdateWithEndBlock:(void(^)(CLLocation *))block
{
    if(_inWorking) return NO;
    _inUpdating = YES;
    _inWorking = YES;
    self.endBlock = block;
    
    if(self.locArray && [self.locArray count]>0)
    {
        NSLog(@"%s,TimerAutoStart,%@",__FUNCTION__,[self.locArray lastObject]);
        [self doneLocationManagerWithArray:self.locArray];
        return YES;
    }
    
    [_locationManager startUpdatingLocation];
    
    return YES;
}
-(void)stopUpdateLocation
{
    NSLog(@"%s",__FUNCTION__);
    self.locArray = nil;
    self.endBlock = nil;
    preLocation = nil;
    preDate = nil;
    _inUpdating = NO;
    
    [_locationManager stopUpdatingLocation];
    [_locationManager stopMonitoringSignificantLocationChanges];
    [self doneUpdateLocationFunction];
}

-(void)doneUpdateLocationFunction
{
//    [_locationManager stopUpdatingLocation];
    _inWorking = NO;
}

-(void)doneLocationManagerWithArray:(NSArray *)arr
{
    if(self.endBlock)
    {
        if([DZUtils isValidateArray:arr]||!arr)
        {
            self.endBlock([arr lastObject]);
        }
    }
}

//2、针对用户关闭定位功能的   打开开启服务器界面   仅针对ios8以上用户有效
//返回结果为，跳转成功与否
-(BOOL)openSystemLocationSettingPage:(id)sender
{
    if(iOS8_constant_or_later)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString]];
        return YES;
    }
    return NO;
}
-(BOOL)uploadLocationsFromLocalCheckWithNewLocations:(NSArray *)arr
{
    if([arr count]==0)
    {
        return YES;
    }
    
    CLLocation * current  = [arr lastObject];
    if(![current isKindOfClass:[CLLocation class]])
    {
        return YES;
    }
    
    //位置判定
    if(!preLocation||!preDate)
    {
        preDate = [NSDate date];
        preLocation = current;
        return YES;
    }
    
    //当经纬度一致，时间不足时，返回NO
    if(preLocation.coordinate.latitude == current.coordinate.latitude && preLocation.coordinate.longitude == current.coordinate.longitude)
    {
        //判定数据是否一致
        NSDate * date = [NSDate dateWithTimeInterval:30 sinceDate:preDate];
        NSDate * now = [NSDate date];
        NSTimeInterval count = [date timeIntervalSinceDate:now];
        NSLog(@"%s 重复 %.10f %.10f",__FUNCTION__,preLocation.coordinate.latitude,preLocation.coordinate.longitude);
        
        //当1分钟以内，重复的数据不上传
        if(count>0) return NO;
    }
    

    preDate = [NSDate date];
    preLocation = current;
    
    return YES;
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{

    if(self.isInUpdating)
    {
         self.locArray = locations;
    }

    
    if(![self uploadLocationsFromLocalCheckWithNewLocations:locations])
    {
        return;
    }
    NSLog(@"%s,locations %lu %@",__FUNCTION__,(unsigned long)[locations count],[locations lastObject]);
    //增加排重排定，位置一致，不再重复发送
    
    [self doneLocationManagerWithArray:locations];
    [self doneUpdateLocationFunction];

}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"%s,didFailWithError ",__FUNCTION__);
    [self doneLocationManagerWithArray:nil];
    [self doneUpdateLocationFunction];
}



@end
