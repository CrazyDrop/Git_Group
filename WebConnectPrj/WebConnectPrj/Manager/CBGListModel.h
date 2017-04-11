//
//  CBGListModel.h
//  WebConnectPrj
//
//  Created by Apple on 17/3/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseDataModel.h"

typedef enum : NSUInteger
{
    CBGEquipRoleState_None = 0,
    CBGEquipRoleState_unSelling,
    CBGEquipRoleState_InSelling,
    CBGEquipRoleState_InOrdering,
    CBGEquipRoleState_Backing,
    CBGEquipRoleState_PayFinish,
    CBGEquipRoleState_BuyFinish,
} CBGEquipRoleState;
//列表数据

typedef enum : NSUInteger
{
    CBGEquipPlanStyle_None = 0, //
    CBGEquipPlanStyle_NotWorth,
    CBGEquipPlanStyle_Worth,    //值得
    CBGEquipPlanStyle_PlanBuy,  //可以买
    CBGEquipPlanStyle_Ingore,   //特殊服务器
} CBGEquipPlanStyle;

typedef enum : NSUInteger
{
    CBGLocalDataBaseListUpdateStyle_None = 0,
//    CBGLocalDataBaseListUpdateStyle_Insert,     //全部插入，存在则进行更新，当前不使用，无记录即插入
    CBGLocalDataBaseListUpdateStyle_UpdateTime, //更新价格和时间
    CBGLocalDataBaseListUpdateStyle_RefreshPlan,//刷新估价  详情
    CBGLocalDataBaseListUpdateStyle_RefreshEval, //增加系统估价
    CBGLocalDataBaseListUpdateStyle_TimeAndPlan, //刷新时间和估价
    CBGLocalDataBaseListUpdateStyle_CopyRefresh, //写入刷新，强制刷新
} CBGLocalDataBaseListUpdateStyle;


@interface CBGListModel : BaseDataModel

//包含库表存储字段、库表读取字段
//基础部分
@property (nonatomic, strong) NSString * game_ordersn;
@property (nonatomic, strong) NSString * owner_roleid;
@property (nonatomic, assign) NSInteger server_id;

//账号信息
@property (nonatomic, assign) NSInteger  equip_status;  //无需存储，方便库表操作判定
@property (nonatomic, assign) NSInteger  equip_school;
@property (nonatomic, assign) NSInteger  equip_level;
@property (nonatomic, strong) NSString * equip_name;
@property (nonatomic, strong) NSString * equip_juese;      //根据头像icon设定
@property (nonatomic, strong) NSString * equip_xingbie;
@property (nonatomic, strong) NSString * equip_des;
@property (nonatomic, assign) NSInteger  equip_price;
@property (nonatomic, assign) NSInteger  equip_accept;
@property (nonatomic, assign) NSInteger  equip_start_price; //起始价格  主表中存储
@property (nonatomic, assign) BOOL  appointed;//是否有指定id ，有指定，使用库表equip_start_price
@property (nonatomic, strong) NSString * equip_more_append;
@property (nonatomic, assign) NSInteger  equip_eval_price;

//估值部分
@property (nonatomic, assign) NSInteger  plan_total_price;
@property (nonatomic, assign) NSInteger  plan_xiulian_price;
@property (nonatomic, assign) NSInteger  plan_chongxiu_price;
@property (nonatomic, assign) NSInteger  plan_jineng_price;
@property (nonatomic, assign) NSInteger  plan_qianyuandan_price;
@property (nonatomic, assign) NSInteger  plan_zhaohuanshou_price;
@property (nonatomic, assign) NSInteger  plan_jingyan_price;
@property (nonatomic, assign) NSInteger  plan_zhuangbei_price;
@property (nonatomic, strong) NSString * plan_des;
@property (nonatomic, assign) NSInteger  plan_rate;

//时间信息
@property (nonatomic, strong) NSString * sell_create_time;  //起售时间  详情里有
@property (nonatomic, strong) NSString * sell_start_time;   //上架时间
@property (nonatomic, copy) NSString * sell_sold_time;    //售出时间
@property (nonatomic, copy) NSString * sell_back_time;    //取回时间

@property (nonatomic, strong) NSString * sell_order_time;       //下单时间    本地时间
@property (nonatomic, strong) NSString * sell_cancel_time;      //取消时间    本地时间
@property (nonatomic, assign) NSInteger  sell_space;//售出间隔时间

@property (nonatomic, assign) CBGLocalDataBaseListUpdateStyle dbStyle;
@property (nonatomic, assign) CBGEquipPlanStyle style;
@property (nonatomic, assign) BOOL detailRefresh;

@property (nonatomic, assign) NSInteger fav_or_ingore;
@property (nonatomic, strong) NSString * serverName;


-(void)refreshCBGListDataModelWithDetaiEquipModel:(id)model;
-(CBGEquipRoleState)latestEquipListStatus;
-(NSString * )equip_school_name;
+(NSInteger)schoolNumberFromSchoolName:(NSString *)name;
+(NSString *)schoolNameFromSchoolNumber:(NSInteger)school;
-(NSInteger)price_add_total_plan;
-(NSInteger)price_rate_latest_plan;
- (NSString * )detailWebUrl;
- (NSString * )detailDataUrl;
-(CGFloat)price_base_equip;
-(BOOL)preBuyEquipStatusWithCurrentExtraEquip;

@end
