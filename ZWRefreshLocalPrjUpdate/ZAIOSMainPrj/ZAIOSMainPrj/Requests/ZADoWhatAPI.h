//
//  ZADoWhatAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/6.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface ZADoWhatModelRequest : ZAHTTPRequest
@property (nonatomic,copy) NSString * warningId;
@property (nonatomic,copy) NSString * whattodo;
@end

@interface ZADoWhatModelResponse : ZAHTTPResponse
@end



@interface ZADoWhatAPI : ZAHTTPApi

@property (nonatomic, strong) ZADoWhatModelRequest *req;
@property (nonatomic, strong) ZADoWhatModelResponse *resp;

@end