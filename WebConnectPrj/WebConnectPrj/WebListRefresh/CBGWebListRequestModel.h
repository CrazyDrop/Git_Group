//
//  CBGWebListRequestModel.h
//  WebConnectPrj
//
//  Created by Apple on 17/3/25.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "EquipListRequestModel.h"

//当前规则
//使用cookie时，页面数量无效，仅1个请求，maxTimeNum过小时，清空cookie
//考虑新增使用cookie时   首次请求并发3次  选择其中一个cookie后续使用 (未实现)
//不使用cookie时，页面数量默认1 (2个并发) maxTimeNum过小时，递增页数


@interface CBGWebListRequestModel : EquipListRequestModel

@property (nonatomic, assign) NSInteger latestIndex;
@property (nonatomic, assign) NSInteger maxTimeNum;
@property (nonatomic, assign) BOOL autoRefresh;//控制使用cookie时是否自动变更cookie


@end
