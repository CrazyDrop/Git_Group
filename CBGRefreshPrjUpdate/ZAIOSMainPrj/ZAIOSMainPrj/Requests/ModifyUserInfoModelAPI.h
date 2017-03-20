//
//  ModifyUserInfoModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface ModifyUserInfoModelRequest : ZAHTTPRequest
@property (nonatomic,copy) NSString * username;
@property (nonatomic,copy) NSString * password;
@end

@interface ModifyUserInfoModelResponse : ZAHTTPResponse
@end



@interface ModifyUserInfoModelAPI : ZAHTTPApi

@property (nonatomic, strong) ModifyUserInfoModelRequest *req;
@property (nonatomic, strong) ModifyUserInfoModelResponse *resp;

@end
