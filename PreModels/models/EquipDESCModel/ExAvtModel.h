//
//  ExAvtModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ExAvtModel : NSObject

//@property (nonatomic, strong) 7Model *7;
//@property (nonatomic, strong) 3Model *3;
//@property (nonatomic, strong) 4Model *4;
//@property (nonatomic, strong) 5Model *5;
//@property (nonatomic, strong) 1Model *1;
//@property (nonatomic, strong) 20Model *20;
//@property (nonatomic, strong) 15Model *15;
//@property (nonatomic, strong) 6Model *6;
//@property (nonatomic, strong) 2Model *2;

@property (nonatomic, strong) NSMutableArray * jinyiModelsArray;


/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

