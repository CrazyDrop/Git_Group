//
//  Equip_listModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "EquipModel.h"
#import "CBGListModel.h"
@interface Equip_listModel : BaseDataModel

@property (nonatomic, assign) BOOL accept_bargain;
@property (nonatomic, strong) NSString *area_name;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSNumber *serverid;
@property (nonatomic, strong) NSString *server_name;
@property (nonatomic, strong) NSNumber *equip_status;
@property (nonatomic, strong) NSNumber *pass_fair_show;
@property (nonatomic, strong) NSString *equip_name;
@property (nonatomic, strong) NSNumber *equipid;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *sell_expire_time_desc;
@property (nonatomic, strong) NSString *game_ordersn;
@property (nonatomic, strong) NSString *status_desc;
@property (nonatomic, strong) NSNumber *storage_type;
@property (nonatomic, strong) NSString *price_desc;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *desc_sumup;

//新增字段，作为接受库表回传的数据补充
@property (nonatomic, strong) NSString *add_create_time;
@property (nonatomic, strong) NSString *add_selling_time;
@property (nonatomic, strong) NSString *add_plan_des;
@property (nonatomic, strong) NSString *add_plan_total;
@property (nonatomic, strong) NSString *add_sell_price;

@property (nonatomic, strong) EquipModel * equipModel;//详情数据
//@property (nonatomic, strong) id ;//详情数据
@property (nonatomic, strong) CBGListModel * listSaveModel;//详情数据

@property (nonatomic, strong) NSString * favTag;//喜欢标识
@property (nonatomic, strong) NSString * createTime;

@property (nonatomic, strong) NSString * earnPrice;
@property (nonatomic, assign) CGFloat  earnRate;

-(void)refrehLocalBaseListModelWithDetail:(EquipModel *)detail;
- (NSString * )detailCheckIdentifier;
- (NSString * )detailDataUrl;
- (NSString * )detailWebUrl;
//计算公式，判定账号是否值得购买
- (BOOL)preBuyEquipStatusWithCurrentExtraEquip;
-(BOOL)isFirstInSelling;
-(NSString *)listLatestShowPrice;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

