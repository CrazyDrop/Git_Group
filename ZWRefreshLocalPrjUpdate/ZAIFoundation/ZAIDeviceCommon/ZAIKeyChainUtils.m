//
//  ZAOKeyChainUtils.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/15.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIKeyChainUtils.h"

@implementation ZAIKeyChainUtils

+(NSString *)commonStaticAppDeviceId
{
    NSString * pwd =  [SFHFKeychainUtils getPasswordForUsername:@"storeDeviceUDID" andServiceName:@"zhongan.app" error:nil];
    if (!pwd)
    {
        pwd = [[UIDevice currentDevice].identifierForVendor UUIDString];
        
        NSError * error = nil;
        [SFHFKeychainUtils storeUsername:@"storeDeviceUDID" andPassword:pwd forServiceName:@"app" updateExisting:YES error:&error];
        
    }
    return pwd;
}

@end
