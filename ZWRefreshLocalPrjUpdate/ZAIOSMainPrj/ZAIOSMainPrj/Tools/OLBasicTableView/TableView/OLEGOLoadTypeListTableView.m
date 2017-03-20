//
//  OLEGOLoadTypeListTableView.m
//  WebConnectPrj
//
//  Created by Apple on 15/2/12.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOLoadTypeListTableView.h"
//footer 相关
#import "OLEGOFooterAutoLoadControl.h"
#import "OLEGOFooterNormalControl.h"

#import "OLEGONormalFooterView.h"
#import "OLEGOCustomFooterView.h"
#import "OLEGOPullTextFooterView.h"
#import "OLEGOTapTextFooterView.h"

//header相关
#import "OLEGOHeaderNormalControl.h"
#import "OLEGONormalHeaderView.h"
#import "OLEGOCustomHeaderView.h"
#import "OLEGOFooterAndHeaderNoneControl.h"
@interface OLEGOLoadTypeListTableView()
{
    OL_EGOVIEW_TYPE startedViewType;
}
@property (nonatomic,assign) OL_EGOVIEW_TYPE loadMoreViewType;
@property (nonatomic,assign) BOOL effectiveMixed;
@end
@implementation OLEGOLoadTypeListTableView


-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        startedViewType = OL_EGOVIEW_TYPE_DRAG_TEXT;
        _loadMoreViewType = startedViewType;
        _effectiveHeight = 2500;
        _effectiveMixed = NO;
//        self.loadRefreshType = OL_LIST_DATA_LOAD_TYPE_NORMAL;
//        self.loadMoreType = OL_LIST_DATA_LOAD_TYPE_NORMAL;
    }
    return self;
}
//重写方法，以便适应新增变量
-(void)startLoadMoredDataInForcedWithViewAnimated:(BOOL)animated
{
    if(_loadMoreType==OL_LIST_DATA_LOAD_TYPE_NONE) return;
    [super startLoadMoredDataInForcedWithViewAnimated:animated];
}
-(void)startRefreshDataInForcedWithViewAnimated:(BOOL)animated
{
    if(_loadRefreshType==OL_LIST_DATA_LOAD_TYPE_NONE) return;
    [super startRefreshDataInForcedWithViewAnimated:animated];
}

-(void)setLoadMoreViewType:(OL_EGOVIEW_TYPE)type
{
    _loadMoreViewType = type;
    
    //重新创建footer
    //移除原视图
    [self.egoFooter removeFromSuperview];
    
    OLEGORefreshView * foot = [self footerViewForEGOType:type];
    self.egoFooter = foot;
    [self refreshListFooterViewControlForType:_loadMoreType];
    
    //重新启动加载更多，以便重置位置
    [self restartLoadMore];
}

-(void)doneLoadDataReloading
{
    [super doneLoadDataReloading];
    //检查containsize，此处没有判定加载的类型，所以在刷新时如果改变了内容高度，可以自动重置修改
    if (_loadMoreType == OL_LIST_DATA_LOAD_TYPE_MIXED_LOAD)
    {
        CGFloat height = self.contentSize.height;
        BOOL mixed = height>self.effectiveHeight?YES:NO;
        
        if (self.effectiveMixed!=mixed)
        {
            self.effectiveMixed =mixed;
            //刷新view
            self.loadMoreViewType = mixed?OL_EGOVIEW_TYPE_TAP_TEXT:startedViewType;
        }
    }
}

-(void)refreshListFooterViewControlForType:(OL_LIST_DATA_LOAD_TYPE)type
{
    
    //创建视图
    OLEGORefreshView * bottom = self.egoFooter;
    
    //设置变量
    CGFloat height = bottom.egoViewHeight;
    CGFloat endHeight = 0;
    
    switch (type) {
        case OL_LIST_DATA_LOAD_TYPE_NONE:
        {
            bottom.viewControl = nil;
        }
            break;
        case OL_LIST_DATA_LOAD_TYPE_AUTO_LOAD:
        case OL_LIST_DATA_LOAD_TYPE_TAPED_LOAD:
        case OL_LIST_DATA_LOAD_TYPE_MIXED_LOAD:
        {
            bottom.viewControl = [[OLEGOFooterAutoLoadControl alloc] init];
        }
            break;
        default:
            bottom.viewControl = [[OLEGOFooterNormalControl alloc] init];
            break;
    }
    
    if(type==OL_LIST_DATA_LOAD_TYPE_MIXED_LOAD)
    {
        //响应混合后部分的形式、混合前部分的形式
        type = self.effectiveMixed?OL_LIST_DATA_LOAD_TYPE_TAPED_LOAD:OL_LIST_DATA_LOAD_TYPE_AUTO_LOAD;
    }
    
    
    OLEGOFooterNormalControl * control = (OLEGOFooterNormalControl *)bottom.viewControl;
    //改变control状态
    switch (type)
    {
        case OL_LIST_DATA_LOAD_TYPE_NONE:
        {
            bottom.hidden = YES;
        }
            break;
        case OL_LIST_DATA_LOAD_TYPE_NORMAL:
        {
            control.effectiveHeight = height;
            control.defultedExtendY = endHeight;
            control.showExtendY = height;
            control.endExtendY = endHeight;
        }
            break;
        case OL_LIST_DATA_LOAD_TYPE_SHOW_LOAD:
        {
            control.effectiveHeight = height;
            control.defultedExtendY = height;
            control.showExtendY = height;
            control.endExtendY = height;
        }
            break;
        case OL_LIST_DATA_LOAD_TYPE_AUTO_LOAD:
        {
            control.effectiveHeight = -10;
            control.defultedExtendY = height;
            control.showExtendY = height;
            control.endExtendY = endHeight;
            control.backDelay = YES;
        }
            break;
        case OL_LIST_DATA_LOAD_TYPE_TAPED_LOAD:
        {
            control.effectiveHeight = MAXFLOAT;
            control.defultedExtendY = height;
            control.showExtendY = height;
            control.endExtendY = height;
        }
            break;
            
        default:
            break;
    }
}
-(OLEGORefreshView *)footerViewForEGOType:(OL_EGOVIEW_TYPE)type
{
    UIView * coverView = self;
    CGFloat height = MAX(self.contentSize.height, self.frame.size.height);
    
    CGRect rect = CGRectMake(0.0f, height,
                             coverView.frame.size.width, coverView.bounds.size.height);
    OLEGORefreshView * bottom = nil;
    {
        switch (type)
        {
            case OL_EGOVIEW_TYPE_NORMAL:{
                bottom = [[OLEGONormalFooterView alloc] initWithFrame:rect];
            }
                break;
            case OL_EGOVIEW_TYPE_CUSTOM:
            {
                bottom = [[OLEGOCustomFooterView alloc] initWithFrame:rect];
            }
                break;
            case OL_EGOVIEW_TYPE_DRAG_TEXT:
            {
                bottom = [[OLEGOPullTextFooterView alloc] initWithFrame:rect];
            }
                break;
            case OL_EGOVIEW_TYPE_TAP_TEXT:
            {
                bottom = [[OLEGOTapTextFooterView alloc] initWithFrame:rect];
            }
                break;
                
            default:
                break;
        }
    }
    return bottom;
}


-(void)setLoadMoreType:(OL_LIST_DATA_LOAD_TYPE)type
{
    _loadMoreType = type;
    //使用默认视图重置
    
    //创建新视图
    [self.egoFooter removeFromSuperview];
    
    OLEGORefreshView * foot = [self footerViewForEGOType:_loadMoreViewType];
    self.egoFooter = foot;
    [self refreshListFooterViewControlForType:type];
    
    //重新启动加载更多，以便重置位置
    [self restartLoadMore];
}



-(void)setLoadRefreshType:(OL_LIST_DATA_LOAD_TYPE)type
{
    _loadRefreshType = type;
    //使用默认视图重置
    [self.egoHeader removeFromSuperview];
    
    OLEGORefreshView * aHeader = [self listHeaderViewForType:type];
    self.egoHeader = aHeader;
}

//暂未实现headerview的变量设定，都使用默认值
-(OLEGORefreshView *)listHeaderViewForType:(OL_LIST_DATA_LOAD_TYPE)type
{
    //仅一种形式control，两种view
    UIView * coverView = self;
    OLEGORefreshView * topView = nil;
    
    CGRect rect = CGRectMake(0.0f, 0.0f - coverView.bounds.size.height,
                             coverView.bounds.size.width, coverView.bounds.size.height);
    
    switch (OL_EGOVIEW_TYPE_CUSTOM)
    {//默认使用custom形式
        case OL_EGOVIEW_TYPE_NORMAL:
            topView = [[OLEGONormalHeaderView alloc] initWithFrame:rect];
            break;
        case OL_EGOVIEW_TYPE_CUSTOM:
        default:
            topView = [[OLEGOCustomHeaderView alloc] initWithFrame:rect];
            break;
    }
    
    if (type==OL_LIST_DATA_LOAD_TYPE_NONE)
    {
        topView.viewControl = nil;
        topView.hidden = YES;
    }
    
    topView.backgroundColor = [UIColor clearColor];
    [coverView addSubview:topView];
    [topView setState:EGOOPullRefreshNormal];
    
    return topView;
}

@end
