//
//  TextBottomButton.m
//  ShaiHuo
//
//  Created by 王晓宇 on 14-2-22.
//  Copyright (c) 2014年 CBSi. All rights reserved.
//

#import "TextBottomButton.h"

@implementation TextBottomButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel.font=[UIFont systemFontOfSize:11];
        self.titleLabel.textAlignment=NSTextAlignmentCenter;
        [self.titleLabel setClipsToBounds:false];
        [self setClipsToBounds:false];
        self.small = NO;
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if(!self.small)
    {
        self.imageView.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20);
        self.titleLabel.frame=CGRectMake(-5, self.frame.size.height-10, self.frame.size.width+10, 20);
        return;
    }
    CGFloat imgWidth = FLoatChange(36);
    self.imageView.frame=CGRectMake((self.frame.size.width - imgWidth)/2.0, 0, imgWidth, imgWidth);
    self.titleLabel.frame=CGRectMake(-5, self.frame.size.height-22, self.frame.size.width+10, 20);



//    [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 20, 0)];
//    [self setTitleEdgeInsets:UIEdgeInsetsMake(self.frame.size.height-20, 0, 0, 0)];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
