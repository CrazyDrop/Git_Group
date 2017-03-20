//
//  ZANumberCollectionCell.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/24.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZANumberCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (nonatomic,strong) UIColor * circleColor;

@property (nonatomic,strong) NSString * numberStr;
@property (nonatomic,strong) NSString * subStr;
@property (nonatomic,strong) NSString * redString;

@property (strong, nonatomic)  UIImageView * redIconImg;

@end
