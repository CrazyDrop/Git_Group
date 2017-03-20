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
@interface Equip_listModel : BaseDataModel

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

@property (nonatomic, strong) EquipModel * detaiModel;//详情数据
//@property (nonatomic, strong) id ;//详情数据

@property (nonatomic, strong) NSString * favTag;//喜欢标识
@property (nonatomic, strong) NSString * createTime;

@property (nonatomic, strong) NSString * earnPrice;
@property (nonatomic, assign) CGFloat  earnRate;

- (NSString * )detailCheckIdentifier;
- (NSString * )detailDataUrl;
- (NSString * )detailWebUrl;
//计算公式，判定账号是否值得购买
- (BOOL)preBuyEquipStatusWithCurrentExtraEquip;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

