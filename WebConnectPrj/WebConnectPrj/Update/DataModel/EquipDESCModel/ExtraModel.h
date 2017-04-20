//
//  1Model.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "BaseDataModel.h"
@interface ExtraModel : BaseDataModel

@property (nonatomic, strong) NSString * extraTag;
@property (nonatomic, strong) NSString * extraName;
@property (nonatomic, strong) NSString * extraString;
@property (nonatomic, strong) NSNumber * extraValue;

@property (nonatomic, strong) NSNumber *name;

//@property (nonatomic, strong) NSNumber *iType;
@property (nonatomic, strong) NSString *cDesc;

//model0
@property (nonatomic, strong) NSNumber *iSpe;
@property (nonatomic, strong) NSNumber *iStr;
@property (nonatomic, strong) NSNumber *iCor;
@property (nonatomic, strong) NSNumber *iMag;
@property (nonatomic, strong) NSNumber *iRes;


//model4
@property (nonatomic, strong) NSNumber *order;
@property (nonatomic, strong) NSString *cName;
@property (nonatomic, strong) NSNumber *iType;


//model9
//@property (nonatomic, strong) NSNumber *iType;
//@property (nonatomic, strong) NSNumber *order;
@property (nonatomic, strong) NSNumber *iSkillLevel;
//@property (nonatomic, strong) NSString *cName;
@property (nonatomic, strong) NSNumber *iSkill;
@property (nonatomic, strong) NSNumber *nosale;

//model187
@property (nonatomic, strong) NSNumber *iLock;
//@property (nonatomic, strong) NSString *cDesc;
//@property (nonatomic, strong) NSNumber *iType;

-(NSInteger)equipLatestAddLevel;//宝石等级
-(NSString *)equipAppendSkill;//特技

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

