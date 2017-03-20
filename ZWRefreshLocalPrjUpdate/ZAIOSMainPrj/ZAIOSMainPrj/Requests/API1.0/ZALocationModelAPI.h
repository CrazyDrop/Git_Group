//
//  ZALocationModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"


@interface ZALocationModelRequest : ZAHTTPRequest

@property (nonatomic, copy) NSString *longtitude;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *altitude;
@property (nonatomic, copy) NSString *scene;
@property (nonatomic, copy) NSString *priority;

@end

@interface ZALocationModelResponse : ZAHTTPResponse
//@property (nonatomic, copy) NSString *token;
@end

@interface ZALocationModelAPI : ZAHTTPApi
@property (nonatomic, strong) ZALocationModelRequest *req;
@property (nonatomic, strong) ZALocationModelResponse *resp;

@end