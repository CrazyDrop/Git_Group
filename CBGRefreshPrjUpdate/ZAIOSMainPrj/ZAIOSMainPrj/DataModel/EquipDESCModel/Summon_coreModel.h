//
//  Summon_coreModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
//#import "902Model.h"
//#import "901Model.h"
//#import "907Model.h"
@class ExtraModel;
@interface Summon_coreModel : NSObject

//@property (nonatomic, strong) NSMutableArray <902Model *> *902;
//@property (nonatomic, strong) NSMutableArray <901Model *> *901;
//@property (nonatomic, strong) NSMutableArray <907Model *> *907;

@property (nonatomic, strong) NSMutableArray<ExtraModel *> * sumonModelsArray;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

