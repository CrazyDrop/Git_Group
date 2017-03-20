//
//  ZAHTTPRequest.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/11.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "STIHTTPNetwork.h"

@protocol ZAHTTPRequestSendDataProcessor <NSObject>

- (NSString *)createSign;

@end

@interface ZAHTTPRequest : STIHTTPRequest<ZAHTTPRequestSendDataProcessor>

+ (NSString *)createSignByPhoneNum:(NSString *)phoneNum;

@end
