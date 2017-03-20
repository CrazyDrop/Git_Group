//
//  WarningModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"
//@interface WarningModelResponseDetail : NSObject
//@property (nonatomic,strong) NSString * lock;
//@end

@interface WarningModelRequest : ZAHTTPRequest

@property (nonatomic,copy) NSString * scene;

@end
@interface WarningModelResponse : ZAHTTPResponse
@property (nonatomic, strong) PaPaUserInfoModel * returnData;
@end

@interface WarningModelAPI : ZAHTTPApi

//先设定id,后设定type   否则作为新增
@property (nonatomic,copy) NSString * timingId;

@property (nonatomic,assign) WarningModelTYPE type;

@property (nonatomic, strong) WarningModelRequest *req;
@property (nonatomic, strong) WarningModelResponse *resp;

@end
