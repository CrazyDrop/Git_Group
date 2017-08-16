//
//  ServerRefreshRequestModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/7/28.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWQueueGroupRequestModel.h"
//服务器刷新Model
@interface ServerRefreshRequestModel : ZWQueueGroupRequestModel

//数据刷新
//@property (nonatomic, assign) BOOL timerState;

//仅请求第一页数据
@property (nonatomic, strong) NSArray * serverArr;


@end
