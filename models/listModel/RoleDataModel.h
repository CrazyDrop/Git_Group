//
//  RoleDataModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Keyword_argModel.h"
#import "Order_headersModel.h"
#import "Equip_listModel.h"

@interface RoleDataModel : NSObject

@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSNumber *num_per_page;
@property (nonatomic, strong) NSString *order_direction;
@property (nonatomic, strong) NSString *advance_search_type;
@property (nonatomic, strong) NSNumber *is_login;
@property (nonatomic, strong) NSString *order_field;
@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) Keyword_argModel *keyword_arg;
@property (nonatomic, strong) NSMutableArray <Order_headersModel *> *order_headers;
@property (nonatomic, strong) NSMutableArray <Equip_listModel *> *equip_list;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

