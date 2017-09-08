//
//  ZALocalModelDBManager.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZALocalModelDBManager.h"

@implementation ZALocalModelDBManager

-(id)initWithDBExtendString:(NSString *)extend
{
    self = [super initWithDBExtendString:extend];
    if(self)
    {
        self.panicSpecial = YES;
    }
    return self;
}



@end
