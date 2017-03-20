//
//  ZALineNumberView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/26.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>
//完成个数设定，展示当前设定了几个数字

@interface ZALineNumberView : UIView


@property (nonatomic,assign) NSInteger currentIndex;  //当前序号
@property (nonatomic,assign) NSInteger totalNum;      //总数目

@property (nonatomic,strong) UIColor * selectedColor; //选中颜色，默认绿色
@property (nonatomic,strong) UIColor * circleColor;   //未选中边框颜色

@property (nonatomic,assign) CGFloat radius;




@end
