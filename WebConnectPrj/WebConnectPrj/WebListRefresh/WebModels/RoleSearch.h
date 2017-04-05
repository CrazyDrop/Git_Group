//
//  RoleSearch.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PagerModel.h"
#import "WebEquip_listModel.h"

@interface RoleSearch : NSObject

@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) PagerModel *pager;
@property (nonatomic, strong) NSMutableArray <WebEquip_listModel *> *equip_list;
@property (nonatomic, strong) NSString * msg;
/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

