//
//  CBGNearHistoryVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/3/21.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZACBGListDetailShowVC.h"
#import "CBGListModel.h"
#import "Equip_listModel.h"
@interface CBGNearHistoryVC : ZACBGListDetailShowVC

@property (nonatomic, strong) EquipModel * detailModel; //详情信息
@property (nonatomic, strong) CBGListModel * cbgList;   //列表信息，基础字段

@end
