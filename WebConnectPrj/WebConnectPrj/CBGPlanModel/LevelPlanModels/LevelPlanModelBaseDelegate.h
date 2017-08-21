//
//  LevelPlanModelBaseDelegate.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  LevelPlanModelBaseYouxibiRateForMoney  1300.0*100
@class EquipExtraModel;
@protocol LevelPlanPriceBackDelegate <NSObject>

-(CGFloat)price_xiulianWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_chongxiuWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_jinengWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_jingyanWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_qiannengguoWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_qianyuandanWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_dengjiWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_jiyuanWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_menpaiWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_fangwuWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_xianjinWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_haiziWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_xiangruiWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_zuojiWithExtraModel:(EquipExtraModel *)extraModel;
-(CGFloat)price_fabaoWithExtraModel:(EquipExtraModel *)extraModel;

@end

@interface LevelPlanModelBaseDelegate : NSObject<LevelPlanPriceBackDelegate>


+(id <LevelPlanPriceBackDelegate>)selectPlanModelFromExtraModel:(EquipExtraModel *)model;




@end
