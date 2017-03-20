//
//  CityLocationManager.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/24.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
//完成城市信息的定位，请求，数据保存等数据
@interface CityLocationManager : NSObject


+(instancetype)sharedInstanceManager;

//默认为NO
@property (nonatomic,assign) BOOL isUpdating;


+(BOOL)cityLocationNeedRefresh;


+(BOOL)cityListContainCurrentCity;


//启动位置更新
-(void)startCityLocationUpdate;//完成时会自动关闭定位

-(void)startLastestLocationUpdate;




@end
