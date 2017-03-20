//
//  ZAORequestCollector.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIWebRequestCollector.h"

typedef void (^visitor)(id<NSCopying> aKey, id<ZAIWebRequestProtocol> anRequest);

static unsigned long requestIDCount = 0;

@interface ZAIWebRequestCollector()

@property(nonatomic, copy)NSMutableDictionary *requestCollector;

@end

@implementation ZAIWebRequestCollector

- (id) init
{
    if (self = [super init])
    {
        _requestCollector = [NSMutableDictionary new];
    }
    
    return self;
}

-(ZAIRequestID)insertRequest:(id<ZAIWebRequestProtocol>)request
{
    if (!request)
    {
        return ZAORequestInvalidID;
    }
    
    ZAIRequestID uid = [self nextUid];
    [self setValue:request withKey:[self packUid:uid]];
    NSLog(@"insert element [%@] -- id[%ld]",
           [request respondsToSelector:@selector(brief)] ? [request brief] : (NSObject *)request,
           uid);
    return uid;
}


- (ZAIRequestID) findRequest:(id<ZAIWebRequestProtocol>)request
{
    if (!request)
        return ZAORequestInvalidID;
    
    for (id<NSCopying> key in [self keyEnumerator])
    {
        if ([[self objectForKey:key] isEqualToRequest:request])
            return [self unpackUid:key];
    }
    
    return ZAORequestInvalidID;
}

- (bool) removeRequestWithUid:(ZAIRequestID)uid
{
    if (uid == ZAORequestInvalidID)
    {
        NSLog(@"%@", @"element is nil");
        return NO;
    }
    
    id<NSCopying> key = [self packUid:uid];
    
    if ([self hasKey:key])
    {
         NSLog(
         @"remove element [%@] -- id[%ld]",
         [[self objectForKey:key] respondsToSelector:@selector(brief)] ? [[self objectForKey:key] brief] : (NSObject *)[self objectForKey:key],
         uid);
        
        [[self objectForKey:key] destroy];
        [self removeObjectForKey:key];
        return YES;
    }
    
    return NO;
}

- (id<ZAIWebRequestProtocol>) requestForUid : (ZAIRequestID) uid
{
    return [self objectForKey:[self packUid:uid]];
}

- (bool) removeRequest:(id<ZAIWebRequestProtocol>)request
{
    return [self removeRequestWithUid:[self findRequest:request]];
}


#pragma mark - 生成UID

- (ZAIRequestID) nextUid
{
    return requestIDCount++;
}

#pragma mark - 将UID打包/解包

- (id<NSCopying>) packUid : (ZAIRequestID) uid
{
    return [NSNumber numberWithUnsignedLong:uid];
}

- (ZAIRequestID) unpackUid : (id<NSCopying>) packedUid
{
    NSNumber *number = (NSNumber *)packedUid;
    if (![number isKindOfClass:[NSNumber class]])
    {
        return ZAORequestInvalidID;
    }
    
    return [number unsignedLongValue];
}

#pragma mark - setter/getter

- (id<ZAIWebRequestProtocol>) objectForKey : (id<NSCopying>) key
{
    return [self.requestCollector objectForKey:key];
}

- (void) setValue : (id<ZAIWebRequestProtocol>) request withKey : (id<NSCopying>) key
{
    [self.requestCollector setObject:request forKey:key];
}

- (void) removeObjectForKey : (id<NSCopying>) key
{
    [self.requestCollector removeObjectForKey:key];
}

- (bool) hasKey : (id<NSCopying>) key
{
    return ([self objectForKey:key] != nil);
}

#pragma mark - iterator

- (NSEnumerator *) keyEnumerator
{
    return [self.requestCollector keyEnumerator];
}

- (void) traversalWithBlock : (visitor) visit
{
    if (!visit)
        return;
    
    for (id<NSCopying> key in [self.requestCollector keyEnumerator])
    {
        id<ZAIWebRequestProtocol> request = [self.requestCollector objectForKey:key];
        visit(key, request);
    }
}


@end
