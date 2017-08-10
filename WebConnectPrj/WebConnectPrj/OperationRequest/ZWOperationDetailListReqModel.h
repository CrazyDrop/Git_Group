//
//  ZWOperationDetailListReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/10.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWDefaultOperationReqModel.h"
@class EquipExtraModel;
@class EquipModel;
@interface ZWOperationDetailListReqModel : ZWDefaultOperationReqModel
@property (nonatomic, assign) BOOL ingoreExtra;

-(EquipExtraModel *)extraModelFromLatestEquipDESC:(EquipModel *)detail;

@end
