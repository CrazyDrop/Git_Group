//
//  DPTableViewCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPTableViewCell.h"

@implementation DPTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}
-(void)loadCellData:(id)sender
{
    NSLog(@"%s 重写此方法，进行cell数据载入",__FUNCTION__);
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

////此方法和下面的方法很重要,对ios 5SDK 设置不被Helighted
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    // Configure the view for the selected state
//    UIView *vMenuView = [self.contentView viewWithTag:100];
//    if (vMenuView.hidden == YES) {
//        [super setSelected:selected animated:animated];
//        self.backgroundColor = [UIColor whiteColor];
//    }
//}
//此方法和上面的方法很重要，对ios 5SDK 设置不被Helighted
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
//    UIView *vMenuView = [self.contentView viewWithTag:100];
//    if (vMenuView.hidden == YES) {
//        [super setHighlighted:highlighted animated:animated];
//    }
}


@end
