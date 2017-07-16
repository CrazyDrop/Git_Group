//
//  AllEquipModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
@interface AllEquipModel : NSObject

//@property (nonatomic, strong) 187Model *187;
//@property (nonatomic, strong) 3Model *3;
//@property (nonatomic, strong) 16Model *16;
//@property (nonatomic, strong) 190Model *190;
//@property (nonatomic, strong) 4Model *4;
//@property (nonatomic, strong) 189Model *189;
//@property (nonatomic, strong) 5Model *5;
//@property (nonatomic, strong) 1Model *1;
//@property (nonatomic, strong) 188Model *188;
//@property (nonatomic, strong) 6Model *6;
//@property (nonatomic, strong) 2Model *2;

@property (nonatomic, strong) NSMutableArray * modelsArray;



/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSArray *)equipAddedSkillsNumberArrayFromEquipModel;

@end

