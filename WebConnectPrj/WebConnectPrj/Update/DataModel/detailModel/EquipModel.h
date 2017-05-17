//
//  EquipModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Bargain_infoModel.h"
#import "Cross_buy_serveridsModel.h"
#import "HighlightModel.h"
#import "Selling_infoModel.h"
#import "Poundage_listModel.h"
#import "EquipExtraModel.h"
#import "CBGListModel.h"

@interface EquipModel : BaseDataModel

@property (nonatomic, strong) NSString *raw_fair_show_end_time_desc;
@property (nonatomic, strong) NSString *server_name;
@property (nonatomic, strong) NSNumber *owner_uid;
// @property (nonatomic, strong) Null *bargain_status;
@property (nonatomic, strong) NSNumber *can_cross_buy;
@property (nonatomic, strong) NSNumber *storage_type;
// @property (nonatomic, strong) Null *bargain_poundage_list;
@property (nonatomic, strong) NSString *price_desc;
@property (nonatomic, strong) NSNumber *kindid;
@property (nonatomic, strong) NSString *web_last_price_desc;
@property (nonatomic, strong) NSString *equip_name;
@property (nonatomic, strong) NSString *area_name;
@property (nonatomic, strong) NSNumber *is_my_equip;
@property (nonatomic, strong) NSNumber *support_cross_buy;
@property (nonatomic, strong) NSString *status_desc;
@property (nonatomic, strong) NSNumber *can_buy;
// @property (nonatomic, strong) Null *bargain_resp_price_desc;
@property (nonatomic, strong) NSNumber *status;
// @property (nonatomic, strong) Null *appointed_data;
@property (nonatomic, strong) NSString *fair_show_poundage_desc;
@property (nonatomic, strong) NSString *fair_show_end_time_desc;
@property (nonatomic, strong) NSString *create_time_desc;
// @property (nonatomic, strong) Null *bargain_extra_msg;
@property (nonatomic, strong) NSNumber *has_collect;
// @property (nonatomic, strong) Null *bargain_resp_msgid;
@property (nonatomic, strong) NSNumber *fair_show_poundage;
// @property (nonatomic, strong) Null *bargain_resp_price;
// @property (nonatomic, strong) Null *bargain_status_desc;
@property (nonatomic, strong) NSNumber *areaid;
@property (nonatomic, strong) NSNumber *serverid;
@property (nonatomic, strong) NSString *equip_face_img;
// @property (nonatomic, strong) Null *bargainid;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *create_time;
@property (nonatomic, strong) NSNumber *equip_level;
@property (nonatomic, strong) NSNumber *equip_count;
@property (nonatomic, strong) NSString *equip_type;
@property (nonatomic, strong) NSString *owner_nickname;
// @property (nonatomic, strong) Null *unread_bargain_count;
@property (nonatomic, strong) NSNumber *is_login;
@property (nonatomic, strong) NSString *equip_type_desc;
@property (nonatomic, strong) NSNumber *equipid;
@property (nonatomic, strong) NSString *equip_desc;
@property (nonatomic, strong) NSNumber *is_same_server;
@property (nonatomic, strong) NSNumber *allow_appoint;
@property (nonatomic, strong) NSString *game_ordersn;
@property (nonatomic, strong) NSString *appointed_roleid;
@property (nonatomic, strong) NSString *last_price_desc;
@property (nonatomic, strong) NSString *game_serverid;
@property (nonatomic, strong) NSString *share_desc;
@property (nonatomic, strong) NSNumber *can_start_auction;
@property (nonatomic, strong) NSString *sell_expire_time_desc;
@property (nonatomic, strong) NSNumber *allow_bargain;
@property (nonatomic, strong) NSString *level_desc;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSNumber *pass_fair_show;
@property (nonatomic, strong) NSNumber *is_role_cross_buy;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *owner_roleid;
@property (nonatomic, strong) NSNumber *collect_num;
@property (nonatomic, strong) NSString *detail_title_desc;
@property (nonatomic, strong) NSString *share_title;
@property (nonatomic, strong) NSString *desc_sumup;
@property (nonatomic, strong) NSString *selling_time;
@property (nonatomic, strong) NSString *fair_show_end_time;
@property (nonatomic, strong) Bargain_infoModel *bargain_info;
@property (nonatomic, strong) NSMutableArray <Cross_buy_serveridsModel *> *cross_buy_serverids;
@property (nonatomic, strong) NSMutableArray <HighlightModel *> *highlight;
@property (nonatomic, strong) NSMutableArray <Selling_infoModel *> *selling_info;
@property (nonatomic, strong) NSMutableArray <Poundage_listModel *> *poundage_list;

@property (nonatomic, strong) EquipExtraModel *equipExtra;
@property (nonatomic, assign) CGFloat extraEarnRate;

@property (nonatomic, assign) CGFloat earnPrice;
@property (nonatomic, strong) NSString * finishDate;//详情刷新时间

-(CBGEquipRoleState)equipState;

-(NSString *)equipSoldOutResultTime;
-(NSString *)equipCancelBackResultTime;
-(CGFloat)createEquipExtraEarnRate;

-(NSDictionary *)detailDesDicFromCurrentDesc;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

