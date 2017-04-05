//
//  OLBasicDataModel.h
//  WebConnectPrj
//
//  Created by Apple on 14-10-15.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>

//服务器端数据简历的model模型基础类，便于区分
//尽可能的必带initWithWebDic: 方法

@interface OLBasicDataModel : NSObject
-(id)initWithWebDic:(NSDictionary *)dic;


@end
