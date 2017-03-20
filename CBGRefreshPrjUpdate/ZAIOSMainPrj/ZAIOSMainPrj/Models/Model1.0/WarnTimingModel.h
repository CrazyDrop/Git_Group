//
//  WarnTimingModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"

//倒计时model
@interface WarnTimingModel : BaseRequestModel

@property (nonatomic, assign) BOOL isInRequesting;


@prop_strong( NSString *,		timeId	OUT )

//启动倒计时
@property (nonatomic,copy) NSString * scene; //建议增加scene
@property (nonatomic,copy) NSString * duration;

@property (nonatomic,copy) NSString * whattodo;

@end
