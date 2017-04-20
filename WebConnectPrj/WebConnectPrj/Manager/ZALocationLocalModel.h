//
//  ZALocationLocalModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseDataModel.h"
//位置信息model，需要copy
//数据处理逻辑，本地获取位置信息，直接本地保存
//本地数据取出
//本地数据清空
@class ZWDataDetailModel;
//@class CBGListModel;
@interface ZALocationLocalModel : BaseDataModel

@property (nonatomic, copy) NSString *longtitude;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *altitude;
@property (nonatomic, copy) NSString *scene;
@property (nonatomic, copy) NSString *priority;
@property (nonatomic, copy) NSString *timestamp;
//yyyy-mm-dd hh:MM:ss
@property (nonatomic, copy) NSDate * date;


@end

@interface ZALocationLocalModelManager:NSObject

+(instancetype)sharedInstance;

-(void)exchangeLocalDBWithCurrentDBPath:(NSString *)path;
//复制售出数据到新数据库
-(void)localCopySoldOutDataToPartDataBase;


-(NSArray *)localLocationsArrayForAppendingDB;
-(void)exchangeLocalSaveLocationsToSave;

//最近的一个model
-(ZWDataDetailModel *)latestLocationModel;

-(void)clearTotalSoldOutLocations;
-(void)clearTotalLocations;
-(void)clearUploadedLocations:(NSArray *)current;

-(void)localSaveDetailUpdateArray:(NSArray *)arr;
-(BOOL)localSaveCurrentLocation:(id)obj;
-(void)localSaveDisappearLocation:(id)obj;
-(NSArray *)localLocationsArrayForCurrent;


-(NSArray *)localTotalSaveEquipArray;
-(void)localSaveSoldOutEquipModelArray:(id)objArray;
-(NSArray *)localSaveEquipArrayForSoldOut_database;
-(NSArray *)localSaveEquipArrayForSoldOut;

//存储刷新 下单数据  ORDER表
-(void)localSaveMakeOrderArrayListDetailCBGModelArray:(NSArray *)arr;
-(NSArray *)localSaveMakeOrderHistoryListForOrderSN:(NSString *)ordersn;
-(NSArray *)localSaveMakeOrderHistoryListForRoleId:(NSString *)roleId;

//存储  刷新卖家变动数据  CHANGE表
-(void)localSaveUserChangeArrayListWithDetailCBGModelArray:(NSArray *)arr;
-(NSArray *)localSaveUserChangeHistoryListForOrderSN:(NSString *)ordersn;
-(NSArray *)localSaveUserChangeHistoryListForRoleId:(NSString *)roleId;

//存储数据  主表，更新状态，更新估价，新增记录，均可以
-(void)localSaveEquipHistoryArrayListWithDetailCBGModelArray:(NSArray *)array;
-(void)deleteLocalSaveEquipHistoryObjectWithCBGModelOrderSN:(NSString *)ordersn;
-(NSArray *)localSaveEquipHistoryModelListWithIngoreNumber:(NSInteger)number;
-(NSArray *)localSaveEquipHistoryModelListTotal;
-(NSArray *)localSaveEquipHistoryModelListEquipPriceError;
-(NSArray *)localSaveEquipHistoryModelListTotalWithSoldOut;
-(NSArray *)localSaveEquipHistoryModelListTotalWithUnFinished;
-(NSArray *)localSaveEquipHistoryModelListTotalWithPlanBuy;
-(NSArray *)localSaveEquipHistoryModelListTotalWithPlanFail;
-(NSArray *)localSaveEquipHistoryModelListForOrderSN:(NSString *)ordersn;
-(NSArray *)localSaveEquipHistoryModelListForTime:(NSString *)time;
-(NSArray *)localSaveEquipHistoryModelListForRoleId:(NSString *)roleId;
-(NSArray *)localSaveEquipHistoryModelListForServerId:(NSString *)server andSchool:(NSString *)school;
-(NSArray *)localSaveEquipHistoryModelListForCompareCBGModel:(id)model;
-(void)updateFavAndIngoreStateForMaxedPlanRateListAndClearChange;
-(NSArray *)localSaveEquipHistoryModelListRepeatSold;
-(NSArray *)localSaveEquipHistoryModelListOwnerList;

//服务器名称存储操作
-(NSArray *)localServerNameAndIDTotalDictionaryArray;
-(void)localSaveServerNameAndIDDictionaryArray:(NSArray *)array;
-(void)localSaveServerName:(NSString *)name withServerID:(NSInteger)serverId;

@end

