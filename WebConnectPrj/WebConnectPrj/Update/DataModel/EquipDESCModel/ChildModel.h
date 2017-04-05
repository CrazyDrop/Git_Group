//
//  ChildModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Summon_equip2Model.h"
#import "Summon_equip1Model.h"
#import "All_skillsModel.h"

@interface ChildModel : BaseDataModel

@property (nonatomic, strong) NSNumber *def;
@property (nonatomic, strong) NSNumber *grow;
@property (nonatomic, strong) NSNumber *iHp_max;
@property (nonatomic, strong) NSNumber *iSpe_all;
@property (nonatomic, strong) NSNumber *iDef_All;
@property (nonatomic, strong) NSNumber *att;
@property (nonatomic, strong) NSNumber *iRes_all;
@property (nonatomic, strong) NSNumber *mp;
@property (nonatomic, strong) NSNumber *change_598_times;
@property (nonatomic, strong) NSNumber *spe;
@property (nonatomic, strong) NSNumber *iBaobao;
@property (nonatomic, strong) NSNumber *iMp_max;
@property (nonatomic, strong) NSNumber *iMag_all;
@property (nonatomic, strong) NSNumber *iGrade;
@property (nonatomic, strong) NSNumber *iType;
@property (nonatomic, strong) NSNumber *iMp;
@property (nonatomic, strong) NSNumber *iPoint;
@property (nonatomic, strong) NSNumber *qianjinlu;
@property (nonatomic, strong) NSNumber *dod;
@property (nonatomic, strong) NSNumber *ruyidan;
@property (nonatomic, strong) NSNumber *iHp;
@property (nonatomic, strong) NSNumber *yuanxiao;
@property (nonatomic, strong) NSNumber *iDex_All;
@property (nonatomic, strong) NSNumber *iMagDef_all;
@property (nonatomic, strong) NSNumber *iStr_all;
@property (nonatomic, strong) NSNumber *child_sixwx;
@property (nonatomic, strong) NSNumber *hp;
@property (nonatomic, strong) NSNumber *life;
@property (nonatomic, strong) NSNumber *iAtt_F;
@property (nonatomic, strong) NSNumber *att_rate;
@property (nonatomic, strong) NSNumber *iDod_All;
@property (nonatomic, strong) NSNumber *iAtt_all;
@property (nonatomic, strong) NSNumber *iCor_all;
@property (nonatomic, strong) Summon_equip2Model *summon_equip2;
@property (nonatomic, strong) Summon_equip1Model *summon_equip1;
@property (nonatomic, strong) All_skillsModel *all_skills;

/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

