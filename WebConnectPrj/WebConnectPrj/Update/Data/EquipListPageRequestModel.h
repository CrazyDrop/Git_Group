//
//  EquipListPageRequestModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "RefreshDefaultListRequestModel.h"

@interface EquipListPageRequestModel : RefreshDefaultListRequestModel

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) BOOL timerState;

@end
