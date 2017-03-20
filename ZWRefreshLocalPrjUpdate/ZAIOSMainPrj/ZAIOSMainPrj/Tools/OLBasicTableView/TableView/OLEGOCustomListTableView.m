//
//  OLEGOCustomListTableView.m
//  WebConnectPrj
//
//  Created by Apple on 15/1/30.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOCustomListTableView.h"
#import "OLEGONormalHeaderView.h"
#import "OLEGOCustomHeaderView.h"
#import "OLEGONormalFooterView.h"
#import "OLEGOCustomFooterView.h"
#import "OLEGOPullTextFooterView.h"
#import "OLEGOTapTextFooterView.h"
#import "OLEGOFooterNormalControl.h"
#import "OLEGOHeaderNormalControl.h"
@interface OLEGOCustomListTableView()<UITableViewDelegate,EGORefreshTableDelegate>
{
    BOOL _reloading;
    
    //判定已经没有数据可以加载，当前加载更多是否可用
    BOOL loadMoreAvailable;
    BOOL autoHideBottom;
    BOOL needRefreshInset;//设定是否需要刷新inset，重置egoview时需要设置

}
@property (nonatomic,assign) UIEdgeInsets startEdgeInsets;
@property (nonatomic,weak) id<UITableViewDelegate> olTableDelegate;
@end

@implementation OLEGOCustomListTableView
@synthesize olTableDelegate;
@synthesize hideEndLoadMoreView = _hideEndLoadMoreView;
-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        //判定子视图是否实现了相应的方法
        self.delegate = self;
        
        _maxAnimatedInterval = 8;
        _hideEndLoadMoreView = NO;
        _headerViewAboveInset = YES;
        loadMoreAvailable = YES;
        needRefreshInset = YES;
        _containPreContentInset = NO;
        //判定egoViewType形式,展示view
        
        //仅启动时设定，之后不使用默认的
        OLEGORefreshView * header = [self createHeaderViewForType:OL_EGOVIEW_TYPE_CUSTOM];
        self.egoHeader = header;
        
        OLEGORefreshView * footer = [self createFooterViewForType:OL_EGOVIEW_TYPE_DRAG_TEXT];
        self.egoFooter = footer;
        
        autoHideBottom = YES;
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshContentInset];
}



#pragma mark PublicMedhods
//取消加载结束
-(void)restartLoadMore
{
    //设置加载结束
    loadMoreAvailable = YES;
    
    [_egoFooter showEndLoadMoreWithString:nil];
    [self refreshFooterView];
}
//刷新上下拉控件的起始位置
-(void)refreshContentInset
{
    //如果不是第一次进入，并且之前有inset，那么不处理
    if (!needRefreshInset||!_containPreContentInset) {
        return;
    }
    
    needRefreshInset = NO;
    self.startEdgeInsets = self.contentInset;
    [self refreshForTopView];
}

//外部调用接口 启动刷新
-(void)startRefreshDataInForcedWithViewAnimated:(BOOL)animated{
    
    //如果父视图不存在，则没有刷新的必要
    if(!self.superview)  return;
    
    //鉴于此方法的调用，可能要早于layoutSubviews，而此时包含inset的情况出现异常,所以设置inset
    [self refreshContentInset];
    
    if(_reloading) [self doneLoadDataReloading];
    //开启动画
    if (animated) [self startTableViewLoadDataAnimatedForPos:EGORefreshHeader];
    [self beginToReloadData:EGORefreshHeader];
}

//启动加载
-(void)startLoadMoredDataInForcedWithViewAnimated:(BOOL)animated{
    if(!self.superview)  return;
    
    [self refreshContentInset];
    if(_reloading) [self doneLoadDataReloading];
    //开启动画
    if (animated) [self startTableViewLoadDataAnimatedForPos:EGORefreshFooter];
    [self beginToReloadData:EGORefreshFooter];
}
//结束加载更多，因网络异常
-(void)doneLoadDataReloadingWithAnimationDelay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doneLoadDataReloading];
    });
}

-(void)doneLoadDataReloading
{
    [self doneLoadDataReloadingAndEndLoadMoreWithString:nil];
}
-(void)doneLoadDataReloadingAndEndLoadMoreWithString:(NSString *)str
{
    //停止最终动画结束的调用
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doneLoadDataReloading) object:nil];
    
    //如果调用结束为启动请求调用
    //重置为起始位置
    [self refreshFooterView];
    
    //    标识已经有数据可以加载更多
    CGSize contain = self.contentSize;
    CGFloat viewHeight = self.tableHeaderView.bounds.size.height+self.tableFooterView.bounds.size.height;
    BOOL effective = (contain.height>10&&contain.height>viewHeight)?YES:NO;
    //针对不使用刷新方法的适应
    autoHideBottom =  !effective;
    
    //原本没启动，直接停止
    if (!_reloading) return;
    
    
    BOOL containMore = !str?YES:NO;
    loadMoreAvailable = containMore;
    
    
    OLEGORefreshView * bottomView = self.egoFooter;
    if (effectiveEGO==EGORefreshHeader)
    {
        OLEGORefreshView * topView = self.egoHeader;
        [topView egoRefreshScrollViewDataSourceDidFinishedLoading:self andEndString:str];
        autoHideBottom = !effective;

        
    }else
    {
        autoHideBottom = NO;
        [bottomView egoRefreshScrollViewDataSourceDidFinishedLoading:self andEndString:str];
    }
    [self refreshFooterView];
    
    _reloading = NO;
}
#pragma mark -
#pragma mark PrivateMethods

-(void)setEgoFooter:(OLEGORefreshView *)view
{
    if(_egoFooter!=nil)
    {
        [_egoFooter removeFromSuperview];
        _egoFooter = nil;
    }

    _egoFooter = view;
    _egoFooter.delegate = self;
    [self addSubview:view];
    [self refreshFooterView];
}
-(void)setEgoHeader:(OLEGORefreshView *)view
{
    if(_egoHeader!=nil)
    {
        [_egoHeader removeFromSuperview];
        _egoHeader = nil;
    }
    
    _egoHeader = view;
    _egoHeader.delegate = self;
    [self addSubview:view];
    [self refreshForTopView];
}

-(void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if (delegate!=self)
    {
        olTableDelegate = delegate;
        return;
    }
    //设置delegate
    [super setDelegate:delegate];
}
-(void)startTableViewLoadDataAnimatedForPos:(EGORefreshPos)type
{
    switch (type) {
        case EGORefreshHeader:
        {
            OLEGORefreshView * topView = self.egoHeader;
            //ContentOffset 在归零contentInset时自动归零了，不需要再设置
            [topView setState:EGOOPullRefreshLoading];
            UIEdgeInsets inset = self.startEdgeInsets;
            inset.top += REFRESH_REGION_HEIGHT;
            [UIView animateWithDuration:0.2 animations:^{
                        self.contentInset = inset;
            }];
            
            [self setContentOffset:CGPointMake(0, -inset.top) animated:YES];
            break;
        }
        case EGORefreshFooter:
        {
            OLEGORefreshView * bottomView = self.egoFooter;
            [bottomView setState:EGOOPullRefreshLoading];
            //设定inset的bottom
            UIEdgeInsets inset = self.startEdgeInsets;
            inset.bottom += REFRESH_LOADMORE_END_HEIGHT;
            [UIView animateWithDuration:0.2 animations:^{
                self.contentInset = inset;
            }];
            
            CGFloat maxHeight = MAX(self.bounds.size.height, self.contentSize.height);
            CGFloat bottom = self.contentInset.bottom;
            CGFloat startY = maxHeight + bottom - self.bounds.size.height;
            [self setContentOffset:CGPointMake(0, startY) animated:YES];
            
            break;
        }
        default:
            break;
    }
}
-(void)refreshForTopView
{
    //普通的处理
    CGFloat topHeight = _startEdgeInsets.top;
    OLEGORefreshView * topView = _egoHeader;
    topView.startedInset = self.startEdgeInsets;
    
    if (_egoHeader.stayBelow)
    {//针对保持底部的特殊处理
        CGRect rect = self.frame;
        rect.size.height-= topHeight;
        rect.origin.y += topHeight;
        
        UIView * head = self.egoHeader;
        head.frame = rect;
        [self.superview insertSubview:head belowSubview:self];
    }else
    {
        if (_headerViewAboveInset&&topHeight>0)
        {
            CGRect rect = topView.frame;
            CGFloat startY = - self.bounds.size.height - topHeight;
            rect.origin.y = startY;
            topView.frame = rect;
        }
    }
    

}
-(void)refreshFooterView
{
    OLEGORefreshView * bottomView = self.egoFooter;
    
    UIView * coverView = self;
    CGFloat height = MAX(self.contentSize.height, self.frame.size.height);
    // reset position
    bottomView.frame = CGRectMake(0.0f,
                               height,
                               coverView.frame.size.width,
                               coverView.bounds.size.height);
}
-(OLEGORefreshView *)createFooterViewForType:(OL_EGOVIEW_TYPE)type
{
    UIView * coverView = self;
    CGFloat height = MAX(self.contentSize.height, self.frame.size.height);
    
    OLEGORefreshView * bottom = nil;
    {
        switch (type)
        {
            case OL_EGOVIEW_TYPE_NORMAL:{
                bottom = [[OLEGONormalFooterView alloc] initWithFrame:
                          CGRectMake(0.0f, height,
                                     coverView.frame.size.width, coverView.bounds.size.height)];
            }
                break;
            case OL_EGOVIEW_TYPE_CUSTOM:
            {
                bottom = [[OLEGOCustomFooterView alloc] initWithFrame:
                          CGRectMake(0.0f, height,
                                     coverView.frame.size.width, coverView.bounds.size.height)];
            }
                break;
            case OL_EGOVIEW_TYPE_DRAG_TEXT:
            {
                bottom = [[OLEGOPullTextFooterView alloc] initWithFrame:
                          CGRectMake(0.0f, height,
                                     coverView.frame.size.width, coverView.bounds.size.height)];
            }
                break;
            case OL_EGOVIEW_TYPE_TAP_TEXT:
            {
                bottom = [[OLEGOTapTextFooterView alloc] initWithFrame:
                          CGRectMake(0.0f, height,
                                     coverView.frame.size.width, coverView.bounds.size.height)];
            }
                break;

            default:
                break;
        }
    }

    
    //设置变量
    bottom.delegate = self;
    [coverView addSubview:bottom];
    [self refreshFooterView];
    return bottom;
}
-(OLEGORefreshView *)createHeaderViewForType:(OL_EGOVIEW_TYPE)type
{
    UIView * coverView = self;
    OLEGORefreshView * topView = nil;
    switch (type)
    {
        case OL_EGOVIEW_TYPE_NORMAL:
            topView = [[OLEGONormalHeaderView alloc] initWithFrame:
                       CGRectMake(0.0f, 0.0f - coverView.bounds.size.height,
                                  coverView.bounds.size.width, coverView.bounds.size.height)];
            break;
        case OL_EGOVIEW_TYPE_CUSTOM:
        default:
            topView = [[OLEGOCustomHeaderView alloc] initWithFrame:
                       CGRectMake(0.0f, 0.0f - coverView.bounds.size.height,
                                  coverView.bounds.size.width, coverView.bounds.size.height)];
            break;
    }
    
    topView.delegate = self;
    topView.backgroundColor = [UIColor clearColor];
    [coverView addSubview:topView];
    [topView setState:EGOOPullRefreshNormal];
    [self refreshForTopView];
    return topView;
}
-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    
    //  should be calling your tableviews data source model to reload
    _reloading = YES;
    effectiveEGO = aRefreshPos;
    
    CGFloat maxInterval = self.maxAnimatedInterval;
    if (aRefreshPos == EGORefreshHeader)
    {
        if (self.loadRefreshNewDataBlock)
        {
            self.loadRefreshNewDataBlock(self);
        }
        
        if (self.loadDataDelegate&&[self.loadDataDelegate respondsToSelector:@selector(basicTableView:startRefreshDataForType:)])
        {
            [self.loadDataDelegate basicTableView:self startRefreshDataForType:OL_LIST_DATA_LOAD_TYPE_NORMAL];
        }
        // pull down to refresh data
        
        [self performSelector:@selector(doneLoadDataReloading) withObject:nil afterDelay:maxInterval];
        
    }else if(aRefreshPos == EGORefreshFooter)
    {
        if (self.loadMoreDataBlock) {
            self.loadMoreDataBlock(self);
        }
        if (self.loadDataDelegate&&[self.loadDataDelegate respondsToSelector:@selector(basicTableView:startLoadMoreDataForType:)]) {
            [self.loadDataDelegate basicTableView:self startLoadMoreDataForType:OL_LIST_DATA_LOAD_TYPE_NORMAL];
        }
        // pull up to load more data
        [self performSelector:@selector(doneLoadDataReloading) withObject:nil afterDelay:maxInterval];
        
    }
    
}
#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    [self beginToReloadData:aRefreshPos];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

// if we don't realize this method, it won't display the refresh timestamp
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
    
    return [NSDate date]; // should return date data source was last changed
}
#pragma mark -
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [olTableDelegate scrollViewDidScroll:scrollView];
    }
    
    //当一方处理加载状态，停止接收事件响应
    if (_reloading)
    {
        return;
    }

    //处理部
    OLEGORefreshView * topView = self.egoHeader;
    [topView egoRefreshScrollViewDidScroll:scrollView];
    

    //处理底部
    OLEGORefreshView * bottomView = self.egoFooter;
    if ((!loadMoreAvailable&&_hideEndLoadMoreView)||autoHideBottom)
    {
        bottomView.hidden = YES;
    }else if (loadMoreAvailable)
    {
        bottomView.hidden = NO;
        [bottomView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [olTableDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    if (_reloading)
    {
        return;
    }
    
    //停止接收事件响应,仅针对已经开始载入的情况开启结束处理
    [_egoHeader egoRefreshScrollViewDidEndDragging:scrollView];
    [_egoFooter egoRefreshScrollViewDidEndDragging:scrollView];

    
    
}


//以下仅设置默认值
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        
        [olTableDelegate scrollViewWillBeginDragging:scrollView];
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(olTableDelegate&&[olTableDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
        [olTableDelegate scrollViewDidEndDecelerating:scrollView];
    
}// called when scroll view grinds to a halt

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if(olTableDelegate&&[olTableDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
        [olTableDelegate scrollViewDidEndScrollingAnimation:scrollView];
}// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [olTableDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return tableView.rowHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        [olTableDelegate tableView:tableView heightForHeaderInSection:section];
    }
    return 0.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        [olTableDelegate tableView:tableView heightForFooterInSection:section];
    }
    return 0.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [olTableDelegate tableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}// custom view for header. will be adjusted to default or specified header height
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        [olTableDelegate tableView:tableView viewForFooterInSection:section];
    }
    return nil;
}// custom view for footer. will be adjusted to default or specified footer height
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        return  [olTableDelegate tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return indexPath;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        return  [olTableDelegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    return indexPath;
}//    NS_AVAILABLE_IOS(3_0);

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [olTableDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (olTableDelegate&&[olTableDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [olTableDelegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}//NS_AVAILABLE_IOS(3_0)
#pragma mark -
@end
