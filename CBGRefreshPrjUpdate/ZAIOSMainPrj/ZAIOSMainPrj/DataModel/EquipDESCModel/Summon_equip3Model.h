//
//  Summon_equip3Model.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Summon_equip3Model : NSObject

@property (nonatomic, strong) NSNumber *iLock;
@property (nonatomic, strong) NSString *cDesc;
@property (nonatomic, strong) NSNumber *iType;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

