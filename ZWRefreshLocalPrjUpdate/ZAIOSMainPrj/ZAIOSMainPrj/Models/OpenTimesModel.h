//
//  OpenTimesModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"

@interface OpenTimesModel : BaseRequestModel

@prop_strong( NSString *,		times	OUT )

@property (nonatomic,strong) NSString * warnId;



@end
