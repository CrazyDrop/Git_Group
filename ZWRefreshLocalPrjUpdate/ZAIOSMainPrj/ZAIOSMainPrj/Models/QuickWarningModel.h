//
//  QuickWarningModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"

@interface QuickWarningModel : BaseRequestModel

@prop_strong( NSString *,		timeId	OUT )

//启动倒计时
@property (nonatomic,copy) NSString * scene; //建议增加scene
@property (nonatomic,copy) NSString * duration;


@end
