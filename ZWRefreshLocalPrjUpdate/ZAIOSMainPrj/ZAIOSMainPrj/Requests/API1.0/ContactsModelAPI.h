//
//  ContactsModelApi.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface ContactsModelRequest : ZAHTTPRequest

@property (nonatomic, copy) NSString *contactName;
@property (nonatomic, copy) NSString *contactMobile;
@property (nonatomic, copy) NSString *relation;
@property (nonatomic, copy) NSString *contactPwd;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *isContacted;  //0：未通知，1：已通知

@property (nonatomic, copy) NSString *isDeleted;    //0：有效，1：无效

@end

@interface ContactsModelResponse : ZAHTTPResponse

@end

@interface ContactsModelAPI : ZAHTTPApi

//先设定id,后设定type   否则作为新增
@property (nonatomic,copy) NSString * contanctId;

@property (nonatomic, strong) ContactsModelRequest *req;
@property (nonatomic, strong) ContactsModelResponse *resp;

@end

