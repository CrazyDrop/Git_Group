//
//  OLEGORefreshView.h
//  WebConnectPrj
//
//  Created by Apple on 15/1/29.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>
//拆分EGO视图的事件和视图
//此类实现视图部分
#import "EGOViewCommon.h"
@class OLEGORefreshView;
@protocol OLEGOViewContorlDelegate <NSObject>
-(void)egoHeaderView:(OLEGORefreshView *)header scrollViewDidScrollForScrollView:(UIScrollView *)scrollView;
-(void)egoHeaderView:(OLEGORefreshView *)header scrollViewDidEndDragingForScrollView:(UIScrollView *)scrollView;
-(void)egoHeaderView:(OLEGORefreshView *)header doneReloadingScrollView:(UIScrollView *)scroll andEndString:(NSString *)str;
@end


//使用方法，创建子类实现界面 指定controlDelegate实现必须的三个代理即可
@interface OLEGORefreshView : UIView
{
    UIView * _endLoadView;
    UILabel * _endLoadLbl;
    
    UIButton * _tapedBtn;
    __weak UIScrollView * _scroll;
    EGOPullRefreshState _state;
}

//控制视图的展示形式，是普通的跟随滑动还是底部展示
//目前仅对headerview有效，默认为NO
//基于此种形式的视图，视图靠上展示
@property (nonatomic,assign) BOOL stayBelow;


//高度
@property (nonatomic,assign) CGFloat egoViewHeight;


//指定逻辑实现对象，方便扩展使用,自定义control
@property (nonatomic,strong) NSObject <OLEGOViewContorlDelegate> * viewControl;


//状态
@property (nonatomic,assign) EGOPullRefreshState state;

//控制是否处于加载状态,可以不使用
//@property (nonatomic,assign,getter=isLoading) BOOL loading;


//起始时的顶部缩进
@property(nonatomic,assign) UIEdgeInsets startedInset;


//提供给使用者反馈,以便响应事件
@property(nonatomic,assign) id <EGORefreshTableDelegate> delegate;

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView andEndString:(NSString *)str;

//展示加载结束,当传入nil,隐藏加载结束视图，仅针对FooterView使用
- (void)showEndLoadMoreWithString:(NSString *)str;

//默认刷新，进行control的默认刷新，此方法暂未测试
-(void)refreshLocalControlForType:(OL_LIST_DATA_LOAD_TYPE)type andEGOHeight:(CGFloat)height;

@end
