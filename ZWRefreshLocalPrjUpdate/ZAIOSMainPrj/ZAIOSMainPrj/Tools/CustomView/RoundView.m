//
//  RoundView.m
//  Photography
//
//  Created by jialifei on 15/4/10.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "RoundView.h"

@implementation RoundView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)init
{
    self = [super init];
    if (self) {
        [self.layer setCornerRadius:5.0];
    }
    return self;
}

@end
