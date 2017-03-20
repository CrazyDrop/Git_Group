//
//  ZALocationHTTPApi.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/23.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZALocationHTTPRequest : ZAHTTPRequest
@property (nonatomic,copy) NSString * location;
@end

@interface ZALocationHTTPResponse : ZAHTTPResponse


@end


//位置信息网络请求api，
//进行位置信息的api请求、解析

//专为城市请求的API
@interface ZALocationHTTPApi : ZAHTTPApi


//-(instancetype)shareLocationAPI;


//启动数据发送
-(void)send;

//取消
-(void)cancel;

@property (nonatomic, strong) ZALocationHTTPRequest *req;
@property (nonatomic, strong) ZALocationHTTPResponse *resp;


@end

