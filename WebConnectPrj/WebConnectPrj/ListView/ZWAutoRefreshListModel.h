//
//  ZWAutoRefreshListModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/7/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "EquipListRequestModel.h"
//追加刷新形式，形成稳定刷新，防止屏蔽，每页单条数据请求，1分钟请求一次   共请求3页数据
@interface ZWAutoRefreshListModel : EquipListRequestModel

@property (nonatomic, assign) BOOL autoRefresh;
@property (nonatomic, assign, readonly) NSInteger latestIndex;



@end
