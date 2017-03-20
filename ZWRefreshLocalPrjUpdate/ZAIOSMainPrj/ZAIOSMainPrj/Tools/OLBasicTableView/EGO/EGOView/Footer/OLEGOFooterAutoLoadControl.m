//
//  OLEGOFooterAutoLoadControl.m
//  WebConnectPrj
//
//  Created by Apple on 15/1/29.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOFooterAutoLoadControl.h"
@interface OLEGOFooterAutoLoadControl()
{
    BOOL _waiting;
}
@end
@implementation OLEGOFooterAutoLoadControl

-(id)init
{
    self = [super init];
    if (self)
    {
        _waiting = NO;
        _backDelay = NO;
        _showExtendY = REFRESH_LOADMORE_END_HEIGHT;
        _endExtendY = REFRESH_LOADMORE_END_HEIGHT;
        _defultedExtendY = REFRESH_LOADMORE_END_HEIGHT;
        _effectiveHeight = 10;
    }
    return self;
}
//

-(void)egoHeaderView:(OLEGORefreshView *)header scrollViewDidScrollForScrollView:(UIScrollView *)scrollView
{
    
    if (scrollView.contentOffset.y <= 0.0f||_waiting)
    {
        return;
    }
    
    BOOL _loading = NO;
    id viewDelegate = header.delegate;
    if ([viewDelegate respondsToSelector:@selector(egoRefreshTableDataSourceIsLoading:)]) {
        _loading = [viewDelegate egoRefreshTableDataSourceIsLoading:header];
    }
    
    if (_loading)
    {
        return;
    }
    
    if(scrollView.isDragging)
    {
        //设置默认缩进量
        CGFloat height = _defultedExtendY + header.startedInset.bottom;
        if (scrollView.contentInset.bottom!=height)
        {
            UIEdgeInsets inset = scrollView.contentInset;
            inset.bottom = height;
            scrollView.contentInset = inset;
        }
    }
    
    EGOPullRefreshState state = header.state;
    CGFloat offset = MAX(scrollView.contentSize.height, scrollView.bounds.size.height);
    
    //偏差距离
    CGFloat bottomLine = scrollView.contentOffset.y+scrollView.frame.size.height - offset - _defultedExtendY;
    if (state == EGOOPullRefreshLoading)
    {
        CGFloat height = _showExtendY + header.startedInset.bottom;
        UIEdgeInsets inset = scrollView.contentInset;
        inset.bottom = height;
        scrollView.contentInset = inset;
        
    }
    else  if (bottomLine>_effectiveHeight)
    {
        //一旦大于界限值，启动请求
        void(^delegateBlock)(void) = ^(void) {
            _waiting = NO;
            if ([viewDelegate respondsToSelector:@selector(egoRefreshTableDidTriggerRefresh:)]) {
                [viewDelegate egoRefreshTableDidTriggerRefresh:EGORefreshFooter];
            }
        };
        
        if (self.backDelay)
        {
            _waiting = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                delegateBlock();
            });
        }else
        {
            delegateBlock();
        }
        
        
        
        [header setState:EGOOPullRefreshLoading];
        
        CGFloat height = _showExtendY + header.startedInset.bottom;
        UIEdgeInsets inset = scrollView.contentInset;
        inset.bottom = height;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = inset;
        [UIView commitAnimations];

    }else
    {
        [header setState:EGOOPullRefreshNormal];
    }
}

-(void)egoHeaderView:(OLEGORefreshView *)header scrollViewDidEndDragingForScrollView:(UIScrollView *)scrollView
{
    //自动加载的情况下，不需要在响应事件
    
}



@end
