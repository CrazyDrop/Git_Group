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

//数据缓存原则，仅存储最新的300条数据，超过则清空早进入的
@interface ZWDetailCheckManager : NSObject

+(instancetype)sharedInstance;

@property (nonatomic,strong) NSArray * urlsArray;

@property (nonatomic,strong) NSArray * refreshArray;

-(NSArray *)latestRequestDetailModelsWithCurrentBackModelArray:(NSArray *)array;

@end
