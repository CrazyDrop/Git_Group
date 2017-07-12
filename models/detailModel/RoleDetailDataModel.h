//
//  RoleDataModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "EquipModel.h"

@interface RoleDetailDataModel : NSObject

@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) EquipModel *equip;
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

