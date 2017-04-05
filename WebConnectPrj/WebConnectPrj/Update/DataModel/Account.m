//
//  Account.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/12.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "Account.h"

@implementation Account

@synthesize userId;
@synthesize name;
@synthesize token;
@synthesize acctInfoComplete;
@synthesize isRegister;

-(BOOL)isInfoCompleted
{//1为信息已经补全
    return [self.acctInfoComplete intValue]==1 ;
}
@end
