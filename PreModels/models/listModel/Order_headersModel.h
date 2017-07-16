//
//  Order_headersModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DirectionModel.h"

@interface Order_headersModel : NSObject

@property (nonatomic, strong) NSString *field;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray <DirectionModel *> *direction;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

