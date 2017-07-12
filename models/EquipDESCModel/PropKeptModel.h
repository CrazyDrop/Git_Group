//
//  PropKeptModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
//#import "3Model.h"
//#import "1Model.h"
//#import "2Model.h"
//#import "0Model.h"

@interface PropKeptModel : NSObject

//@property (nonatomic, strong) 3Model *3;
//@property (nonatomic, strong) 1Model *1;
//@property (nonatomic, strong) 2Model *2;
//@property (nonatomic, strong) 0Model *0;

@property (nonatomic, strong) NSMutableArray * proKeptModelsArray;


/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

