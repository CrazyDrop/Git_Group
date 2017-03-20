//
//  ZAHTTPRequest.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/11.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPRequest.h"
#import "RSACryptor.h"
#import "OpenSSLRSACryptor.h"

#define secretKey @"app.ZhongAn"

@implementation ZAHTTPRequest

@synthesize endpoint = _endpoint;

+ (NSString *)createSignByPhoneNum:(NSString *)phoneNum
{
    NSString *sign = secretKey;
    sign = [sign stringByAppendingString:phoneNum];
    NSDateFormatter *formatter = [DZUtils sharedDateFormatter];
    [formatter setDateFormat:@"yyyyMMdd"];
    sign = [sign stringByAppendingString:[formatter stringFromDate:[NSDate date]]];
    sign = [sign stringByAppendingString:secretKey];
    return [sign MD5String];
}

- (NSString *)toJsonString:(NSDictionary *)dict sorting:(BOOL)sort
{
    NSArray *keys = [NSArray arrayWithArray:[dict allKeys]];
    NSArray *sortedKeys = keys;
    if(sort)
    {
        sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
        }];
    }
    NSMutableString *jsonString = [[NSMutableString alloc] init];
    [jsonString appendString:@"{"];
    for (NSString *key in sortedKeys) {
        [jsonString appendFormat:@"\"%@\"",key];
        [jsonString appendString:@";"];
        [jsonString appendFormat:@"\"%@\"",[dict objectForKey:key]];
        [jsonString appendString:@","];
    }
    if([jsonString length] > 2)
    {
        [jsonString deleteCharactersInRange:NSMakeRange([jsonString length] -1, 1)];
    }
    [jsonString appendString:@"}"];
    return jsonString;
}

- (instancetype)initWithEndpoint:(NSString *)endpoint method:(STIHTTPRequestMethod)method
{
    self = [super initWithEndpoint:endpoint method:method];
    if (self) {
        _endpoint = endpoint;
    }
    return self;
}

- (NSString *)endpoint
{
    if ( [_endpoint hasPrefix:@"/"] ) {
        _endpoint = [_endpoint substringFromIndex:1];
    }
    
    if([_endpoint hasSuffix:@"/"])
    {
        _endpoint = [_endpoint substringWithRange:NSMakeRange(0, _endpoint.length-1)];
    }
    
//    NSString *sign = [self createSign];
//    NSString *version = [DZUtils currentAppBundleShortVersion];
//    int type = 1;
    
//    _endpoint = [_endpoint stringByAppendingFormat:@"/v/%@/t/%d?sign=%@",version,type,sign];
    
    return _endpoint;
}

//- (NSDictionary *)parameters
//{
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    
//    if(self.serviceName)
//        params[@"serviceName"] = self.serviceName;
//    
//    return params;
//}

- (NSString *)createSign
{
    return @"";
}

@end
