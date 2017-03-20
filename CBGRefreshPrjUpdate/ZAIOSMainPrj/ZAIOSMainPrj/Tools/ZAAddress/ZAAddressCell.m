//
//  ZAAddressCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAAddressCell.h"

@implementation ZAAddressCell

- (void)awakeFromNib
{
    // Initialization code
    UIView * btn = self.nameBGView;
    CALayer * layer = btn.layer;
    [layer setCornerRadius:btn.bounds.size.height/2.0];
    self.subNameLbl.backgroundColor = [UIColor clearColor];
    
    self.normalBGColor = [UIColor redColor];
//    [btn setBackgroundColor:[UIColor redColor]];
    
    self.phoneNumLbl.textColor = [UIColor grayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    [UIView animateWithDuration:0.2 animations:^{
        UIView * btn = self.nameBGView;
        UIColor * color = selected?[UIColor whiteColor]:self.normalBGColor;
        [btn setBackgroundColor:color];
        
        UIColor *txtColor = selected?[UIColor blackColor]:[UIColor whiteColor];
        self.subNameLbl.textColor = txtColor;
    }];

    
    // Configure the view for the selected state
}

@end
