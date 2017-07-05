//
//  CBGPlanZhuangbeiModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/6/30.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseDataModel.h"
#import "AllEquipModel.h"

@interface CBGPlanZhuangbeiModel : BaseDataModel

//价格列表
@property (nonatomic, strong) NSArray * priceArr;

//总价格
@property (nonatomic, assign) NSInteger total_price;


+(CBGPlanZhuangbeiModel  *)planZhuangbeiPriceModelFromAllEquipModel:(AllEquipModel *)equipModel;



@end
