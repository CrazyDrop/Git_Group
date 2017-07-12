//
//  PetModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "All_skillsModel.h"
@interface PetModel : NSObject

@property (nonatomic, strong) NSString *cName;
@property (nonatomic, strong) NSNumber *iType;
@property (nonatomic, strong) NSMutableArray <All_skillsModel *> *all_skills;
/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

