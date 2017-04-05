//
//  TimeRefreshManager.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
//新建父类，作为同意的倒计时父类使用
//使用时，创建子类，并使用子类的单利

//block
typedef void (^RefreshFunctionBlock)(void);

@interface TimeRefreshManager : NSObject

@property (nonatomic,assign,readonly) BOOL isRefreshing;

//功能block
@property (nonatomic,strong) RefreshFunctionBlock funcBlock;

//NSUserdefault中保存的key值
@property (nonatomic,strong) NSString * userDefaultIndentifyStr;

//调用间隔
@property (nonatomic,assign) NSTimeInterval functionInterval;

//刷新间隔
@property (nonatomic,assign) NSTimeInterval refreshInterval;

//设定起始时间，并开始
-(void)saveCurrentAndStartAutoRefresh;

//清空起始时间，并结束
-(void)endAutoRefreshAndClearTime;


//到达时间刷新
-(void)startAutoRefresh;

//关闭时间刷新
-(void)stopAutoRefresh;

//结束当前循环周期，并记录时间
-(void)finishFunctionAndSaveCurrentTime;


-(BOOL)localTimeNeedRefreshCheck;

//关闭所有倒计时
+(void)stopCurrentAllRefreshManager;


@end
