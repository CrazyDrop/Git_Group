//
//  HugeHorseModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>


@interface HugeHorseModel : NSObject

//@property (nonatomic, strong) 105Model *105;
//@property (nonatomic, strong) 9Model *9;
//@property (nonatomic, strong) 198Model *198;
//@property (nonatomic, strong) 113Model *113;

@property (nonatomic, strong) NSMutableArray * zuoJiModelsArray;


/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

