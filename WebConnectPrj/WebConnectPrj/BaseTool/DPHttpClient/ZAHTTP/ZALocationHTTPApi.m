//
//  ZALocationHTTPApi.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/23.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocationHTTPApi.h"
#import "NSObject+AutoCoding.h"
#import "ZALocationLocalModel.h"
#import <CommonCrypto/CommonCrypto.h>
#import "QNUrlSafeBase64.h"

@implementation ZALocationHTTPRequest
@end

@implementation ZALocationHTTPResponse
@end

@interface ZALocationHTTPApi()
//未能共用STIHTTPSessionManager网络请求中心
@property (nonatomic,strong) STIHTTPSessionManager * sessionManager;

@end
@implementation ZALocationHTTPApi
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZALocationHTTPRequest alloc] initWithEndpoint:@"zadatabase_update_total.db" method:STIHTTPRequestMethodGet];
        self.req.responseClass = [ZALocationHTTPResponse class];
    }
    return self;
}

-(STIHTTPSessionManager *)sessionManager
{
    if(!_sessionManager)
    {
        //        ?ak=petGKNAWHdahKOlzqPcghijZ&callback=renderReverse&output=json&pois=0&location=39.983424,116.322987
    
        
        STIHTTPSessionManager * client = [[STIHTTPSessionManager alloc] init];
        client.requestSerializer = [AFHTTPRequestSerializer serializer];
        client.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.sessionManager = client;
    }
    return _sessionManager;
}

-(instancetype)shareLocationAPI
{
    static ZALocationHTTPApi *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
//        //        &location=39.983424,116.322987
//        NSString * locationUrl = @"https://api.map.baidu.com/geocoder/v2/?ak=petGKNAWHdahKOlzqPcghijZ&callback=renderReverse&output=json&pois=0";
//        
//        _sharedClient = [[STIHTTPRequestManager alloc] initWithBaseURL:[NSURL URLWithString:locationUrl]];
//        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
//        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient = [[ZALocationHTTPApi alloc] init];
    });
    return _sharedClient;
}

-(void)send
{
    if ( self.sessionManager.setup )
    {
        self.sessionManager.setup(nil);
    }
    
    
    //        ?ak=petGKNAWHdahKOlzqPcghijZ&callback=renderReverse&output=json&pois=0&location=39.983424,116.322987

    AFHTTPRequestSerializer * requestSlizer = self.sessionManager.requestSerializer;
//    requestSlizer.timeoutInterval = 5;
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
//    [parameters addEntriesFromDictionary:self.req.parameters];
//    [parameters setValue:@"petGKNAWHdahKOlzqPcghijZ" forKey:@"ak"];
//    [parameters setValue:@"renderReverse" forKey:@"callback"];
//    [parameters setValue:@"json" forKey:@"output"];
//    [parameters setValue:@"0" forKey:@"pois"];
//    [parameters setValue:@"wgs84ll" forKey:@"coordtype"];
    
    NSURL *url = [NSURL URLWithString:@"http://oru29fpwj.bkt.clouddn.com/2017_Auto_Total.xlsx"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *databasePath=[path stringByAppendingPathComponent:@"zadatabase_update_read.db"];
    

    
    NSURLSessionDownloadTask *downloadTask =[self.sessionManager downloadTaskWithRequest:request
                                        progress:nil
                                     destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
    {
//                                         NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//                                         return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:databasePath];
        return documentsDirectoryURL;
                                     }
                               completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
    {
        NSLog(@"File downloaded to: %@", filePath);

        self.resp = [[self.req.responseClass alloc] init];
        self.responseObject = error?@"123":nil;
        if ( self.whenUpdate )
        {
            self.whenUpdate( self.resp, nil );
        }
                                     }];
    
    [downloadTask resume];
}



//启动数据删除
-(void)sendRemoveRequest
{
    if ( self.sessionManager.setup )
    {
        self.sessionManager.setup(nil);
    }

    
//    NSString *token = [[self class] token];
    NSString * encodUrl = [[self class] getUrlEncodeString];
    NSString * url = [NSString stringWithFormat:@"http://rs.qiniu.com/delete/%@",encodUrl];
    NSString * domain = @"rs.qiniu.com";
    
    
//    NSString * key = @"2017_Auto_Total.xlsx";
//    NSString * mime = @"application/octet-stream";

    
    AFHTTPSessionManager * manager = self.sessionManager;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
    NSURL * webURL = [NSURL URLWithString:url];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:webURL];
    NSString * authStr = [[self class] authorizationAccessToken];
    
    [request setValue:domain forHTTPHeaderField:@"Host"];
    [request setValue:authStr forHTTPHeaderField:@"Authorization"];
    [request setValue:nil forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"curl/7.30.0" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    

    NSURLSessionDataTask * uploadTask = [manager dataTaskWithRequest:request
                                                   completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
    {
                                                       NSLog(@"response %@ %@",response,error);
        self.resp = [[self.req.responseClass alloc] init];
        self.responseObject = error?@"123":nil;
        if ( self.whenUpdate )
        {
            self.whenUpdate( self.resp, nil );
        }

                                                   }];
    [uploadTask resume];
}



//启动数据上传
-(void)sendUploadRequest
{
    if ( self.sessionManager.setup )
    {
        self.sessionManager.setup(nil);
    }
    
    
    NSString *token = [[self class] token];
    
    NSString * url = @"http://61.162.231.217:80/";
    url = @"http://upload-z2.qiniu.com";
    NSString * domain = @"upload-z2.qiniu.com";
    
    NSString  * access = [[self class] getAccess];
    NSString * agent = [[self class] getUserAgent:access];
    
    NSString * path = [ZALocationLocalModelManager localSaveTotalDBPath];
    NSData * data = [NSData dataWithContentsOfFile:path];
    //    data = [@"hahaha" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString * key = @"2017_Auto_Total.xlsx";
    NSString * mime = @"application/octet-stream";
    
    NSDictionary *dic = @{
                          @"key" :key,
                          @"token":token
                          };
    
    AFHTTPSessionManager * manager = self.sessionManager;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                   URLString:url
                                                                                  parameters:dic
                                                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                       [formData appendPartWithFileData:data name:@"file" fileName:key mimeType:mime];
                                                                   }
                                                                                       error:nil];
    
    //    request.URL = [NSURL URLWithString:url];
    [request setValue:domain forHTTPHeaderField:@"Host"];
    [request setValue:agent forHTTPHeaderField:@"User-Agent"];
    [request setValue:nil forHTTPHeaderField:@"Accept-Language"];
    
    
    NSURLSessionUploadTask * uploadTask = [manager uploadTaskWithStreamedRequest:request
                                                                        progress:nil
                                                               completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                                   NSLog(@"upload  with file path: %@", path);
                                                                   
                                                                   self.resp = [[self.req.responseClass alloc] init];
                                                                   self.responseObject = error?@"123":nil;
                                                                   if ( self.whenUpdate )
                                                                   {
                                                                       self.whenUpdate( self.resp, nil );
                                                                   }
                                                               }];
    [uploadTask resume];
    
}

+ (NSString*)dictionryToJSONString:(NSMutableDictionary *)dictionary
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}
+ (NSString *)getUserAgent:(NSString *)access
{
    NSString *ak;
    if (access == nil || access.length == 0) {
        ak = @"-";
    } else {
        ak = access;
    }
    NSString * _id = qn_clientId();
    return qn_userAgent(_id, ak);
}

+ (NSString *)getAccess
{
    NSString * token = [[self class] token];
    NSRange range = [token rangeOfString:@":" options:NSCaseInsensitiveSearch];
    return [token substringToIndex:range.location];
}

static NSString *qn_clientId(void) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    NSString *s = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (s == nil) {
        s = @"simulator";
    }
    return s;
#else
    long long now_timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    int r = arc4random() % 1000;
    return [NSString stringWithFormat:@"%lld%u", now_timestamp, r];
#endif
}

static const NSString *kQiniuVersion = @"7.1.5";
static NSString *qn_userAgent(NSString *id, NSString *ak) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    return [NSString stringWithFormat:@"QiniuObject-C/%@ (%@; iOS %@; %@; %@)", kQiniuVersion, [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], id, ak];
#else
    return [NSString stringWithFormat:@"QiniuObject-C/%@ (Mac OS X %@; %@; %@)", kQiniuVersion, [[NSProcessInfo processInfo] operatingSystemVersionString], id, ak];
#endif
}

+(NSString *)getUrlEncodeString
{
    NSString * baseUrlStr  = [NSString stringWithFormat:@"%@:%@",@"localupdatedb",@"2017_Auto_Total.xlsx"];
    NSData * baseData = [baseUrlStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString * encodeURL = [QNUrlSafeBase64 encodeData:baseData];
    return encodeURL;
}


+(NSString *)authorizationAccessToken
{
    NSString * accessKey = @"f9wjb-PpALgdlFb1Q96ru_1GERDuHFTAatCXDJOZ";
    NSString * secretKey = @"haWI3O4XTfNjVed6YS23YS8ev_Yhz9zSf9Ix2d0m";
    
//    accessKey = @"MY_ACCESS_KEY";
//    secretKey = @"MY_SECRET_KEY";
    
    NSString * encodeUrl = [[self class] getUrlEncodeString];
    NSString * signStr = [NSString stringWithFormat:@"/delete/%@\n",encodeUrl];
//    signStr = @"/move/bmV3ZG9jczpmaW5kX21hbi50eHQ=/bmV3ZG9jczpmaW5kLm1hbi50eHQ=\n";
    
    NSString * encodedSign = [[self class] hmacSha1Key:secretKey textData:signStr];
    NSString * accessToken = [NSString stringWithFormat:@"%@:%@",accessKey,encodedSign];
    accessToken = [@"QBox " stringByAppendingString:accessToken];
    
    return accessToken;
}

//AccessKey  以及SecretKey
+ (NSString *)token
{
    return [self makeToken:@"f9wjb-PpALgdlFb1Q96ru_1GERDuHFTAatCXDJOZ" secretKey:@"haWI3O4XTfNjVed6YS23YS8ev_Yhz9zSf9Ix2d0m"];
}

+ (NSString *)hmacSha1Key:(NSString*)key textData:(NSString*)text
{
    const char *cData  = [text cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [QNUrlSafeBase64 encodeData:HMAC];
    return hash;
}

+ (NSString *)makeToken:(NSString *)accessKey secretKey:(NSString *)secretKey
{
    //名字
    NSString *baseName = [self marshal];
    baseName = [baseName stringByReplacingOccurrencesOfString:@" " withString:@""];
    baseName = [baseName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSData   *baseNameData = [baseName dataUsingEncoding:NSUTF8StringEncoding];
    NSString *baseNameBase64 = [QNUrlSafeBase64 encodeData:baseNameData];
    NSString *secretKeyBase64 =  [self hmacSha1Key:secretKey textData:baseNameBase64];
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@",  accessKey, secretKeyBase64, baseNameBase64];
    
    return token;
}

+ (NSString *)marshal
{
    time_t deadline;
    time(&deadline);
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"localupdatedb" forKey:@"scope"];
    NSNumber *escapeNumber = [NSNumber numberWithLongLong:3464706673];
    [dic setObject:escapeNumber forKey:@"deadline"];
    NSString *json = [self dictionryToJSONString:dic];
    return json;
}

-(void)cancel
{
    NSURLSession * httpSession = self.sessionManager.session;
    [httpSession invalidateAndCancel];
}



@end
