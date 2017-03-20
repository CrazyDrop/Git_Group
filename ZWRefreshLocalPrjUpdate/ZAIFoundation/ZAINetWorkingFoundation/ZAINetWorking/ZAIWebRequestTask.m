//
//  ZAOWebRequestAPI.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIWebRequestTask.h"
#import "ZAIWebRequestService.h"
#import "ZAIWebRequestCollector.h"
#import "ZAIWebRequestKernel.h"
#import "ZAIWebRequestTask.h"

@implementation ZAIWebRequestTask

- (id) initWithParam:(NSDictionary *)apiInfos
{
    if(self = [super init])
    {
        [self setValuesForKeysWithDictionary:apiInfos];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if(value == nil)
    {
        return;
    }
    
    [super setValue:value forKey:key];
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    return;
}

#pragma mark - ZAORequest
- (void) destroy
{
    [self.request cancel];
}

- (bool) isEqualToRequest:(id<ZAIWebRequestProtocol>)element
{
    return NO;
}

- (NSString *) brief
{
    return nil;
}

@end
