//
//  EGOViewCommon.h
//  TableViewRefresh
//
//  Created by  Abby Lin on 12-5-2.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef TableViewRefresh_EGOViewCommon_h
#define TableViewRefresh_EGOViewCommon_h

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

#define  REFRESH_REGION_HEIGHT 65.0f

//新增宏定义，默认底部展示距离
#define  REFRESH_LOADMORE_END_HEIGHT 30.0f

typedef enum{
	EGOOPullRefreshPulling = 0,
	EGOOPullRefreshNormal,
	EGOOPullRefreshLoading,	
} EGOPullRefreshState;

typedef enum{
	EGORefreshHeader = 0,
	EGORefreshFooter	
} EGORefreshPos;

@protocol EGORefreshTableDelegate
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos;
- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view;
@optional
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view;
@end


typedef enum {
    OL_EGOVIEW_TYPE_NORMAL = 1,        //通用的
    OL_EGOVIEW_TYPE_CUSTOM = 2,        //自定义，方便后续添加新形式
    OL_EGOVIEW_TYPE_DRAG_TEXT = 3,     //模仿糗百
    OL_EGOVIEW_TYPE_TAP_TEXT = 4,      //模仿网易
}OL_EGOVIEW_TYPE;

typedef enum {
    OL_LIST_DATA_LOAD_TYPE_NONE = 1,        //没有上下拉效果
    OL_LIST_DATA_LOAD_TYPE_NORMAL = 2,      //原始的上下拉效果
    OL_LIST_DATA_LOAD_TYPE_SHOW_LOAD = 3,   //常见上下拉效果，默认展示上拉加载更多
    OL_LIST_DATA_LOAD_TYPE_AUTO_LOAD = 4,   //自动启动加载更多，此种为特殊形式，不区分EGOVIEW_TYPE
    OL_LIST_DATA_LOAD_TYPE_TAPED_LOAD = 5,  //点击启动加载更多
    OL_LIST_DATA_LOAD_TYPE_MIXED_LOAD = 6,  //混合的加载形式，前4次为AUTO_LOAD之后为点击TAPED_LOAD
    OL_LIST_DATA_LOAD_TYPE_UNKNOWN_LOAD = 7, //未知形式，使用可以参照OLEGOHeaderNormalControl
}OL_LIST_DATA_LOAD_TYPE;

@class OLEGOCustomListTableView;
@protocol OLBasicListTableViewLoadDataDelegate<NSObject>
-(void)basicTableView:(OLEGOCustomListTableView *)table startRefreshDataForType:(OL_LIST_DATA_LOAD_TYPE)type;
-(void)basicTableView:(OLEGOCustomListTableView *)table startLoadMoreDataForType:(OL_LIST_DATA_LOAD_TYPE)type;
@end


#endif
