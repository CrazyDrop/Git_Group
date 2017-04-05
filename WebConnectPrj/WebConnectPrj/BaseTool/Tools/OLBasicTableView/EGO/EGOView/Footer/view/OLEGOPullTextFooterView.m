//
//  OLEGOPullTextFooterView.m
//  WebConnectPrj
//
//  Created by Apple on 15/1/30.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOPullTextFooterView.h"
#import "OLEGOFooterNormalControl.h"
@interface OLEGOPullTextFooterView()
@property (nonatomic,strong)	UILabel *statusLabel;
@property (nonatomic,strong)	UIActivityIndicatorView *activityView;
@end

@implementation OLEGOPullTextFooterView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        [self initPreViews];
        
        self.egoViewHeight = REFRESH_LOADMORE_END_HEIGHT+10;
    }
    return self;
}
-(void)initPreViews
{
    UIColor * textColor = [UIColor grayColor];
    UILabel *label  = nil;
    
    CGFloat topHeight = 20;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0, self.frame.size.width, 30.0f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:13.0f];
    label.textColor = textColor;
    label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    [self addSubview:label];
    _statusLabel=label;
    
    CGPoint pt = label.center;
    pt.y = topHeight;
    label.center = pt;

    //控制加载结束的位置
    _endLoadLbl.textColor = textColor;
    _endLoadLbl.center = pt;
    _endLoadLbl.font = label.font;
    
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    view.hidesWhenStopped = YES;
    view.frame = CGRectMake(25.0f, 20.0f, 20.0f, 20.0f);
    [self addSubview:view];
    _activityView = view;
    
    pt.x = 100;
    view.center = pt;
    
    [self setState:EGOOPullRefreshNormal];
}

- (void)setState:(EGOPullRefreshState)aState{
    
    switch (aState) {
        case EGOOPullRefreshPulling:
            
            _statusLabel.text = @"松开加载更多";
            
            break;
        case EGOOPullRefreshNormal:
            
            _statusLabel.text = @"上拉加载更多";
            [_activityView stopAnimating];

            
            break;
        case EGOOPullRefreshLoading:
            
            _statusLabel.text = @"加载中...";
            [_activityView startAnimating];
            
            break;
        default:
            break;
    }
    
    _state = aState;
}




@end
