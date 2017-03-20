//
//  GetCheckNumAPI.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/11.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface GetCheckNumReqeust : ZAHTTPRequest
@property (nonatomic, copy) NSString *phoneNo;
@property (nonatomic, assign) NSInteger type;
@end

@interface GetCheckNumResponse : ZAHTTPResponse
@end

@interface GetCheckNumAPI : ZAHTTPApi

@property (nonatomic, strong) GetCheckNumReqeust *req;
@property (nonatomic, strong) GetCheckNumResponse *resp;

@end
