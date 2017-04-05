//
//  NTConnectClient.m
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "NTConnectClient.h"
#import "AFURLSessionManager.h"
#import "JSONKit.h"
@interface NTConnectClient()
{
}
//数据解析处理队列
@property (nonatomic,strong) dispatch_queue_t checkQueue;
@property (nonatomic,strong) NSMutableDictionary * operationDic;
@end

@implementation NTConnectClient

-(id)init
{
    self = [super init];
    if (self)
    {
        NSURL * url = nil;
//        [NSURL URLWithString:DEFAULT_HTTP_SERVER_HOST];
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        _checkQueue = dispatch_queue_create("com.NTConnectClient.CheckResponseBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        self.operationDic = [NSMutableDictionary dictionary];
    }
    return self;
}

//方便快速调用
+(instancetype)sharedNTConnectClient
{
    static NTConnectClient *  _SharedNTConnectClient = nil;
    if (!_SharedNTConnectClient)
    {
        _SharedNTConnectClient = [[NTConnectClient alloc] init];
    }
    return _SharedNTConnectClient;
}


//如果有多个requestid相同的请求，那么，同时取消
//认为requestId是特殊的请求参数，区别处理，以便快速取消
-(void)cancelWebRequestWithRequestIDString:(NSString *)requestid
{
    @synchronized(self.operationDic)
    {
        NSMutableArray * array = [self.operationDic valueForKey:requestid];
        for (AFURLConnectionOperation * eve in array)
        {
            [eve cancel];
        }
        [self.operationDic removeObjectForKey:requestid];
    }
}
//网络请求，获取网络返回即可
-(void)requestWithBasicRequest:(NTBasicRequest *)basic
                   andEndBlock:(void(^)(id responseData,NSError * error))endRequestBlock
{
    [self basicRequestWithRequest:basic
            downloadProgressBlock:nil
              uploadProgressBlock:nil
                      andEndBlock:endRequestBlock];
}


//网络请求，需要解析(使用此方法，可以将数据解析放到子线程处理)
//checkBlock如果需要使用特殊资源，要设置lock
-(void)requestModelDataArrayWithBasicRequest:(NTBasicRequest *)basic
                          checkResponseBlock:(CheckResponseDataBlock)checkBlock
                                 andEndBlock:(void(^)(BOOL netWorkType,NSArray * array))endRequestBlock
{
    
    [self basicRequestWithRequest:basic
            downloadProgressBlock:nil
              uploadProgressBlock:nil
                      andEndBlock:^(id responseData,NSError * error){
                          if (error)
                          {
                              endRequestBlock(NO,nil);
                              return ;
                          }
                          //此处区别对待，对于简单的解析可以不放到子线程
                          dispatch_async(_checkQueue, ^{
                              //移动到线程处理
                              NSArray * array = nil;
                              if (checkBlock)
                              {
                                  array = checkBlock(responseData);
                              }
                              
                              dispatch_async(dispatch_get_main_queue(),^(){
                                   endRequestBlock(YES,array);
                              });
                          });
                          
                      }];
}


-(void)requestSmallModelDataArrayWithBasicRequest:(NTBasicRequest *)basic
                               checkResponseBlock:(CheckResponseDataBlock)checkBlock
                                      andEndBlock:(void(^)(BOOL netWorkType,NSArray * array))endRequestBlock
{
    [self basicRequestWithRequest:basic
            downloadProgressBlock:nil
              uploadProgressBlock:nil
                      andEndBlock:^(id responseData,NSError * error){
                          if (error)
                          {
                              endRequestBlock(NO,nil);
                              return ;
                          }
                          //此处区别对待，对于简单的解析可以不放到子线程
//                          dispatch_async(_checkQueue, ^{
                              //移动到线程处理
                              NSArray * array = nil;
                              if (checkBlock)
                              {
                                  array = checkBlock(responseData);
                              }
                              
                              
//                              dispatch_async(dispatch_get_main_queue(),^(){
                                  endRequestBlock(YES,array);
//                              });
//                          });
     
                      }];
}

//数据下载进度相关的请求
-(void)requestBigFileDataWithBasicRequest:(NTBasicRequest *)basic
                    downloadProgressBlock:(DownloadProgressBlock)download
                              andEndBlock:(void(^)(id responseData,NSError * error))endRequestBlock
{
    [self basicRequestWithRequest:basic
            downloadProgressBlock:download
              uploadProgressBlock:nil
                      andEndBlock:endRequestBlock];
    
    
}



//数据长传进度相关的请求
-(void)uploadBigFileDataWithBasicRequest:(NTBasicRequest *)basic
                     uploadProgressBlock:(DownloadProgressBlock)upload
                             andEndBlock:(void(^)(id responseData,NSError * error))endRequestBlock
{
    [self basicRequestWithRequest:basic
            downloadProgressBlock:nil
              uploadProgressBlock:upload
                      andEndBlock:endRequestBlock];
    
}
////专门针对需要Authorization认证的实现
////网络请求，获取网络返回即可
//-(void)requestWithAuthorizationWithBasicRequest:(NTBasicRequest *)basic
//                                    andEndBlock:(void(^)(id responseData,NSError * error))endRequestBlock
//{
//    NSString * name = nil;
//    NSString * pwd = nil;
//    
//    [manager ]
//    
//}
#pragma mark -privateMethods

-(void)finishRequestWithOperaion:(AFURLConnectionOperation *)operation andRequestId:(NSString *)requestid
{
    //移除
    @synchronized(self.operationDic){
        NSMutableArray * array = [self.operationDic valueForKey:requestid];
        [array removeObject:operation];
    }
}
-(void)startRequestWithOperation:(AFURLConnectionOperation *)operation andRequestId:(NSString *)requestid
{
    //新增
    @synchronized(self.operationDic)
    {
        NSMutableArray * array = [self.operationDic valueForKey:requestid];
        if (!array)
        {
            array = [NSMutableArray array];
        }
        [array addObject:operation];
        [self.operationDic setValue:array forKey:requestid];
    }
}

//统一调用的请求
-(void)basicRequestWithRequest:(NTBasicRequest *)basic
         downloadProgressBlock:(DownloadProgressBlock )downloadBlock
           uploadProgressBlock:(DownloadProgressBlock)uploadBlock
                   andEndBlock:(void(^)(id responseData,NSError * error))endBlock
{
    
    if (!basic.requestid||[basic.requestid intValue]<=0)
    {
        return;
    }
    
    NSString * tagId = basic.requestid;
    [basic setValue:tagId forKey:@"rd"];
    NSString * url = basic.requestUrlStr;
    
    NSDictionary * dataDic = [basic currentDataDic];
    if (basic.needAuthorization)
    {
        //针对认证的特殊处理
        NSString * name = [dataDic valueForKey:@"name"];
        NSString * pass = [dataDic valueForKey:@"pass"];
        
        if (!name) {
            name=@"";
        }
        if (!pass) {
            pass=@"";
        }
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:name password:pass];
        NSMutableDictionary * postDic = [NSMutableDictionary dictionaryWithDictionary:dataDic];
//        [postDic removeObjectForKey:@"name"];
//        [postDic removeObjectForKey:@"pass"];
        dataDic = postDic;
    }else{
        [manager.requestSerializer clearAuthorizationHeader];
    }
    
    NSString * paragramStr = [dataDic JSONString];
    NSLog(@"start RequestUrl:%@ paragram:%@",url,paragramStr);
    __weak NTConnectClient * weakClient = self;
    AFHTTPRequestOperation * requestOperation = [manager  POST:url
                                                   parameters:dataDic
                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                          NSString * str = [responseObject JSONString];
                                                          NSLog(@"End RequestUrl:%@ response data:%@",paragramStr,[str length]>100?[str substringToIndex:100]:str);
                                                          endBlock(responseObject,nil);
                                                          [weakClient finishRequestWithOperaion:operation andRequestId:tagId];
                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                          NSLog(@"End RequestUrl:%@ response error:%@",paragramStr,error);
                                                          endBlock(nil,error);
                                                          [weakClient finishRequestWithOperaion:operation andRequestId:tagId];
                                                      }];
    
    [self startRequestWithOperation:requestOperation
                       andRequestId:tagId];
    
    [requestOperation setUploadProgressBlock:uploadBlock];
    [requestOperation setDownloadProgressBlock:downloadBlock];
    
}
#pragma mark -

@end
