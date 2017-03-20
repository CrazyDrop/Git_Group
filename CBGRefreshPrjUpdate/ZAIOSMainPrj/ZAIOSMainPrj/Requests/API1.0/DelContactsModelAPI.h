//
//  DelContactsModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface DelContactsModelRequest : ZAHTTPRequest

@property (nonatomic, copy) NSString *id;

@end

@interface DelContactsModelResponse : ZAHTTPResponse

@end



@interface DelContactsModelAPI : ZAHTTPApi
//先设定id,后设定type   否则无法删除
@property (nonatomic,copy) NSString * contanctId;

@property (nonatomic, strong) DelContactsModelRequest *req;
@property (nonatomic, strong) DelContactsModelResponse *resp;

@end
