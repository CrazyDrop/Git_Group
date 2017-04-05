//
//  OLEGORefreshView.m
//  WebConnectPrj
//
//  Created by Apple on 15/1/29.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGORefreshView.h"
#import "OLEGOFooterNormalControl.h"
#import "OLEGOFooterAutoLoadControl.h"
@interface OLEGORefreshView()
{
    CGFloat preEffectiveHeight;
    BOOL tapedStarted;
}
//控制事件的响应变量判定
@property (nonatomic,weak) id<OLEGOViewContorlDelegate> controlDelegate;

@end;
@implementation OLEGORefreshView
@synthesize  viewControl=_viewControl;
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //创建通用的加载结束视图
        //创建视图
        preEffectiveHeight = 0;
        tapedStarted = NO;
        _stayBelow = NO;
        _egoViewHeight = 0;
        
        CGRect rect = self.bounds;
        UIView * aView = [[UIView alloc] initWithFrame:rect];
        aView.backgroundColor =[UIColor whiteColor];
        [self addSubview:aView];
        _endLoadView = aView;
        aView.hidden = YES;
        
        rect.size.height = REFRESH_REGION_HEIGHT;
        UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
        [aView addSubview:lbl];
        lbl.font = [UIFont systemFontOfSize:15];
        lbl.textAlignment = NSTextAlignmentCenter;
        _endLoadLbl = lbl;
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        btn.frame = self.bounds;
        [btn addTarget:self action:@selector(tapedOnLoadMore:) forControlEvents:UIControlEventTouchUpInside];
//        btn.hidden = YES;
        _tapedBtn = btn;
        
    }
    
    return self;
}

-(void)tapedOnLoadMore:(id)sender
{
    if (!_scroll)
    {
        return;
    }
    //设置自动刷新控件，并启动
    OLEGOFooterNormalControl *control = (OLEGOFooterNormalControl *)self.viewControl;
    if(![control isKindOfClass:[OLEGOFooterNormalControl class]])
    {
        return;
    }
    preEffectiveHeight = control.effectiveHeight;
    control.effectiveHeight = -MAXFLOAT;
    
    tapedStarted = YES;
    //启动刷新事件
    [self egoRefreshScrollViewDidScroll:_scroll];
    [self egoRefreshScrollViewDidEndDragging:_scroll];
}
#pragma mark - PrivateMethods
-(void)refreshLocalControlForType:(OL_LIST_DATA_LOAD_TYPE)type andEGOHeight:(CGFloat)height
{
    if (type==OL_LIST_DATA_LOAD_TYPE_UNKNOWN_LOAD) return;
    
    OLEGOFooterNormalControl * control = (OLEGOFooterNormalControl *)self.viewControl;
    
    CGFloat endHeight = 0;
    
    //改变control状态
    switch (type)
    {
        case OL_LIST_DATA_LOAD_TYPE_NONE:
        {
            control.effectiveHeight = MAXFLOAT;
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
        case OL_LIST_DATA_LOAD_TYPE_MIXED_LOAD:
        {
            
        }
            break;
            
        default:
            break;
    }

}

#pragma mark -
-(void)setViewControl:(NSObject <OLEGOViewContorlDelegate> *)aControl
{
    _viewControl = aControl;
    self.controlDelegate = aControl;
}

#pragma mark - PublicMethods
- (void)showEndLoadMoreWithString:(NSString *)str
{
    if(!str)
    {
        _endLoadView.hidden = YES;
        [self sendSubviewToBack:_endLoadView];
        return;
    }
    _endLoadView.hidden = NO;
    _endLoadLbl.text = str;
    [self bringSubviewToFront:_endLoadView];
}
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_controlDelegate&&[_controlDelegate respondsToSelector:@selector(egoHeaderView:scrollViewDidScrollForScrollView:)]) {
        [_controlDelegate egoHeaderView:self scrollViewDidScrollForScrollView:scrollView];
    }
    _scroll = scrollView;
}
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    if (_controlDelegate&&[_controlDelegate respondsToSelector:@selector(egoHeaderView:scrollViewDidEndDragingForScrollView:)]) {
        [_controlDelegate egoHeaderView:self scrollViewDidEndDragingForScrollView:scrollView];
    }}
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView andEndString:(NSString *)str
{
    if (_controlDelegate&&[_controlDelegate respondsToSelector:@selector(egoHeaderView:doneReloadingScrollView:andEndString:)]) {
        [_controlDelegate egoHeaderView:self doneReloadingScrollView:scrollView andEndString:str];
    }
    
    if (tapedStarted)
    {
        tapedStarted = NO;
        OLEGOFooterNormalControl *control = (OLEGOFooterNormalControl *)self.viewControl;
        control.effectiveHeight = preEffectiveHeight;
    }
}



@end
