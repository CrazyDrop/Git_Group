//
//  GetContactsModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"
@class ContactsModel;
@interface GetContactsModelRequest : ZAHTTPRequest


@end

@interface GetContactsModelResponse : ZAHTTPResponse
@property (nonatomic, strong) NSArray<ContactsModel> * returnData;
@end



@interface GetContactsModelAPI : ZAHTTPApi

@property (nonatomic, strong) GetContactsModelRequest *req;
@property (nonatomic, strong) GetContactsModelResponse *resp;

@end
