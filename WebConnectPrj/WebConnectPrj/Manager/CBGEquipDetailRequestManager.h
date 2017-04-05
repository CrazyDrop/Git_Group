//
//  CBGEquipDetailRequestManager.h
//  ZAIOSMainPrj
//
//  Created by Apple on 17/1/28.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Equip_listModel.h"
@interface CBGEquipDetailRequestManager : NSObject

+ (CBGEquipDetailRequestManager *)sharedInstance;

@property (nonatomic,  copy) void (^DoneDetailBlockForRequestSuccess)(Equip_listModel * detail);


//启动
-(void)startDetailRequest;

//取消全部
-(void)cancelAndClearTotal;


//添加新请求，依据对应的model
-(void)addDetailEquipRequestUrlWithEquipModel:(id)model;

-(EquipExtraModel *)extraModelFromLatestEquipDESC:(EquipModel *)detail;

@end
