//
//  ZAWKConnectDelegate.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/9/28.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

//实现网络请求代理部分，中间处理applewatch的网络请求和返回响应
@interface ZAWKConnectDelegate : NSObject




-(void)startWebRequestWithRequestDic:(NSDictionary *)info andReplyBlockForAppleWatch:(void (^)(NSDictionary * dic))replyBlock andLocalSuccessBlock:(void(^)(void))iphoneBlock;









@end
