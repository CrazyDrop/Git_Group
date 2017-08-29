//
//  ZWOperationEquipListCircleReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/11.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWQueueGroupRequestModel.h"
//单一mobile代理刷新使用
@interface ZWOperationEquipListCircleReqModel : ZWQueueGroupRequestModel

@property (nonatomic, assign) NSInteger repeatNum;

//废弃参数
//@property (nonatomic, assign) NSInteger selectSchool;
//@property (nonatomic, assign) NSInteger priceStatus;

//@property (nonatomic, assign) BOOL saveCookie;


@end
