//
//  NTBasicRequest.m
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "NTBasicRequest.h"
@interface NTBasicRequest()
{
    NSMutableDictionary * containDic;
}
@property (nonatomic,strong) NSString * requestid;
@end

@implementation NTBasicRequest
@synthesize requestid;
-(id)initWithRequestIdStr:(NSString *)str
{
    self = [super init];
    if (self) {
        self.requestid = str;
        self.sepcialRequestTag = NO;
        self.needAuthorization = NO;
        containDic = [NSMutableDictionary dictionary];
    }
    return self;
}
+(instancetype)basicNTRequestModelWithRequestIDStr:(NSString *)aReqeustid
{
    NTBasicRequest * request = [[NTBasicRequest alloc] initWithRequestIdStr:aReqeustid];
    return request;
}

- (NSDictionary *)currentDataDic
{
    return [NSDictionary dictionaryWithDictionary:containDic];
}

- (void)removeObjectForKey:(id)aKey
{
    [containDic removeObjectForKey:aKey];
}
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    if (!aKey)
    {
        return;
    }
    
    if (anObject)
    {
        [containDic setObject:anObject forKey:aKey];
    }else
    {
        [containDic removeObjectForKey:aKey];
    }

}
- (void)setValue:(id)value forKey:(NSString *)key
{
    [self setObject:value forKey:key];
}


@end
