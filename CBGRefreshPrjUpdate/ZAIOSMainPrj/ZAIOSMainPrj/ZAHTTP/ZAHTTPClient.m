////
////  ZAHTTPClient.m
////  ZAIOSMainPrj
////
////  Created by J on 15/5/11.
////  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
////
//
#import "ZAHTTPClient.h"
#import "STIHTTPNetwork.h"
#import "Constant.h"
//
////#define BaseUrl @"http://10.139.32.222:9080/za-clare/"
////#define BaseUrl @"http://www.baidu.com"
//
////#define BaseUrl @"https://192.168.0.107:8443"
////#define BaseUrl @"http://125.35.85.250:8080"
////#define BaseUrl @"http://192.168.0.107:80"
//
#if kAPP_Local_Release_URL_Identifier_TAG

//生产环境，使用生产环境打包，注释掉
#define BaseUrl @"https://papa.zhongan.com/za-papa"//2.0新接口地址

#else
////外网，北京
////#define BaseUrl @"https://125.35.85.250:8443" //之前版本地址
//#define BaseUrl @"https://125.35.85.250:8092/za-papa"//2.0新接口地址
//#define BaseUrl @"https://192.168.0.151:8092/za-papa"//2.0新接口地址

#if kAPP_Local_UAT_URL_Identifier_TAG
//UAT环境
#define BaseUrl @"http://120.55.172.37/za-papa/"//2.0新接口地址
#else
//内网//2.0新接口地址  替换需要使用全局查找，统一替换ip部分
#define BaseUrl @"http://10.139.104.74:6080/za-papa/"
#endif

#endif


#define P12Password CFSTR("xiejinbldg!69")

@implementation ZAHTTPClient

+ (AFSecurityPolicy *)customSecurityPolicy
{
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    [policy setAllowInvalidCertificates:YES];
    if(cerData)
        [policy setPinnedCertificates:@[cerData]];
    
    return policy;
}

+ (NSURLCredential *)customCredential
{
    NSString *p12Path = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];
    NSData *p12data = [NSData dataWithContentsOfFile:p12Path];
    if(p12data == nil)
        return nil;
    CFDataRef inP12data = (__bridge CFDataRef)p12data;
    
    CFStringRef password = P12Password;
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef p12Items = nil;
    
    OSStatus result = SecPKCS12Import((CFDataRef)inP12data, optionsDictionary, &p12Items);
    
    NSURLCredential *credential = nil;
    if(result == noErr) {
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(p12Items, 0);
        SecIdentityRef identityApp =(SecIdentityRef)CFDictionaryGetValue(identityDict,kSecImportItemIdentity);
        
        SecCertificateRef certRef;
        SecIdentityCopyCertificate(identityApp, &certRef);
        
        SecCertificateRef certArray[1] = { certRef };
        CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
        CFRelease(certRef);
        
        credential = [NSURLCredential credentialWithIdentity:identityApp certificates:(__bridge NSArray *)myCerts persistence:NSURLCredentialPersistencePermanent];
        CFRelease(myCerts);
    }
    CFRelease(optionsDictionary);
    CFRelease(p12Items);
    return credential;
}

@end


@interface ZAHTTPSessionManager()
@property (nonatomic,strong) NSArray * keyWords;
@end
@implementation ZAHTTPSessionManager

//第二版关键字  手电筒 防身术  防盗 人身意外保险 护花使者 汽车保险 老人走失 公车性骚扰

+ (void)load
{
    if([NSURLSession class] != nil)
    {
        ZAHTTPSessionManager *client = [self sharedClient];
        [STIHTTPApi setGlobalHTTPSessionManager:client];
//        client.securityPolicy = [ZAHTTPClient customSecurityPolicy];
//        if([ZAHTTPClient customCredential])
//        {
//            [client setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *credential)
//            {
//                *credential = [ZAHTTPClient customCredential];
//                return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
//            }];
//        }
    }
}

+ (instancetype)sharedClient {
    static ZAHTTPSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ZAHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
        NSLog(@"BaseUrl %@",BaseUrl);
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSString * key = @"手电筒 防身术 防盗 人身意外保险 护花使者 汽车保险 老人走失 公车性骚扰";
        _sharedClient.keyWords = [key componentsSeparatedByString:@" "];
    });
    return _sharedClient;
}

@end

@implementation ZAHTTPRequestManager

+ (void)load
{
    if([NSURLSession class] == nil)
    {
        [STIHTTPApi setGlobalHTTPRequestManager:[self sharedClient]];
    }
}

+ (instancetype)sharedClient {
    static ZAHTTPRequestManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ZAHTTPRequestManager alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
//        _sharedClient.securityPolicy = [ZAHTTPClient customSecurityPolicy];
//        _sharedClient.credential = [ZAHTTPClient customCredential];
        
    });
    return _sharedClient;
}

@end
