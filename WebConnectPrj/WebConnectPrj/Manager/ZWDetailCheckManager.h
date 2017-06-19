//
//  ZWDetailCheckManager.h
//  ZAIOSMainPrj
//
//  Created by Apple on 16/4/21.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZWCheckModel;
//数据检查控制中心
//进行数据筛选，库表保存，数据返回
@interface ZWDetailCheckManager : NSObject
//check出现问题，或者出现请求后库表处理问题
+(instancetype)sharedInstance;

@property (nonatomic,strong) NSArray * latestHistory;  //缓存列表，进行展示

@property (nonatomic,strong) NSArray * modelsArray;

//屏蔽状态变更的网络请求//屏蔽强制刷新  屏蔽数据展示，库表操作继续
@property (nonatomic,assign) BOOL ingoreUpdate;
@property (nonatomic,assign) BOOL ingoreDB;

//库表刷新方法，进行数据库表保存
-(void)refreshLocalSaveDBListModelWithArray:(NSArray *)array;


//刷新数组，列表刷新的结果数组
@property (nonatomic,strong) NSArray * refreshArr;//内含价格变化，且价格非空的数据刷新

//返回需要详情刷新的列表
-(NSArray *)checkLatestBackListDataModelsWithBackModelArray:(NSArray *)array;
//-(void)refreshLocalDBHistoryWithLatestBackModelArr:(NSArray *)array;


//详情刷新的结果数组
@property (nonatomic,strong) NSArray * filterArray;
//数据详情请求结束时回调
-(void)refreshDiskCacheWithDetailRequestFinishedArray:(NSArray *)array;



//刷新标示
-(BOOL)refreshListRequestUpdate;


@end
