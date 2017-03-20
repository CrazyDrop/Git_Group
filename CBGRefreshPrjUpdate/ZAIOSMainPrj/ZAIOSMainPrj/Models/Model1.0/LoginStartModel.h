//
//  LoginStartModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/22.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseDataModel.h"

//作为父类使用，此区域数据全部临时,(存储的数据，不能永久存在，重启后消失)
@interface LoginStartModel : BaseDataModel

//新增参数 lock warningId status scene Duration remain
@property (nonatomic,strong) NSString * lock;
//@property (nonatomic,strong) NSString * warningId;
@property (nonatomic,strong) NSString * status;
@property (nonatomic,strong) NSString * scene;
@property (nonatomic,strong) NSString * duration;
@property (nonatomic,strong) NSString * remain;

@property (nonatomic,strong) NSString * whattodo;

-(BOOL)userTimingOutOfControlForState;


@end
