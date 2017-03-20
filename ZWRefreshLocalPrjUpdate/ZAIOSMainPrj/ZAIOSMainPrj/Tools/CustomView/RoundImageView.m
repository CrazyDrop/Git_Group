//
//  RoundImageView.m
//  Photography
//
//  Created by jialifei on 15/4/5.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "RoundImageView.h"
#import "UIImageView+WebCache.h"

@implementation RoundImageView




-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.clipsToBounds = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
