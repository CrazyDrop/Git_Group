//
//  ZATabbarItemView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZATabbarItemView : UIView

@property (nonatomic,strong) UIView * bgView;
@property (nonatomic,strong) UIImageView * imgView;
@property (nonatomic,strong) UILabel * bottomLbl;
@property (nonatomic,strong) UILabel * topLbl;

-(void)refreshTransformForPersent:(CGFloat)persent;

@end
