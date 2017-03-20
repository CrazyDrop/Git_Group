//
//  ZAOpenTimesAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/20.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"

@interface ZAOpenTimesResponseDetail : NSObject
@property (nonatomic,strong) NSString * opentimes;
@end

@interface ZAOpenTimesRequest : ZAHTTPRequest
//@property (nonatomic,copy) NSString * warnId;
@end

@interface ZAOpenTimesResponse : ZAHTTPResponse
@property (nonatomic, strong) ZAOpenTimesResponseDetail * returnData;
@end


@interface ZAOpenTimesAPI : ZAHTTPApi

//先设定id,后设定type   否则无法删除
- (instancetype)initWithWarnTimingId:(NSString *)idStr;

@property (nonatomic, strong) ZAOpenTimesRequest *req;
@property (nonatomic, strong) ZAOpenTimesResponse *resp;

@end