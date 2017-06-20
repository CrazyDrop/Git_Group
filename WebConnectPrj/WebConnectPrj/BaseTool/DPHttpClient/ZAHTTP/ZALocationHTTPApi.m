//
//  ZALocationHTTPApi.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/23.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocationHTTPApi.h"
#import "NSObject+AutoCoding.h"
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
    
    NSURL *url = [NSURL URLWithString:@"http://oru29fpwj.bkt.clouddn.com/zadatabase_update_total.db"];
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

-(void)cancel
{
    NSURLSession * httpSession = self.sessionManager.session;
    [httpSession invalidateAndCancel];
}



@end
