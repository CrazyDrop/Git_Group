//
//  ZAIWebRequestManager.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/16.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIWebRequestManager.h"
#import "ZAIOSVERSION.h"
#import "ZAIWebRquestSessionManager.h"
#import "ZAIWebRequestOperationManager.h"

@implementation ZAIWebRequestManager

+(id<ZAIWebRequestManagerProtocol>)shareClient;
{
    if(OSVERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        return [ZAIWebRquestSessionManager sharedClient];
    }
    else
    {
        return [ZAIWebRequestOperationManager sharedClient];
    }
}

@end
