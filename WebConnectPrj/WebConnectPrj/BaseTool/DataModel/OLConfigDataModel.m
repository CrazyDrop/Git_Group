//
//  OLConfigDataModel.m
//  WebConnectPrj
//
//  Created by Apple on 14-10-15.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "OLConfigDataModel.h"

@implementation OLConfigDataModel

-(id)initWithWebDic:(NSDictionary *)dic
{
    self = [super initWithWebDic:dic];
    if (self)
    {
        self.ctpriStr = [dic valueForKey:@"ctpri"];
        self.ctproStr = [dic valueForKey:@"ctpro"];
        self.vnpriStr = [dic valueForKey:@"vnpri"];
        self.vnproStr = [dic valueForKey:@"vnpro"];
    }
    return self;
}


@end
