//
//  CoreModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>

@interface CoreModel : NSObject

@property (nonatomic, strong) NSString *effect;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSNumber *fix_st;
@property (nonatomic, strong) NSString *name;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

