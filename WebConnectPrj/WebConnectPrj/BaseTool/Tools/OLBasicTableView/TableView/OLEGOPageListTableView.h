//
//  OLEGOPageListTableView.h
//  WebConnectPrj
//
//  Created by Apple on 15/1/28.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOLoadTypeListTableView.h"
//封装网络请求后的数据回调处理，限制之后的列表，仅支持一种数据展示
//为方便处理，增加pageIndex和dataArr变量
@interface OLEGOPageListTableView : OLEGOLoadTypeListTableView
//当前数据
@property (nonatomic,strong,readonly) NSArray * listDataArr;

//当前页数，此变量，仅能通过refreshTableViewWithLatestLoadMoreDataArray方法增加
@property (nonatomic,assign,readonly) NSInteger pageIndex;

//不设置此变量，默认不进行排重运算
@property (nonatomic,copy) NSInteger (^compareNumFromObjBlock)(id obj);

//起始页数，默认为1，修改后，需要调用refreshTableViewWithRefreshDataArray生效
@property (nonatomic,assign) NSInteger startedPageIndex;

//控制数据刷新RefreshDataArray时，是否清空原有数据 默认不清空
@property (nonatomic,assign) BOOL refreshClear;

//数据刷新,用于刷新数据解析后的回调，或者使用历史数据的展示
-(void)refreshTableViewWithRefreshDataArray:(NSArray *)array;


//数据加载，用于加载更多
-(void)refreshTableViewWithLatestLoadMoreDataArray:(NSArray *)array;


//针对进行默认处理的使用以下方法
-(void)refreshTableViewWithRefreshDataArray:(NSArray *)array andErrorStr:(NSString *)err;
-(void)refreshTableViewWithLatestLoadMoreDataArray:(NSArray *)array andErrorStr:(NSString *)err;




@end
