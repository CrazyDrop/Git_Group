//
//  OLEGOTapTextFooterView.m
//  WebConnectPrj
//
//  Created by Apple on 15/1/30.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOTapTextFooterView.h"
#import "OLEGOFooterAutoLoadControl.h"
@implementation OLEGOTapTextFooterView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.egoViewHeight = REFRESH_LOADMORE_END_HEIGHT;
        
    }
    return self;
}
- (void)setState:(EGOPullRefreshState)aState
{
    
    switch (aState) {
        case EGOOPullRefreshPulling:
            
//            _statusLabel.text = @"松开加载更多";
            
            break;
        case EGOOPullRefreshNormal:
            
            _statusLabel.text = @"点击加载更多";
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
