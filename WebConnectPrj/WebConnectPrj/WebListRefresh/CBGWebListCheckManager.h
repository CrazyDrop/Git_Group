//
//  CBGWebListCheckManager.h
//  WebConnectPrj
//
//  Created by Apple on 17/3/25.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBGWebListCheckManager : NSObject

+(instancetype)sharedInstance;

@property (nonatomic,strong) NSArray * latestHistory;


@property (nonatomic,strong) NSArray * modelsArray;

//返回需要详情刷新的列表
@property (nonatomic,strong) NSArray * refreshArr;
-(NSArray *)checkLatestBackListDataModelsWithBackModelArray:(NSArray *)backArray;

//详情数据请求结束，数据model返回
@property (nonatomic,strong) NSArray * filterArray;
-(void)refreshDiskCacheWithDetailRequestFinishedArray:(NSArray *)array;

@end
