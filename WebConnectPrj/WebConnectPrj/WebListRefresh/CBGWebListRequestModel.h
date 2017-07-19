//
//  CBGWebListRequestModel.h
//  WebConnectPrj
//
//  Created by Apple on 17/3/25.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "EquipListRequestModel.h"

//当前规则
//考虑 流量情况下，刷新无验证码，并发数太少，修改并发请求同时发起3个

@interface CBGWebListRequestModel : EquipListRequestModel

@property (nonatomic, assign) NSInteger latestIndex;
@property (nonatomic, assign) NSInteger maxTimeNum;
@property (nonatomic, assign) BOOL autoRefresh;//控制使用cookie时是否自动变更cookie


@end
