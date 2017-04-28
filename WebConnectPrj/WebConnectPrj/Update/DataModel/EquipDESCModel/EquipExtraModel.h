//
//  EquipExtraModel.h
//
//  http://www.cnblogs.com/YouXianMing/
//  https://github.com/YouXianMing
//
//  Copyright (c) YouXianMing All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FabaoModel.h"
#import "AllEquipModel.h"
#import "ExAvtModel.h"
#import "HugeHorseModel.h"
#import "More_attrModel.h"
#import "AllRiderModel.h"
#import "All_skillsModel.h"
#import "ChildModel.h"
#import "PropKeptModel.h"
#import "ChangeschModel.h"
#import "PetModel.h"
#import "AllSummonModel.h"
#import "Idbid_descModel.h"

@interface EquipExtraModel : BaseDataModel

@property (nonatomic, strong) NSNumber *iTotalMagDam_all;
@property (nonatomic, strong) NSNumber *addPoint;//粽子数量
@property (nonatomic, strong) NSString *cOrg;//帮派名字
@property (nonatomic, strong) NSNumber *iRes_All;
@property (nonatomic, strong) NSNumber *i3FlyLv;
@property (nonatomic, strong) NSNumber *iSchool;
@property (nonatomic, strong) NSNumber *total_avatar;
@property (nonatomic, strong) NSNumber *usernum;
@property (nonatomic, strong) NSNumber *iCGBoxAmount;//彩果方案
@property (nonatomic, strong) NSNumber *commu_gid;
@property (nonatomic, strong) NSNumber *iAtt_All;
@property (nonatomic, strong) NSNumber *iLearnCash;//储备金
@property (nonatomic, strong) NSNumber *iCGTotalAmount;
@property (nonatomic, strong) NSNumber *AchPointTotal;//彩果数量
@property (nonatomic, strong) NSNumber *ExpJw;
@property (nonatomic, strong) NSNumber *iExptSki1;//人物物理
@property (nonatomic, strong) NSNumber *iGrade;//等级
@property (nonatomic, strong) NSNumber *iMag_All;
@property (nonatomic, strong) NSNumber *iSchOffer;//门贡
@property (nonatomic, strong) NSNumber *iNutsNum;
@property (nonatomic, strong) NSNumber *bid;
@property (nonatomic, strong) NSNumber *iDef_All;
@property (nonatomic, strong) NSNumber *iExptSki4;
@property (nonatomic, strong) NSNumber *iDesc;
@property (nonatomic, strong) NSNumber *iStr_All;
@property (nonatomic, strong) NSNumber *iUpExp;//当前经验
@property (nonatomic, strong) NSNumber *iBeastSki3;
@property (nonatomic, strong) NSNumber *commu_name;
@property (nonatomic, strong) NSNumber *iBadness;
@property (nonatomic, strong) NSNumber *outdoor_level;//庭院规模
@property (nonatomic, strong) NSNumber *iErrantry;//侠义、剑会积分
@property (nonatomic, strong) NSNumber *iTotalMagDef_all;
@property (nonatomic, strong) NSNumber *iPoint;
@property (nonatomic, strong) NSNumber *iGoodness;//善恶点
@property (nonatomic, strong) NSNumber *iMaxExpt2;
@property (nonatomic, strong) NSNumber *iSewski;
@property (nonatomic, strong) NSNumber *iHp_Eff;
@property (nonatomic, strong) NSString *cName;
@property (nonatomic, strong) NSNumber *normal_horse;
@property (nonatomic, strong) NSNumber *icolor_ex;
@property (nonatomic, strong) NSNumber *rent_level;//房屋等级等级?
@property (nonatomic, strong) NSNumber *iCGBodyAmount;//身上彩果数量
@property (nonatomic, strong) NSNumber *ori_desc;
@property (nonatomic, strong) NSNumber *iPride;
@property (nonatomic, strong) NSNumber *total_horse;
@property (nonatomic, strong) NSNumber *iDod_All;
@property (nonatomic, strong) NSNumber *iSaving;//存款
@property (nonatomic, strong) NSNumber *iMp;
@property (nonatomic, strong) NSNumber *TA_iAllPoint;
@property (nonatomic, strong) NSNumber *iMarry;//婚否
@property (nonatomic, strong) NSNumber *iBeastSki1;
@property (nonatomic, strong) NSNumber *iExptSki3;
@property (nonatomic, strong) NSNumber *iPcktPage;
@property (nonatomic, strong) NSNumber *iOrgOffer;
@property (nonatomic, strong) NSNumber *iSumAmountEx;
@property (nonatomic, strong) NSNumber *iCash;//现金
@property (nonatomic, strong) NSNumber *iBeastSki4;//宠修
@property (nonatomic, strong) NSNumber *iMaxExpt1; //人物修上线
@property (nonatomic, strong) NSNumber *datang_feat;//三届功绩
@property (nonatomic, strong) NSNumber *energy;//精力
@property (nonatomic, strong) NSNumber *sum_exp;//经验
@property (nonatomic, strong) NSNumber *igoodness_sav;//储备善恶点
@property (nonatomic, strong) NSNumber *farm_level;
@property (nonatomic, strong) NSNumber *iMaxExpt4;
@property (nonatomic, strong) NSNumber *iSumAmount;
@property (nonatomic, strong) NSNumber *jiyuan;
@property (nonatomic, strong) NSNumber *iIcon;
@property (nonatomic, strong) NSNumber *ori_race;
@property (nonatomic, strong) NSNumber *iSpe_All;
@property (nonatomic, strong) NSNumber *iHp_Max;
@property (nonatomic, strong) NSNumber *iMarry2;
@property (nonatomic, strong) NSNumber *sword_score;
@property (nonatomic, strong) NSNumber *iDamage_All;
@property (nonatomic, strong) NSNumber *TA_iAllNewPoint;
@property (nonatomic, strong) NSNumber *iCor_All;
@property (nonatomic, strong) NSNumber *xianyu;
@property (nonatomic, strong) NSNumber *iSmithski;
@property (nonatomic, strong) NSNumber *iExptSki2;
@property (nonatomic, strong) NSNumber *iRace;
@property (nonatomic, strong) NSNumber *iBeastSki2;
@property (nonatomic, strong) NSNumber *iMp_Max;
@property (nonatomic, strong) NSNumber *iMagDef_All;
@property (nonatomic, strong) NSNumber *HeroScore;
@property (nonatomic, strong) NSNumber *iExptSki5;//猎术
@property (nonatomic, strong) NSNumber *iDex_All;
@property (nonatomic, strong) NSNumber *iHp;
@property (nonatomic, strong) NSNumber *rent;//房屋
@property (nonatomic, strong) NSNumber *iSkiPoint;
@property (nonatomic, strong) NSNumber *ExpJwBase;
@property (nonatomic, strong) NSNumber *iMaxExpt3;
@property (nonatomic, strong) NSNumber *iZhuanZhi;//专制
@property (nonatomic, strong) FabaoModel *fabao;
@property (nonatomic, strong) AllEquipModel *AllEquip;
@property (nonatomic, strong) ExAvtModel *ExAvt;
@property (nonatomic, strong) HugeHorseModel *HugeHorse;
@property (nonatomic, strong) More_attrModel *more_attr;
@property (nonatomic, strong) AllRiderModel *AllRider;
@property (nonatomic, strong) All_skillsModel *all_skills;
@property (nonatomic, strong) ChildModel *child;
@property (nonatomic, strong) ChildModel *child2;
@property (nonatomic, strong) PropKeptModel *propKept;//属性保存方案
@property (nonatomic, strong) NSMutableArray <ChangeschModel *> *changesch;
@property (nonatomic, strong) NSMutableArray <PetModel *> *pet;
@property (nonatomic, strong) NSMutableArray <AllSummonModel *> *AllSummon;//召唤兽
@property (nonatomic, strong) NSMutableArray <Idbid_descModel *> *idbid_desc;

@property (nonatomic, strong) NSString * buyPrice;//价格计算，当前仅计算空号价格
@property (nonatomic, strong) NSString * detailPrePrice;

//totalMoney = xiulian + chongxiu + qianyuandan + jineng + jingyan + youxibi + zhaohuanshou;
@property (nonatomic, assign) CGFloat xiulianPrice;
@property (nonatomic, assign) CGFloat chongxiuPrice;
@property (nonatomic, assign) CGFloat qianyuandanPrice;
@property (nonatomic, assign) CGFloat jinengPrice;
@property (nonatomic, assign) CGFloat jingyanPrice;
@property (nonatomic, assign) CGFloat youxibiPrice;
@property (nonatomic, assign) CGFloat zhaohuanPrice;
@property (nonatomic, assign) CGFloat zhuangbeiPrice;
@property (nonatomic, assign) CGFloat totalPrice;

-(NSString *)createExtraPrice;
-(NSString *)extraDes;
//化圣标识，通过修炼、等级、技能、宠修  综合判定
-(NSInteger)furtureMaxStatus;


/**
 *  Init the model with dictionary
 *
 *  @param dictionary dictionary
 *
 *  @return model
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
-(void)detailSubCheck;


@end

