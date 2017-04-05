//
//  ZWDataDetailModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/8.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDataModel.h"
@interface ZWDataDetailModel : BaseDataModel

//重新梳理变现区  购买利率  购买天数  计算公式
-(id)initWithRefreshDic:(NSDictionary *)dic;
+(NSArray *)dataArrayFromJsonArray:(NSArray *)array;


@property (nonatomic,strong) NSString * annual_rate_str;
@property (nonatomic,strong) NSString * duration_str;//总天数
@property (nonatomic,strong) NSString * updated_at;

@property (nonatomic,strong) NSString * total_money;
@property (nonatomic,strong) NSString * left_money;

@property (nonatomic,strong) NSString * earnRate; //收益利率
@property (nonatomic,strong) NSString * sellRate; //预计

//2016-04-26 13:02
@property (nonatomic,strong) NSString * start_sell_date;
@property (nonatomic,strong) NSString * created_at;
@property (nonatomic,strong) NSString * containDays;

//2016-04-26 05:15:56 +0000
@property (nonatomic,strong) NSString * finishedDate;   //售罄时间
@property (nonatomic,assign) NSInteger disappearNum;    //0为在售  2为售出后又出现  1为售出

@property (nonatomic,strong) NSString * startRate;      //
@property (nonatomic,strong) NSString * startMoney;
@property (nonatomic,strong) NSString * duration_total;//总天数
@property (nonatomic,strong) NSString * product_id;
@property (nonatomic,assign) BOOL rateUpdate;

+(void)startRateTest;
+(void)startDetailManagerTest;

-(DetailModelSaveType)currentModelState;

-(NSString * )currentEarnResultForSell;

//销售利率上涨，对应收益率的变化  (销售收益率每次变化0.05、至收益率达到15以下为止)
-(NSArray *)zwResultArrayForDifferentSellRate;

+(NSArray *)systemArrayFromLocalSave;

//利率不变，持有天数30天以上，每隔5天的数据(至收益率达到15以下为止)
+(NSArray *)zwResultArrayForContainDifferentDaysAndEarnRateWithModel:(id)dataModel withRefresh:(BOOL)refresh;

-(void)refreshStartState;

-(NSString *)resultTotalMoneyFromCurrentRate;   //通过金额计算利率
-(NSString *)startRateFromCurrentStartMoney;    //通过利率计算金额


@end
