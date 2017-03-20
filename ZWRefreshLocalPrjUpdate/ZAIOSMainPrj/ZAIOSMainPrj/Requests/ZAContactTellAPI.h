//
//  ZAContactTellAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/17.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface ZAContactTellRequest : ZAHTTPRequest

@end

@interface ZAContactTellResponse : ZAHTTPResponse
@end



@interface ZAContactTellAPI : ZAHTTPApi

- (instancetype)initWithContactedId:(NSString *)idStr;

@property (nonatomic, strong) ZAContactTellRequest *req;
@property (nonatomic, strong) ZAContactTellResponse *resp;

@end
