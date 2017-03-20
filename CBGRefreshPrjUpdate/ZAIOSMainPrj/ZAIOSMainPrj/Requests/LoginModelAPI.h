//
//  LoginModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface LoginModelResponseDetail : NSObject
@property (nonatomic,copy) NSString * token;
@end

@interface LoginModelRequest : ZAHTTPRequest
@property (nonatomic,copy) NSString * mobile;
@property (nonatomic,copy) NSString * vcode;
@end

@interface LoginModelResponse : ZAHTTPResponse
@property (nonatomic, strong) PaPaUserInfoModel * returnData;
@end



@interface LoginModelAPI : ZAHTTPApi

@property (nonatomic, strong) LoginModelRequest *req;
@property (nonatomic, strong) LoginModelResponse *resp;

@end

