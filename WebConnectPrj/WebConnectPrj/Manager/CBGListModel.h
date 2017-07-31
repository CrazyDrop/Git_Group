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
    CBGEquipRoleState_AutoUnSell,//自动下架
    CBGEquipRoleState_UserUnSell,//用户下架，只是大概区分
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
{//所有刷新状态，针对无存储的，执行插入，有记录的，部分改变
    CBGLocalDataBaseListUpdateStyle_None = 0,
    CBGLocalDataBaseListUpdateStyle_RefreshEval,    //增加系统估价，read数据导入时使用
    CBGLocalDataBaseListUpdateStyle_TimeAndPrice,     //更新价格和时间
    CBGLocalDataBaseListUpdateStyle_RefreshPlan,    //刷新估价
    CBGLocalDataBaseListUpdateStyle_TimeAndPlan,    //刷新时间和估价
    CBGLocalDataBaseListUpdateStyle_RefreshStatus,  //刷新状态、针对状态修改，仅针对部分页面
    CBGLocalDataBaseListUpdateStyle_CopyRefresh,    //写入刷新，强制刷新，针对服务器合并的情况处理
    CBGLocalDataBaseListUpdateStyle_RefreshTotal,   //所有属性写入
} CBGLocalDataBaseListUpdateStyle;


@interface CBGListModel : BaseDataModel

//包含库表存储字段、库表读取字段
//基础部分
@property (nonatomic, strong) NSString * game_ordersn;
@property (nonatomic, strong) NSString * owner_roleid;
@property (nonatomic, assign) NSInteger server_id;
@property (nonatomic, assign) NSInteger equip_id;
//整理数据字段 存储
@property (nonatomic, assign) NSInteger  equip_status;

@property (nonatomic, assign) NSInteger  equip_huasheng;        //修改字段意义，标识是否已经化圣，方便后续展示化圣相关数据
@property (nonatomic, assign) NSInteger  equip_price_common;    //外部价格，区分是否还价购买，针对售出数据处理
@property (nonatomic, assign) BOOL  appointed;  //是否有指定id ，有指定，使用库表equip_start_price
@property (nonatomic, assign) BOOL  errored;    //是否为问题交易，针对此种，需要单独处理保存方法
@property (nonatomic, assign) BOOL  ingore;     //是否为忽略数据
@property (nonatomic, assign) BOOL  ownerBuy;   //是否为自有购买
@property (nonatomic, assign) BOOL  bargainBuy;   //是否为讲价购买

//可能刷新信息
@property (nonatomic, assign) NSInteger  equip_price;
@property (nonatomic, assign) NSInteger  equip_accept;          //修改字段意义，标识是否可以还价
@property (nonatomic, assign) NSInteger  equip_start_price; //起始价格  主表中存储
@property (nonatomic, strong) NSString * equip_more_append; //方便后续追加
@property (nonatomic, assign) NSInteger  equip_eval_price;

//固定部分
@property (nonatomic, assign) NSInteger  equip_school;
@property (nonatomic, assign) NSInteger  equip_level;
@property (nonatomic, strong) NSString * equip_name;      //根据头像icon设定
@property (nonatomic, strong) NSString * equip_type;
@property (nonatomic, assign) NSInteger kindid;
@property (nonatomic, assign) NSInteger server_check;

//估值部分
@property (nonatomic, assign) NSInteger  plan_total_price;
@property (nonatomic, assign) NSInteger  plan_xiulian_price;
@property (nonatomic, assign) NSInteger  plan_chongxiu_price;
@property (nonatomic, assign) NSInteger  plan_jineng_price;
@property (nonatomic, assign) NSInteger  plan_jingyan_price;
@property (nonatomic, assign) NSInteger  plan_qiannengguo_price;
@property (nonatomic, assign) NSInteger  plan_qianyuandan_price;
@property (nonatomic, assign) NSInteger  plan_dengji_price;
@property (nonatomic, assign) NSInteger  plan_jiyuan_price;
@property (nonatomic, assign) NSInteger  plan_menpai_price;
@property (nonatomic, assign) NSInteger  plan_fangwu_price;
@property (nonatomic, assign) NSInteger  plan_xianjin_price;
@property (nonatomic, assign) NSInteger  plan_haizi_price;
@property (nonatomic, assign) NSInteger  plan_xiangrui_price;
@property (nonatomic, assign) NSInteger  plan_zuoji_price;
@property (nonatomic, assign) NSInteger  plan_fabao_price;
@property (nonatomic, assign) NSInteger  plan_zhaohuanshou_price;
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

@property (nonatomic, assign) NSInteger fav_or_ingore;//暂时废弃

//4为服务器失效  服务器合并，serverID无效//备用
@property (nonatomic, strong) NSString * serverName;
@property (nonatomic, assign) NSInteger  historyPrice;//上一次的价格信息

-(BOOL)planMore_zhaohuan;
-(BOOL)planMore_Equip;

-(void)refreshCBGListDataModelWithDetaiEquipModel:(id)model;
-(CBGEquipRoleState)latestEquipListStatus;
-(NSString * )equip_school_name;
+(NSInteger)schoolNumberFromSchoolName:(NSString *)name;
+(NSString *)schoolNameFromSchoolNumber:(NSInteger)school;
-(NSInteger)price_add_total_plan;
-(NSInteger)price_rate_latest_plan;
-(NSInteger)price_earn_plan;
- (NSString * )detailWebUrl;
- (NSString * )detailDataUrl;
- (NSString * )mobileAppDetailShowUrl;
-(CGFloat)price_base_equip;
-(BOOL)preBuyEquipStatusWithCurrentExtraEquip;

-(NSString *)createLatestMoreAppendString;
-(void)readDataFromMoreAppendString;


@end
