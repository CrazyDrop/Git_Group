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

-(NSArray *)localLocationsArrayForAppendingDB;
-(void)exchangeLocalSaveLocationsToSave;

//最近的一个model
-(ZWDataDetailModel *)latestLocationModel;

-(void)clearTotalLocations;
-(void)clearUploadedLocations:(NSArray *)current;

-(void)localSaveDetailUpdateArray:(NSArray *)arr;
-(BOOL)localSaveCurrentLocation:(id)obj;
-(void)localSaveDisappearLocation:(id)obj;
-(NSArray *)localLocationsArrayForCurrent;


//保存 删除 查看
-(NSArray *)localSystemSellArray;
-(void)clearSystemSellArray:(NSArray *)current;
-(BOOL)localSaveSystemSellModel:(id)obj;


@end

