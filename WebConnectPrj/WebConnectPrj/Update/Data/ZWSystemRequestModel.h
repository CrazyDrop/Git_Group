//
//  ZWSystemRequestModel.h
//  ZAIOSMainPrj
//
//  Created by Apple on 16/8/11.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "BaseDataModel.h"
#import "ZWSysSellModel.h"

@interface ZWSystemRequestModel : BaseRequestModel

@property (nonatomic,copy) NSString * listUrl;
@property (nonatomic,assign) BOOL isFinished ;

@prop_strong( NSArray *,		sysArr	OUT )




@end
