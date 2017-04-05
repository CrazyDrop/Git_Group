//
//  NTConnectSepcialClient.h
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
//特殊网络请求管理器
//主要进行测试网络请求
#import "NTConnectClient.h"

@interface NTConnectSepcialClient : NTConnectClient

+(instancetype)sharedNTConnectSepcialClient;



//网络请求，获取网络返回即可
-(void)specialRequestWithBasicRequest:(NTBasicRequest *)basic
                          andEndBlock:(void(^)(id responseData,NSError * error))endRequestBlock;



+(id)checkResponseDataWithJSONKitAndCustomReplace:(id)data;

@end
