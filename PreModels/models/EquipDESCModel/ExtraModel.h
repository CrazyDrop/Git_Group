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
//"order":2,"cName":"流云玉佩","iSkillLevel":0,"iSkill":0,"iType":11098,"nosale":0,
//3:(["all_skills":([611:3,]),"ExtraGrow":0,"iGrade":136,"exgrow":12712,"iType":508,"mattrib":"魔力",])
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


@property (nonatomic, strong) NSNumber *ExtraGrow;
@property (nonatomic, strong) NSNumber *iGrade;
@property (nonatomic, strong) NSNumber *exgrow;
@property (nonatomic, strong) NSNumber *mattrib;

-(NSInteger)equipErrorTimes;
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

