//
//  ZWOperationEquipListCircleReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/11.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWDefaultOperationReqModel.h"
//单一mobile代理刷新使用
@interface ZWOperationEquipListCircleReqModel : ZWDefaultOperationReqModel

@property (nonatomic, assign) NSInteger repeatNum;
@property (nonatomic, assign) NSInteger selectSchool;
@property (nonatomic, assign) NSInteger priceStatus;
@property (nonatomic, assign) BOOL timerState;

@property (nonatomic, assign) BOOL saveKookie;


@end
