//
//  ZWOperationEquipReqListReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWDefaultOperationReqModel.h"
//mobile监听列表请求使用
@interface ZWOperationEquipReqListReqModel : ZWDefaultOperationReqModel


@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) NSInteger selectSchool;
@property (nonatomic, assign) NSInteger priceStatus;
@property (nonatomic, assign) BOOL timerState;

@property (nonatomic, assign) BOOL saveKookie;

@end
