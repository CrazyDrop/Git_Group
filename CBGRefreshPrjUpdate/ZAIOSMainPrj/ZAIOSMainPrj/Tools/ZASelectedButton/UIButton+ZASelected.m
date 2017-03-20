//
//  UIButton+ZASelected.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/2.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "UIButton+ZASelected.h"
#import "Samurai_Image.h"

@implementation UIButton(ZASelected)

-(void)refreshZASelectedButtonWithCurrentBGColor:(UIColor *)color
{
    self.clipsToBounds = YES;
    
    //刷新背景色
    //当背景色为统一蓝色时，直接刷新
    
    //当蓝色时，直接刷新
//    if(CustomBlueColor)
    {
        UIImage * img = [UIImage imageWithColor:color];
        [self setBackgroundImage:img forState:UIControlStateNormal];
    }
}


-(void)refreshButtonSelectedBGColor
{
    self.clipsToBounds = YES;
    
    //刷新背景色
    //当背景色为统一蓝色时，直接刷新
    UIColor * color = self.backgroundColor;
    BOOL CustomBlueColor = CGColorEqualToColor(color.CGColor,Custom_Blue_Button_BGColor.CGColor);
    
    //当蓝色时，直接刷新
    if(CustomBlueColor)
    {
        UIImage * img = [UIImage imageWithColor:Custom_Blue_Button_BGColor];
        [self setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    //退出登录按钮颜色，暂不使用
//    Setting_Btn_Dark_Color
    
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
