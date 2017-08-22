//
//  CBGJueSeEquipModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/21.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGBaseEquipModel.h"
//角色相关各特征值
@interface CBGJueSeEquipModel : CBGBaseEquipModel

//@property (nonatomic, strong) NSString * equipId;
//@property (nonatomic, strong) NSString * orderSN;
//@property (nonatomic, strong) NSString * serverId;
//
//@property (nonatomic, assign) NSInteger  kindId;
//@property (nonatomic, assign) NSInteger  level;
//@property (nonatomic, assign) NSInteger  price;
//@property (nonatomic, strong) NSString * createTime;
//@property (nonatomic, strong) NSString * soldTime;
//
//@property (nonatomic, assign) NSInteger  addLevel;
//@property (nonatomic, assign) NSInteger  errorNum;
//@property (nonatomic, assign) NSInteger  baseNum;         //基础属性值、当前属性，减扣宝石之后
//@property (nonatomic, assign) NSInteger  basePartNum;     //基础伤害，仅针对武器
//@property (nonatomic, strong) NSString * moreSkill; //简易特效

@property (nonatomic, strong) NSString * xiulian;
@property (nonatomic, strong) NSString * chognxiu;
@property (nonatomic, assign) NSInteger  jiyuan;
@property (nonatomic, assign) NSInteger  jingyan;
@property (nonatomic, strong) NSString * jineng;
@property (nonatomic, strong) NSString * xiangrui;

@end
