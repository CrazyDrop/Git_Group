//
//  Equip_listModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "HighlightModel.h"

@interface BBEquip_listModel : NSObject

@property (nonatomic, strong) NSString *selling_time;
@property (nonatomic, strong) NSString *server_name;
@property (nonatomic, strong) NSString *sell_expire_time_desc;
@property (nonatomic, strong) NSString *selling_time_ago_desc;
@property (nonatomic, strong) NSNumber *has_collect;
@property (nonatomic, strong) NSString *status_desc;
@property (nonatomic, strong) NSNumber *auction_bid_count;
@property (nonatomic, strong) NSString *desc_sumup;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *desc_sumup_short;
@property (nonatomic, strong) NSNumber *equipid;
@property (nonatomic, strong) NSNumber *storage_type;
@property (nonatomic, strong) NSString *price_desc;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *area_name;
@property (nonatomic, strong) NSNumber *collect_num;
@property (nonatomic, strong) NSNumber *equip_status;
@property (nonatomic, strong) NSString *equip_name;
@property (nonatomic, strong) NSNumber *accept_bargain;
@property (nonatomic, strong) NSString *game_ordersn;
@property (nonatomic, strong) NSNumber *auction_status;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *pass_fair_show;
@property (nonatomic, strong) NSNumber *serverid;
@property (nonatomic, strong) NSMutableArray <HighlightModel *> *highlight;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

