//
//  PagerModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>

@interface PagerModel : NSObject

@property (nonatomic, strong) NSNumber *num_end;
@property (nonatomic, strong) NSNumber *num_begin;
@property (nonatomic, strong) NSNumber *cur_page;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

