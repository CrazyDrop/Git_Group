//
//  ZALocationsModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface ZALocationsModelRequest : ZAHTTPRequest

@property (nonatomic,copy) NSArray * locationList;

@end

@interface ZALocationsModelResponse : ZAHTTPResponse
//@property (nonatomic, copy) NSString *token;
@end

@interface ZALocationsModelAPI : ZAHTTPApi
@property (nonatomic, strong) ZALocationsModelRequest *req;
@property (nonatomic, strong) ZALocationsModelResponse *resp;

@end
