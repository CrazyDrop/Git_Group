//
//  OLWebView.m
//  OnlyLady
//
//  Created by Apple on 14-11-18.
//  Copyright (c) 2014年 CBSi女性时尚群组. All rights reserved.
//

#import "OLWebView.h"
@interface OLWebView()

@end

@implementation OLWebView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 30)];
        lbl.text = @"由www.onlylady.com提供";
        lbl.textColor = [DZUtils colorWithHex:@"868686"];
        lbl.font = [UIFont systemFontOfSize:13];
        lbl.textAlignment = NSTextAlignmentCenter;
        self.bgTitleLbl = lbl;
        
        
        UIView * aView = [[UIView alloc] initWithFrame:self.bounds];
        [aView addSubview:lbl];
        aView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        aView.backgroundColor = [UIColor whiteColor];
        self.bgView = aView;
        
        [self.scrollView insertSubview:self.bgView atIndex:0];
        self.scrollView.delegate = self;

    }

    return self;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.bgView.frame = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.bounds.size.width, scrollView.bounds.size.height);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
