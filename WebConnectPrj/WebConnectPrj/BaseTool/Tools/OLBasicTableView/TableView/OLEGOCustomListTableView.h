//
//  OLEGOCustomListTableView.h
//  WebConnectPrj
//
//  Created by Apple on 15/1/30.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOViewCommon.h"
#import "OLEGORefreshView.h"
#import "OLEGOFooterNormalControl.h"
//具体实现功能，尽可能的保持不变

@class OLBasicListTableView;

@interface OLEGOCustomListTableView : UITableView<EGORefreshTableDelegate>
{
    EGORefreshPos effectiveEGO;//当前的响应视图类型
    UIEdgeInsets _startEdgeInsets;
}
//不建议使用此类的delegate,不允许调用父类实现的代理
//如果一定要重新指定delegate,类似scrollViewDidEndScrollingAnimation方式实现
//作为父类使用，loadDataDelegate指向自身，即可实现请求方法的内部封装

//可以自由设定，外部不要控制此视图的行为，仅在需要时赋值即可
//默认为customview,不需要addview
@property (nonatomic,strong) OLEGORefreshView * egoHeader;

//可以自由设定，外部不要控制此视图的行为，仅在需要时赋值即可
//默认为customview,不需要addview
@property (nonatomic,strong) OLEGORefreshView * egoFooter;


//动画最长时间
@property (nonatomic,assign) CGFloat maxAnimatedInterval;


//控制上拉加载更多是否可用，如果不可用，则直接隐藏  默认不可用，用来处理无网络连接时的上拉加载
//加载更多有两变量控制，endLoadMore 控制是否设置加载结束及重启 和 hideEndLoadMore;
//用户可以通过loadMoreType来禁用上拉加载更多，通过hideEndLoadMore来控制是否展示上拉加载结束
//用来控制部分页面的上拉加载结束是否展示
//默认为NO，不隐藏
@property (nonatomic,assign) BOOL hideEndLoadMoreView;


//用来控制顶部加载矿展示位置,此属性，仅在设置contentinset的基础时有效，用来控制顶部视图是否在tableview顶部展示，默认为YES
//仅在tableview上部有固定覆盖时使用此变量，使用时要把滚动条隐藏，否则效果不好
@property (nonatomic,assign) BOOL headerViewAboveInset;


//需要在试图刷新前设置，否则无效  默认为NO,中途设置无效
@property (nonatomic,assign) BOOL containPreContentInset;


//数据加载代理
@property (nonatomic,weak) id<OLBasicListTableViewLoadDataDelegate> loadDataDelegate;

//刷新调用block
@property (nonatomic,copy) void (^loadRefreshNewDataBlock)(OLBasicListTableView * table);

//加载更多调用block
@property (nonatomic,copy) void (^loadMoreDataBlock)(OLBasicListTableView * table);

//如果使用自定义视图，需要在调用前设定egoHeader
//外部调用接口 调用此方法，可以直接调用loadRefreshNewDataBlock以及相关动画
-(void)startRefreshDataInForcedWithViewAnimated:(BOOL)animated;


//启动加载
-(void)startLoadMoredDataInForcedWithViewAnimated:(BOOL)animated;


//理论上需要requestRefreshNewData 方法或者loadRefreshNewDataBlock中调用结束方法
//当str不为空时，可以继续加载更多，当有内容时，不可以启动加载
//终止动画，结束加载状态
-(void)doneLoadDataReloading;


//增加停止加载更多功能，停止加载更多后可以使用restartLoadMore 回复加载更多功能
-(void)doneLoadDataReloadingAndEndLoadMoreWithString:(NSString *)str;


//结束加载更多，因网络异常，此种形式的停止加载更多，可以保留上拉加载功能
-(void)doneLoadDataReloadingWithAnimationDelay;


//重新启用加载更多
-(void)restartLoadMore;


//刷新上下拉控件的起始位置,置于laysubviews中调用
-(void)refreshContentInset;

@end
