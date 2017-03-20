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
@interface ZWDetailCheckManager : NSObject

@property (nonatomic,strong) ZWCheckModel * localCheck;

+(instancetype)sharedInstance;

//处理刷新
-(void)refreshLatestCheckArray:(NSArray *)array withSecond:(NSInteger)index;


//刷新是否售罄，标识存储，缓存上次数据
-(void)refreshLatestTotalArray:(NSArray *)array;


@end
