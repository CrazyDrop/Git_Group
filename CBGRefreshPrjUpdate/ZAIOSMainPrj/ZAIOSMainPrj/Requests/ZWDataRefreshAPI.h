//
//  ZWDataRefreshAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/7.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"
#import "ZWDataDetailModel.h"

@interface ZWDataRefreshHTTPRequest : ZAHTTPRequest
@end

@interface ZWDataRefreshHTTPResponse : ZAHTTPResponse


@end


//位置信息网络请求api，
//进行位置信息的api请求、解析

//专为城市请求的API
@interface ZWDataRefreshHTTPApi : ZAHTTPApi


//-(instancetype)shareLocationAPI;
@property (nonatomic,assign) BOOL nextPage;


//启动数据发送
-(void)send;

//取消
-(void)cancel;

@property (nonatomic, strong) ZWDataRefreshHTTPRequest *req;
@property (nonatomic, strong) ZWDataRefreshHTTPResponse *resp;


@end