//
//  LogoutModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface LogoutModelRequest : ZAHTTPRequest
@end

@interface LogoutModelResponse : ZAHTTPResponse
@end



@interface LogoutModelAPI : ZAHTTPApi

@property (nonatomic, strong) LogoutModelRequest *req;
@property (nonatomic, strong) LogoutModelResponse *resp;

@end
