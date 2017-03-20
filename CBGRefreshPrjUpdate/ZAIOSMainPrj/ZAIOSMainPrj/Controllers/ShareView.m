//
//  ShareView.m
//  Photography
//
//  Created by jialifei on 15/4/1.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "ShareView.h"
#import "DPViewController.h"
//#import "AlbumViewController.h"

@implementation ShareView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)creatShareItemWithImage:(UIImage *)img text:(NSString *)t frame:(CGRect)rect action:(SEL)act
{
    
    UIView *bg = [[UIView alloc] initWithFrame:rect];
    [bottom addSubview:bg];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height - 10 - 12)];
    iv.image = img;
    [bg addSubview:iv];
    
    UILabel *des = [[UILabel alloc] initWithFrame:CGRectMake(0, 50+10, rect.size.width, 12)];
    des.text = t;
    des.textAlignment = NSTextAlignmentCenter;
    des.font = [UIFont systemFontOfSize:10.0];
    [bg addSubview:des];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
//    btn.backgroundColor = [UIColor blackColor];
    [bg addSubview:btn];
    [btn addTarget:self action:act forControlEvents:UIControlEventTouchUpInside];
}


-(void)creatBottomBar
{
    UIView *v  = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 200)];
    v .alpha = 1.0;
    v .backgroundColor = [UIColor whiteColor];
    [self addSubview:v ];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 18, 100, 16)];
    [v addSubview:title];
    title.text = @"分享到";
    
    bottom = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 210)/2, 118/2, 450/2, 200 - 118/2)];
    [v addSubview:bottom];
   [self creatShareItemWithImage:[UIImage imageNamed:@"weichat"] text:@"微信好友" frame:CGRectMake(0, 0, 50, 50+10+12) action:@selector(shareWeiChat)];
    
    if ([_type isEqualToString:@"abl"]) {
        [self creatShareItemWithImage:[UIImage imageNamed:@"friends"] text:@"微信朋友圈" frame:CGRectMake(50+30, 0, 50, 50+10+12) action:@selector(shareSenceFriends)];
        [self creatShareItemWithImage:[UIImage imageNamed:@"bbs"] text:@"社区" frame:CGRectMake(50*2+60, 0, 50, 50+10+12) action:@selector(shareBBs)];
    }
    if ([_type isEqualToString:@"share"]) {
        [self creatShareItemWithImage:[UIImage imageNamed:@"friends"] text:@"微信朋友圈" frame:CGRectMake(50*2+60, 0, 50, 50+10+12) action:@selector(shareSenceFriends)];
       }
}

//-(void)shareBBs
//{
//    [(DPViewController *)_dp shareBBS];
//}
//
//-(void)shareWeiChat
//{
//    [(DPViewController *)_dp shareWeiChat];
//}
//
//-(void)shareSenceFriends
//{
//    [(DPViewController *)_dp shareSenceFriends];
//}

-(id)initWithFrame:(CGRect)frame type:(NSString *)type{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];;

        self.type = type;
        [self creatBottomBar];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [(AlbumViewController *)_dp dismissView];
}

@end
