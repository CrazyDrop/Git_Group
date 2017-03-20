//
//  ZAConfigModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/21.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZAConfigModel : NSObject

//紧急模式(紧急和立即求助)  录音时长
@property (nonatomic,strong) NSString * quick_recorder_length;

//倒计时模式时间到达  录音时长
@property (nonatomic,strong) NSString * timing_recorder_length;


//紧急模式(紧急和立即求助)  预警界面标题切换等待时间
@property (nonatomic,strong) NSString * quick_waiting_length;

//倒计时模式时间到达  标题切换等待时间
@property (nonatomic,strong) NSString * timing_waiting_length;

-(void)refreshConfigDataWithList:(NSDictionary *)dic;

+(instancetype)sharedInstanceManager;



@end
