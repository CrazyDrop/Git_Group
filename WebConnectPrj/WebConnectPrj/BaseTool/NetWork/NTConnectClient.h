//
//  NTConnectClient.h
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTBasicRequest.h"
#import "BlockConstant.h"
#import "AFHTTPRequestOperationManager.h"

//网络请求管理器
//正式发布时，原则上所有的网络请求均通过此管理器调用
@interface NTConnectClient : NSObject
{
    AFHTTPRequestOperationManager * manager ;

}

+(instancetype)sharedNTConnectClient;

//如果有多个requestid相同的请求，那么，同时取消
//认为requestId是特殊的请求参数，区别处理，以便快速取消
//由于此处实现方式不区分请求内容，仅以requestId为区分，尽可能不同界面使用不同requestid
-(void)cancelWebRequestWithRequestIDString:(NSString *)str;


//网络请求，获取网络返回即可
-(void)requestWithBasicRequest:(NTBasicRequest *)basic
            andEndBlock:(void(^)(id responseData,NSError * error))endRequestBlock;



//网络请求，需要解析(使用此方法，可以将数据解析放到子线程处理)
//checkBlock如果需要使用特殊资源，要设置lock
-(void)requestModelDataArrayWithBasicRequest:(NTBasicRequest *)basic
                          checkResponseBlock:(CheckResponseDataBlock)checkBlock
                                 andEndBlock:(void(^)(BOOL netWorkType,NSArray * array))endRequestBlock;


//网络请求，需要解析，但是不需要放置到子线程处理
-(void)requestSmallModelDataArrayWithBasicRequest:(NTBasicRequest *)basic
                          checkResponseBlock:(CheckResponseDataBlock)checkBlock
                                 andEndBlock:(void(^)(BOOL netWorkType,NSArray * array))endRequestBlock;



//数据下载进度相关的请求
-(void)requestBigFileDataWithBasicRequest:(NTBasicRequest *)basic
                    downloadProgressBlock:(DownloadProgressBlock)download
                              andEndBlock:(void(^)(id responseData,NSError * error))endRequestBlock;



//数据长传进度相关的请求
-(void)uploadBigFileDataWithBasicRequest:(NTBasicRequest *)basic
                    uploadProgressBlock:(DownloadProgressBlock)upload
                              andEndBlock:(void(^)(id responseData,NSError * error))endRequestBlock;


////专门针对需要Authorization认证的实现
////网络请求，获取网络返回即可
//-(void)requestWithAuthorizationWithBasicRequest:(NTBasicRequest *)basic
//                   andEndBlock:(void(^)(id responseData,NSError * error))endRequestBlock;

@end
