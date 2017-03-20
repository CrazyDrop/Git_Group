//
//  ZACircularSlider.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/15.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>
//进行修改
//1、屏蔽事件响应，完成倒计时  self.userInteractionEnabled = NO;
//2、实现滑动角度计数，改变现有固定角度计数
//3、实现圈数计数

//关联度数和分钟  外部实现
#import "TBCircularSlider.h"

@interface ZACircularSlider : UIControl

@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) CGFloat effectiveRadius;
//@property (nonatomic,assign) NSInteger extend;
@property (nonatomic,strong) UIColor * circleBGColor;//背景色  圆环部分


@property (nonatomic,assign) int angle;              //角度
@property (nonatomic,assign) int maxAngle;           //最大有效点位

//比例系数，时间与度数的比例，默认为 360  60 即  360度代表60分钟 1分钟占6度
@property (nonatomic,assign) CGFloat timeDegEx;      //1分钟所占的度数
@property (nonatomic,assign) NSInteger circleNum;    //一圈内响应的个数，默认为12个


@end
