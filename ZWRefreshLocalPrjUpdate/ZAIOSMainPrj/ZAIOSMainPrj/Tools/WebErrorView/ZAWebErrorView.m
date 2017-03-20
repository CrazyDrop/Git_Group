//
//  ZAWebErrorView.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/30.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAWebErrorView.h"

@interface ZAWebErrorView()
{
    UILabel * errorLbl;
    UILabel * retryLbl;
    
    UIActivityIndicatorView * loadingView;
    BOOL isLoading;
}


@end

@implementation ZAWebErrorView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.errTxt = @"网络异常，建议检测后";

        [self initSubViews];
        
        //增加事件，添加子视图
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnErrorViewForRetry:)];
        [self addGestureRecognizer:tap];
        
        
        isLoading = NO;
        self.backgroundColor = Custom_View_Gray_BGColor;
    }
    return self;
}

-(void)initSubViews
{
    CGRect rect = self.bounds;
    
    CGFloat centerY = CGRectGetMidY(rect);
    CGFloat centerX = CGRectGetMidX(rect);
    CGFloat imgHeight = FLoatChange(120);
    
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgHeight, imgHeight)];
    imgView.image = [UIImage imageNamed:@"connect_state_icon"];
    [self addSubview:imgView];
    
    
    CGFloat imgExtend = FLoatChange(15);
    imgView.center = CGPointMake(centerX, centerY - imgExtend - imgView.bounds.size.height/2.0);
    
    
    UIFont * font = [UIFont systemFontOfSize:FLoatChange(13)];
    
    NSString * txt = self.errTxt;
    UILabel * firstLbl = [[UILabel alloc] initWithFrame:rect];
    firstLbl.font = font;
    [self addSubview:firstLbl];
    firstLbl.text = txt;
    [firstLbl sizeToFit];
    firstLbl.textAlignment = NSTextAlignmentCenter;
    firstLbl.textColor = [UIColor grayColor];
    firstLbl.center = CGPointMake(centerX, centerY + firstLbl.bounds.size.height/2.0);
    errorLbl = firstLbl;
    
    UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:activity];
    activity.center = firstLbl.center;
    loadingView = activity;
    
    txt= @"点击屏幕重新加载";
    UILabel * aLbl = [[UILabel alloc] initWithFrame:rect];
    aLbl.font = font;
    aLbl.text = txt;
    [self addSubview:aLbl];
    [aLbl sizeToFit];
    aLbl.textAlignment = NSTextAlignmentCenter;
    aLbl.center = CGPointMake(centerX, centerY + aLbl.bounds.size.height + firstLbl.bounds.size.height);
    aLbl.textColor = Custom_Blue_Button_BGColor;
    retryLbl = aLbl;

    rect = errorLbl.frame;
    rect.origin.x = 0;
    rect.size.width = self.bounds.size.width;
    errorLbl.frame = rect;
}


-(void)tapedOnErrorViewForRetry:(id)sender
{
    if(isLoading) return;
    isLoading = YES;

    //视图改变
    if(self.ZAWebRequestRetryBlock)
    {
        self.ZAWebRequestRetryBlock();
    }
}

-(void)refreshErrorViewWithLoading:(BOOL)loading
{
    errorLbl.text = self.errTxt;
    
    isLoading = loading;
    if(loading)
    {
        errorLbl.hidden = YES;
        retryLbl.text = @"加载中..";
        [loadingView startAnimating];
    }else
    {
        errorLbl.hidden = NO;
        retryLbl.text = @"点击屏幕重新加载";
        [loadingView stopAnimating];
        
    }
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
