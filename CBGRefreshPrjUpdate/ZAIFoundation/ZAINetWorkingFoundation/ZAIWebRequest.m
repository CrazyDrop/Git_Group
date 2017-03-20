//
//  ZAOnlineRequest.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIWebRequest.h"

@interface ZAIWebRequest()

@end

@implementation ZAIWebRequest

- (void)setBlockWithReturnBlock:(ReturnSucessBlock)sucessBlock withFailedBlock:(ReturnFailedBlock)failedBlock
{
    _sucessBlock = sucessBlock;
    _failedBlock = failedBlock;
}

- (void) cancelFetch
{
    [ZAIWebRequestAPI cancelRequest:self.requestId];
}
- (NSString *)sign
{
    return @"";
}
-(ZAIWebRequestTask *)buildWebRequestAPIWithDics:(NSDictionary *)dic
{
    return nil;
}
@end
