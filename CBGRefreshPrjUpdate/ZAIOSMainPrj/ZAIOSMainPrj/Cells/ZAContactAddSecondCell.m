//
//  ZAContactAddSecondCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/23.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactAddSecondCell.h"

@implementation ZAContactAddSecondCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self updateCellSubViews];
    }
    return self;
}
-(void)updateCellSubViews
{
    CGRect rect = self.headerLbl.frame;
    
    CGFloat startX = rect.origin.x;
    CGFloat length = CGRectGetMaxX(rect) - startX;
    rect.size.width = length;
    
    self.editTfd.frame = rect;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
