//
//  CBGBaseEquipModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/21.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseDataModel.h"
///CBG物品 基础数据model，进行库表数据存储、数据读取
//包含所有属性，后期屏蔽子类属性使用
@interface CBGBaseEquipModel : BaseDataModel

@property (nonatomic, strong) NSString * equipId;
@property (nonatomic, strong) NSString * orderSN;
@property (nonatomic, strong) NSString * serverId;

@property (nonatomic, assign) NSInteger  kindId;
@property (nonatomic, assign) NSInteger  level;
@property (nonatomic, assign) NSInteger  price;
@property (nonatomic, strong) NSString * createTime;
@property (nonatomic, strong) NSString * soldTime;

@property (nonatomic, assign) NSInteger  addLevel;
@property (nonatomic, assign) NSInteger  errorNum;
@property (nonatomic, assign) NSInteger  baseNum;         //基础属性值、当前属性，减扣宝石之后
@property (nonatomic, assign) NSInteger  basePartNum;     //基础伤害，仅针对武器
@property (nonatomic, strong) NSString * moreSkill;


@end
