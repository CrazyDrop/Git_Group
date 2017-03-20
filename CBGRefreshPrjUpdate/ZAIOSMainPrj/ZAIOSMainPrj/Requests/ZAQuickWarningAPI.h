//
//  ZAQuickWarningAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface ZAQuickWarningModelResponseDetail : NSObject
@property (nonatomic,strong) NSString * id;
@end

@interface ZAQuickWarningRequest : ZAHTTPRequest

@property (nonatomic,copy) NSString * scene;
@property (nonatomic,copy) NSString * duration;

@end

@interface ZAQuickWarningResponse : ZAHTTPResponse
@property (nonatomic, strong) ZAQuickWarningModelResponseDetail * returnData;
@end


@interface ZAQuickWarningAPI : ZAHTTPApi

@property (nonatomic, strong) ZAQuickWarningRequest *req;
@property (nonatomic, strong) ZAQuickWarningResponse *resp;

@end
