//
//  ZAHTTPResponse.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/11.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "STIHTTPNetwork.h"

@interface ZAHTTPResponse : STIHTTPResponse

@property (nonatomic, copy) NSString *returnCode;
@property (nonatomic, copy) NSString *returnMsg;


@end
