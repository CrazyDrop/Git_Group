//
//  ZAStartLogAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/13.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface ZAStartLogRequest : ZAHTTPRequest
@end

@interface ZAStartLogResponse : ZAHTTPResponse
@end


@interface ZAStartLogAPI : ZAHTTPApi

@property (nonatomic, strong) ZAStartLogRequest *req;
@property (nonatomic, strong) ZAStartLogResponse *resp;

@end
