//
//  BBListModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "BBDetailEquipModel.h"

@interface BBStatusModel : NSObject

@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) BBDetailEquipModel *equip;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

