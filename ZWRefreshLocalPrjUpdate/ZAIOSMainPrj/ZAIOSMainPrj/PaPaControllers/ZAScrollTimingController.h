//
//  ZAScrollTimingController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"
//新版本的主界面，内部控制倒计时页面和紧急模式页面
//1、使用scrollview控制，以便可能的跟随滑动
//2、不包含底部的滚动数据，作为tabbar的唯一子类使用
//3、
@interface ZAScrollTimingController : DPWhiteTopController
{
    
}

-(void)scrollContainViewWithTimingString:(NSString *)str;






@end
