//
//  GetMessageModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface GetMessageModelRequest : ZAHTTPRequest
@property (nonatomic,copy) NSString * mobile;

@end

@interface GetMessageModelResponse : ZAHTTPResponse
@end



@interface GetMessageModelAPI : ZAHTTPApi

@property (nonatomic, strong) GetMessageModelRequest *req;
@property (nonatomic, strong) GetMessageModelResponse *resp;

@end

