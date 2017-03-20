//
//  ZAUploadModelAPI.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/9.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAUploadModelAPI.h"
#import "SFHFKeychainUtils.h"
#import "NSObject+AutoCoding.h"

@implementation ZAUploadModelRequest
@synthesize fileData;
@synthesize filePath;
@synthesize fileName;
@end

@implementation ZAUploadModelResponse
@end

@implementation ZAUploadModelAPI
@synthesize req;
@synthesize resp;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.req = [[ZAUploadModelRequest alloc] initWithEndpoint:@"papa/warning/uploadVoice" method:STIHTTPRequestMethodPost];
        self.req.responseClass = [ZAUploadModelResponse class];
    }
    return self;
}
- (instancetype)initWithDuration:(NSString *)duration
{
    self = [self init];
    if(self)
    {
        if(duration)
        {
            NSString * total = [NSString stringWithFormat:@"papa/warning/uploadVoice/%@",duration];
            self.req = [[ZAUploadModelRequest alloc] initWithEndpoint:total method:STIHTTPRequestMethodPost];
            self.req.responseClass = [ZAUploadModelResponse class];

        }
    }
    return self;
}
-(void)send
{
    
    NSString * token = [DZUtils currentLoginToken];
    
    if(token)
    {
        if(self.HTTPRequestManager)
            [self.HTTPRequestManager.requestSerializer setValue:token forHTTPHeaderField:@"Token"];
        else if(self.HTTPSessionManager)
            [self.HTTPSessionManager.requestSerializer setValue:token forHTTPHeaderField:@"Token"];
    }
    
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *platform = [DZUtils platformString];
    NSString *deviceId = [DZUtils currentDeviceIdentifer];
    NSString *deviceIdCheck = [SFHFKeychainUtils commonStaticAppDeviceId];
    
    NSString *sign = [(ZAHTTPRequest *)self.req createSign];
    NSString *version = [DZUtils currentAppBundleShortVersion];
    NSString *type = @"4";
    
    AFHTTPRequestSerializer * requestSlizer = self.HTTPRequestManager.requestSerializer;
    if(!requestSlizer) requestSlizer = self.HTTPSessionManager.requestSerializer;
    
    if(sign)
    {
        [requestSlizer setValue:sign forHTTPHeaderField:@"sign"];
    }
    
    [requestSlizer setValue:version forHTTPHeaderField:@"Client-Version"];
    [requestSlizer setValue:type forHTTPHeaderField:@"Client-Type"];
    [requestSlizer setValue:deviceId forHTTPHeaderField:@"Device-ID"];
    
    [requestSlizer setValue:osVersion forHTTPHeaderField:@"OS-Version"];
    [requestSlizer setValue:platform forHTTPHeaderField:@"Device-Type"];
    
    [requestSlizer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSlizer setValue:@"application/json; charset=utf8" forHTTPHeaderField:@"Content-Type"];
    requestSlizer.timeoutInterval = self.timeoutInterval;
    
    
    
    if ( self.HTTPSessionManager.setup ) {
        self.HTTPSessionManager.setup(nil);
    }
    
    NSString * URLString = self.req.endpoint;
    
    NSString * url = [[NSURL URLWithString:URLString relativeToURL:self.HTTPSessionManager.baseURL] absoluteString];
    
    NSDictionary * totalParameters = self.req.parameters;
    NSMutableURLRequest * request = [requestSlizer
                                     multipartFormRequestWithMethod:STIHTTPRequestMethodString(self.req.method)
                                     URLString:url
                                     parameters:totalParameters
                                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        
        
        NSData *fileData=[totalParameters valueForKey:@"fileData"];
        if(!fileData || [fileData length]==0)
        {
            NSString *filePath=[totalParameters valueForKey:@"filePath"];
            if(filePath && [filePath length]>0)
            {
                fileData = [NSData dataWithContentsOfFile:filePath];
            }
        }
        
        NSString *fileName=[totalParameters valueForKey:@"fileName"];
        
        [formData appendPartWithFileData:fileData name:fileName fileName:@"file" mimeType:@"application/octet-stream"];

    }
                                     error:nil];

    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask =[self.HTTPSessionManager dataTaskWithRequest:request
                                          completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                {
                    if(error)
                    {
                        [self.HTTPSessionManager handleError:error responseObject:responseObject task:dataTask failureBlock:self.whenUpdate];
                        
                    }else{
                        
                        self.resp = [self.req.responseClass ac_objectWithAny:responseObject];
                        self.responseObject = responseObject;
                        if ( self.whenUpdate ) {
                            self.whenUpdate( self.resp, nil );
                        }
                        
                    }
                    
                }];
    
    [dataTask resume];
    
    NSLog(@"deviceId:%@ deviceIdCheck:%@ web Parameter:%@  token:%@",deviceId,deviceIdCheck,self.req.parameters,token);
    
}


@end