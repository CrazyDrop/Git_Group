//
//  ZAStartLoginCell.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAStartLoginCell.h"

@implementation ZAStartLoginCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self refreshBottomLineColor];
    }
    return self;
}
-(void)refreshBottomLineColor
{
    self.bottomLine.backgroundColor = START_LOING_LINE_COLOR;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
