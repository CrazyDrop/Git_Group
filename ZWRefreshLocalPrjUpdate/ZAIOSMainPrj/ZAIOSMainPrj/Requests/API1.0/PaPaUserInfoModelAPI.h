//
//  PaPaUserInfoModelApi.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface PaPaUserInfoModelRequest : ZAHTTPRequest

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *mobile;

@end

@interface PaPaUserInfoModelResponse : ZAHTTPResponse
//@property (nonatomic, copy) NSString *token;
@end



@interface PaPaUserInfoModelAPI : ZAHTTPApi
@property (nonatomic, strong) PaPaUserInfoModelRequest *req;
@property (nonatomic, strong) PaPaUserInfoModelResponse *resp;

@end
