//
//  JinjieModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CoreModel.h"

@interface JinjieModel : NSObject

@property (nonatomic, strong) NSNumber *cnt;
@property (nonatomic, strong) NSNumber *lx;
//@property (nonatomic, strong) NSNumber *new_type;
@property (nonatomic, strong) CoreModel *core;

@property (nonatomic, strong) NSNumber *refresh_style;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

