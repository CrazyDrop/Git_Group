//
//  RegisterModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface RegisterModelResponseDetail : NSObject
@property (nonatomic,copy) NSString * token;
@end



@interface RegisterModelRequest : ZAHTTPRequest
//@property (nonatomic,copy) NSString * username;
//@property (nonatomic,copy) NSString * password;
@property (nonatomic,copy) NSString * mobile;
@property (nonatomic,copy) NSString * vcode;
@end

@interface RegisterModelResponse : ZAHTTPResponse
@property (nonatomic, strong) PaPaUserInfoModel * returnData;
@end



@interface RegisterModelAPI : ZAHTTPApi

@property (nonatomic, strong) RegisterModelRequest *req;
@property (nonatomic, strong) RegisterModelResponse *resp;

@end
