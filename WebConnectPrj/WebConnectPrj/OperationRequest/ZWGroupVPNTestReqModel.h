//
//  ZWGroupVPNTestReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWQueueGroupRequestModel.h"

@interface ZWGroupVPNTestReqModel : ZWQueueGroupRequestModel

@property (nonatomic, assign) NSInteger pageNum;

+(NSString *)randomTestFirstWebRequestWithIndex:(NSInteger)index;

@end
