//
//  ZWOperationWebListReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/10.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWDefaultOperationReqModel.h"

@interface ZWOperationWebListReqModel : ZWDefaultOperationReqModel

@property (nonatomic, assign) NSInteger maxTimeNum;
@property (nonatomic, assign) NSInteger repeatNum; //并发请求数量控制

@property (nonatomic, assign) BOOL saveKookie;

@end
