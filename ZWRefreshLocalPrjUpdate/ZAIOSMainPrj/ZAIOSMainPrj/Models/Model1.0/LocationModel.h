//
//  LocationModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"

@interface LocationModel : BaseRequestModel
//上传位置

@property (nonatomic, copy) NSString *longtitude;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *altitude;
@property (nonatomic, copy) NSString *scene;
@property (nonatomic, copy) NSString *priority;



@end
