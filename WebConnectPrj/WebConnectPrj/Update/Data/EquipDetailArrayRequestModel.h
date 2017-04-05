//
//  EquipDetailArrayRequestModel.h
//  ZAIOSMainPrj
//
//  Created by Apple on 17/2/5.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "RefreshDefaultListRequestModel.h"
@class EquipExtraModel;
@class EquipModel;
@interface EquipDetailArrayRequestModel : RefreshDefaultListRequestModel

@property (nonatomic, assign) BOOL ingoreExtra;
+(instancetype)sharedInstance;
-(EquipExtraModel *)extraModelFromLatestEquipDESC:(EquipModel *)detail;

@end
