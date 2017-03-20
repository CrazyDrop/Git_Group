//
//  ZAEveLineView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/23.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

//实现圆点，底线，以及文本切换
@interface ZAEveLineView : UIView

//选中
@property (nonatomic,assign,readonly) BOOL lineSelected;

//当txt为nil时，相当于不选中
-(void)refreshLineVewSelectedWithCurrentTxt:(NSString *)txt animated:(BOOL)animated;





@end
