//
//  WarningModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"

typedef enum {
    WarningModel_TYPE_START,
    WarningModel_TYPE_STOP
} WarningModelTYPE;

//预警处理model
@interface WarningModel : BaseRequestModel
//2、启动
//3、取消


@property (nonatomic,copy) NSString * scene;

/*
 新接口修改后,已经不需要此数据
 参数可以正常赋值，但是不会传递到请求API中
 */
//倒计时编号
@property (nonatomic,copy) NSString * timingId;


@property (nonatomic,assign)  WarningModelTYPE type;





@end
