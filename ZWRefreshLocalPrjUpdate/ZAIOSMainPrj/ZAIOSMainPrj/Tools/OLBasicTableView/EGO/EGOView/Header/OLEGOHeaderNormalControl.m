//
//  OLEGOHeaderNormalControl.m
//  WebConnectPrj
//
//  Created by Apple on 15/1/29.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOHeaderNormalControl.h"
#import "OLEGORefreshView.h"
@implementation OLEGOHeaderNormalControl

-(void)egoHeaderView:(OLEGORefreshView *)header scrollViewDidScrollForScrollView:(UIScrollView *)scrollView
{
    //	NSLog(@"egoRefreshScrollViewDidScroll scrollView.contentOffset.y= %f", scrollView.contentOffset.y);
    EGOPullRefreshState state = header.state;
    CGFloat topInset = header.startedInset.top;
    
    if (state == EGOOPullRefreshLoading)
    {
        
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = topInset+REFRESH_REGION_HEIGHT;
        scrollView.contentInset = inset;
        
    } else if (scrollView.isDragging)
    {
        
        BOOL _loading = NO;
        id controlDelegate = header.delegate;
        if (controlDelegate&&[controlDelegate respondsToSelector:@selector(egoRefreshTableDataSourceIsLoading:)])
        {
            _loading = [controlDelegate egoRefreshTableDataSourceIsLoading:header];
        }
        
        if(!_loading)
        {//可以进行加载，当前无加载中
            CGFloat effectLineY = scrollView.contentOffset.y + topInset;
            
            if (state == EGOOPullRefreshPulling && effectLineY > -65.0f) {
                [header setState:EGOOPullRefreshNormal];
            } else if (state == EGOOPullRefreshNormal && effectLineY < -65.0f ) {
                [header setState:EGOOPullRefreshPulling];
            }
        }
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
    
    CGFloat effectLineY = scrollView.contentOffset.y + scrollView.contentInset.top;
    if (effectLineY <= - REFRESH_REGION_HEIGHT && !_loading)
    {
        
        if ([controlDelegate respondsToSelector:@selector(egoRefreshTableDidTriggerRefresh:)]) {
            [controlDelegate egoRefreshTableDidTriggerRefresh:EGORefreshHeader];
        }
        
        [header setState:EGOOPullRefreshLoading];
        
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = header.startedInset.top + REFRESH_REGION_HEIGHT;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = inset;
        [UIView commitAnimations];
        
    }else {
        //重置为normal
        [header setState:EGOOPullRefreshPulling];
        [header setState:EGOOPullRefreshNormal];
        
    }
    
}

-(void)egoHeaderView:(OLEGORefreshView *)header doneReloadingScrollView:(UIScrollView *)scrollView andEndString:(NSString *)str
{
    //可以使用此处控制刷新时间间隔
//    [header showEndLoadMoreWithString:str];
    
    CGFloat top = header.startedInset.top;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top = top;
    scrollView.contentInset = inset;
    [UIView commitAnimations];
    
    [header setState:EGOOPullRefreshNormal];
}

@end
