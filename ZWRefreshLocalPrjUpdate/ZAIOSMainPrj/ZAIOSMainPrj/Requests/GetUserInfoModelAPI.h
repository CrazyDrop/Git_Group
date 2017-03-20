//
//  GetUserInfoModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"
@class PaPaUserInfoModel;
@interface GetUserInfoModelRequest : ZAHTTPRequest


@end

@interface GetUserInfoModelResponse : ZAHTTPResponse
@property (nonatomic, strong) PaPaUserInfoModel * returnData;
@end



@interface GetUserInfoModelAPI : ZAHTTPApi

@property (nonatomic, strong) GetUserInfoModelRequest *req;
@property (nonatomic, strong) GetUserInfoModelResponse *resp;

@end
