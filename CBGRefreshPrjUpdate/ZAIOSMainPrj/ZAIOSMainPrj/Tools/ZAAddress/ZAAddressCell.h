//
//  ZAAddressCell.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZAAddressCell : UITableViewCell
@property (nonatomic,strong) UIColor * normalBGColor;
@property (weak, nonatomic) IBOutlet UILabel *subNameLbl;
@property (weak, nonatomic) IBOutlet UIView *nameBGView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLbl;

@end
