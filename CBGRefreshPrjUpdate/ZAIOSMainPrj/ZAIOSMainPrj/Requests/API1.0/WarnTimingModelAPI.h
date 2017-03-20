//
//  WarnTimingModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"
@interface WarnTimingModelResponseDetail : NSObject
@property (nonatomic,strong) NSString * id;
@end

@interface WarnTimingModelRequest : ZAHTTPRequest

@property (nonatomic,copy) NSString * scene;
@property (nonatomic,copy) NSString * duration;

@end

@interface WarnTimingModelResponse : ZAHTTPResponse
//@property (nonatomic, strong) NSArray<ContactsModel> * returnData;
@property (nonatomic, strong) WarnTimingModelResponseDetail * returnData;
@end

@interface WarnTimingModelAPI : ZAHTTPApi

@property (nonatomic, strong) WarnTimingModelRequest *req;
@property (nonatomic, strong) WarnTimingModelResponse *resp;

@end
