//
//  EquipListRequestModel.h
//  ZAIOSMainPrj
//
//  Created by Apple on 17/2/4.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "RefreshDefaultListRequestModel.h"

@interface EquipListRequestModel : RefreshDefaultListRequestModel

@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) NSInteger selectSchool;
@property (nonatomic, assign) BOOL timerState;

@end
