//
//  LocationTimeRefreshManager.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "TimeRefreshManager.h"
//完成位置定位的定时调用，以及相应的数据上传
//定位功能，具体实现由ZALocation 完成

#define LocationTimeRefreshManager_Time_Count_Normal 60
#define LocationTimeRefreshManager_Time_Count_Heigh  30
@interface LocationTimeRefreshManager : TimeRefreshManager

//1为倒计时，2为紧急
@property (nonatomic,strong) NSString * scene;

/*
 0、默认等级
 1、密码倒计时结束、或倒计时时间结束
 2、用户手动触发预警
 3、强制关闭后的再次启动
 */
@property (nonatomic,strong) NSString * priority;


-(void)refreshRefreshTimeWithHeighPriority;
-(void)refreshRefreshTimeWithNormalPriority;
//-(void)restartRefreshTimeWithCurrentSetting;



@end
