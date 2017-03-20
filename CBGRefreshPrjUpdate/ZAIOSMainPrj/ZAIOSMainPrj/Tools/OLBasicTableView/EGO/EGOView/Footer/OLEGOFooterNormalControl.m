//
//  OLEGOFooterNormalControl.m
//  WebConnectPrj
//
//  Created by Apple on 15/1/29.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOFooterNormalControl.h"

@implementation OLEGOFooterNormalControl
-(id)init
{
    self = [super init];
    if (self)
    {
        _backDelay = NO;
        _showExtendY = REFRESH_REGION_HEIGHT;
        _endExtendY = 0;
        _defultedExtendY = 0;
        _effectiveHeight = REFRESH_REGION_HEIGHT;
    }
    return self;
}



#pragma mark - OLEGOViewContorlDelegate

-(void)egoHeaderView:(OLEGORefreshView *)header scrollViewDidScrollForScrollView:(UIScrollView *)scrollView
{
    //	NSLog(@"egoRefreshScrollViewDidScroll scrollView.contentOffset.y= %f", scrollView.contentOffset.y);
    EGOPullRefreshState state = header.state;
    CGFloat bottomInset = header.startedInset.bottom;
    
    if (state == EGOOPullRefreshLoading)
    {
        
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = bottomInset+_showExtendY;
        scrollView.contentInset = inset;
        
    } else if (scrollView.isDragging)
    {
        CGFloat offset = MAX(scrollView.contentSize.height, scrollView.bounds.size.height);
        
        EGOPullRefreshState viewState = header.state;
        id viewDelegate = nil;
        BOOL _loading = NO;
        if ([viewDelegate respondsToSelector:@selector(egoRefreshTableDataSourceIsLoading:)]) {
            _loading = [viewDelegate egoRefreshTableDataSourceIsLoading:header];
        }
        
        if (scrollView.contentOffset.y <= 0.0f||_loading)
        {
            return;
        }
        //偏差距离
        CGFloat bottomLine = scrollView.contentOffset.y+scrollView.frame.size.height - offset;
        if (viewState == EGOOPullRefreshPulling &&
            bottomLine < _effectiveHeight ) {
            [header setState:EGOOPullRefreshNormal];
        } else if (viewState == EGOOPullRefreshNormal &&
                   bottomLine > _effectiveHeight) {
            [header setState:EGOOPullRefreshPulling];
        }
        
        //预设定缩进量
        CGFloat height = _defultedExtendY + header.startedInset.bottom;
        if (scrollView.contentInset.bottom!=height)
        {
            UIEdgeInsets inset = scrollView.contentInset;
            inset.bottom = height;
            scrollView.contentInset = inset;
        }
        
    }else{
        
        [header setState:EGOOPullRefreshNormal];
    }
}

-(void)egoHeaderView:(OLEGORefreshView *)header scrollViewDidEndDragingForScrollView:(UIScrollView *)scrollView
{
    BOOL _loading = NO;
    id controlDelegate = header.delegate;
    
    if (controlDelegate&&[controlDelegate respondsToSelector:@selector(egoRefreshTableDataSourceIsLoading:)])
    {
        _loading = [controlDelegate egoRefreshTableDataSourceIsLoading:header];
    }
    
    if (_loading)
    {
        return;
    }
    
    CGFloat offset = MAX(scrollView.contentSize.height, scrollView.bounds.size.height);
    
    //偏差距离
    CGFloat bottomLine = scrollView.contentOffset.y+scrollView.frame.size.height - offset;
    if (bottomLine>_effectiveHeight)
    {
        id viewDelegate = header.delegate;
        void(^delegateBlock)(void) = ^(void)
        {
            if ([viewDelegate respondsToSelector:@selector(egoRefreshTableDidTriggerRefresh:)]) {
                [viewDelegate egoRefreshTableDidTriggerRefresh:EGORefreshFooter];
            }
        };
        
        if (_backDelay)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                delegateBlock();
            });
        }else
        {
            delegateBlock();
        }
        
        [header setState:EGOOPullRefreshLoading];
        CGFloat height = _showExtendY+ header.startedInset.bottom;
        
        
        UIEdgeInsets inset = scrollView.contentInset;
        inset.bottom = height;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = inset;
        [UIView commitAnimations];
    }
    
}

-(void)egoHeaderView:(OLEGORefreshView *)footer doneReloadingScrollView:(UIScrollView *)scrollView andEndString:(NSString *)str
{
    [footer showEndLoadMoreWithString:str];
    
    CGFloat bottom = _endExtendY + footer.startedInset.bottom;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    UIEdgeInsets inset = scrollView.contentInset;
    inset.bottom = bottom;
    scrollView.contentInset = inset;
    [UIView commitAnimations];
    
    [footer setState:EGOOPullRefreshNormal];
}

@end
