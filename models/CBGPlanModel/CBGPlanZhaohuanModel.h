//
//  CBGPlanZhaohuanModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/6/30.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseDataModel.h"
#import "EquipModel.h"
//独立对装备进行估价，传入数组，返回单一价格

@interface CBGPlanZhaohuanModel : BaseDataModel

//价格列表
@property (nonatomic, strong) NSArray * priceArr;

//总价格
@property (nonatomic, assign) NSInteger total_price;


+(CBGPlanZhaohuanModel  *)planZhaohuanPriceModelFromEquipModelSummonArr:(NSArray<AllSummonModel *> *)zhaohuanArr;




@end
