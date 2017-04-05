//
//  ZALocation.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/9.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
//相关功能
//1、启动定位功能，并返回启动结果    用户是否允许
//2、针对用户关闭定位功能的   打开开启服务器界面   仅针对ios8以上用户有效
//3、启动定位功能，通过block，返回定位结果

typedef void (^LocationDoneBlock)(CLLocation * locStr);

@interface ZALocation : NSObject
@property (nonatomic,assign,readonly,getter=isInUpdating) BOOL inUpdating;
@property (nonatomic,strong,readonly) CLLocationManager * locManager;
@property (nonatomic,assign,readonly,getter=isInWorking) BOOL inWorking;

@property (nonatomic,copy) LocationDoneBlock addBlock;
//定位功能，是否未曾设置许可条件？
+(BOOL)locationStatusNeverSetting;


//定位功能，是否支持前台启动
+(BOOL)locationStatusEnableInForground;


//定位功能，是否支持后台运行
+(BOOL)locationStatusEnableInBackground;


-(void)startLocationRequestUserAuthorization;


//1、启动定位功能，并返回启动结果    用户是否允许
//3、启动定位功能，通过block，返回定位结果
//返回结果为，开启成功与否，包括前台启动，以及后台启动
//启动前，需要确保用户开启当前定位，以及定位
-(BOOL)startLocationUpdateWithEndBlock:(LocationDoneBlock) endBlock;


//主动关闭定位功能
-(void)stopUpdateLocation;


//2、针对用户关闭定位功能的   打开开启服务器界面   仅针对ios8以上用户有效
//返回结果为，跳转成功与否
-(BOOL)openSystemLocationSettingPage:(id)sender;



@end
