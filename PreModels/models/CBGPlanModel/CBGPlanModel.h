//
//  CBGPlanModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/6/29.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseDataModel.h"
#import "EquipModel.h"
#import "CBGPlanZhaohuanModel.h"
#import "CBGPlanZhuangbeiModel.h"
//修改估价算法，实现相关的数据计算处理，后续进行统一库表修改
@interface CBGPlanModel : BaseDataModel

//账号相关信息
@property (nonatomic, strong) NSString * orderSn;
@property (nonatomic, strong) NSString * serverId;

//总价
@property (nonatomic,assign) NSInteger  total_price;

//价格差
@property (nonatomic,assign) NSInteger  earn_price;

//收益
@property (nonatomic,assign) NSInteger  plan_rate;

//服务器检查
@property (nonatomic,assign) BOOL  server_check;

//召唤兽单独计价
@property (nonatomic,strong,readonly) CBGPlanZhaohuanModel * zhaohuanModel;

//装单独计价
@property (nonatomic,strong,readonly) CBGPlanZhuangbeiModel * zhuangbeiModel;


//分项数据
//修炼价格、宠修价格、技能价格、经验价格、潜能果价格、乾元丹价格、等级价格、门派价格、房屋价格、储备金价格、孩子价格、祥瑞价格、坐骑价格、法宝价格
//装备价格、召唤兽价格、//装备宝宝，还需要单独计算
@property (nonatomic,assign) NSInteger  xiulian_plan_price;
@property (nonatomic,assign) NSInteger  chongxiu_plan_price;
@property (nonatomic,assign) NSInteger  jineng_plan_price;
@property (nonatomic,assign) NSInteger  jingyan_plan_price;
@property (nonatomic,assign) NSInteger  qiannengguo_plan_price;
@property (nonatomic,assign) NSInteger  qianyuandan_plan_price;
@property (nonatomic,assign) NSInteger  dengji_plan_price;
@property (nonatomic,assign) NSInteger  jiyuan_plan_price;
@property (nonatomic,assign) NSInteger  menpai_plan_price;
@property (nonatomic,assign) NSInteger  fangwu_plan_price;
@property (nonatomic,assign) NSInteger  xianjin_plan_price;
@property (nonatomic,assign) NSInteger  haizi_plan_price;
@property (nonatomic,assign) NSInteger  xiangrui_plan_price;
@property (nonatomic,assign) NSInteger  zuoji_plan_price;
@property (nonatomic,assign) NSInteger  fabao_plan_price;
@property (nonatomic,assign) NSInteger  zhuangbei_plan_price;
@property (nonatomic,assign) NSInteger  zhaohuanshou_plan_price;


+(CBGPlanModel *)planModelForDetailEquipModel:(EquipModel *)detailModel;

@end
