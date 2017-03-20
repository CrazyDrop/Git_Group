//
//  OLEGOPageListTableView.m
//  WebConnectPrj
//
//  Created by Apple on 15/1/28.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import "OLEGOPageListTableView.h"

#define OLBasicPageList_EndLoadMoreString @"加载完毕"

@interface OLEGOPageListTableView()
//当前数据
@property (nonatomic,strong) NSArray * listDataArr;

//当前页数
@property (nonatomic,assign) NSInteger pageIndex;
@end

@implementation OLEGOPageListTableView
-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        _startedPageIndex = 1;
        _pageIndex = 1;
        _clearWhenRefresh = NO;
    }
    return self;
}


//数据刷新,用于刷新数据解析后的回调，或者使用历史数据的展示
-(void)refreshTableViewWithRefreshDataArray:(NSArray *)array
{
    //当加载更多的数据为空时，加载结束
    if (!array||[array count]==0)
    {
        //刷新结束，无返回
        [self doneLoadDataReloadingWithAnimationDelay];
        return;
    }
    
    //刷新清空
    if (_clearWhenRefresh)
    {
        self.pageIndex = self.startedPageIndex;
        self.listDataArr = array;
        [self reloadData];
        [self doneLoadDataReloading];
        
        //设置重启加载更多
        if (array&&[array count]>0)
        {
            [self restartLoadMore];
        }
        return;
    }
    
    //刷新不清空
    //排重运算
    NSArray * addArr = array;
    if (self.compareNumFromObjBlock)
    {
        //        addArr =
        //排重操作
        if (!addArr||[addArr count]==0)
        {
            //加载回来的数据不为空，但是排重之后为空，正常情况下服务器不能允许，
            //此时先作为加载失败处理一下，页数增加以便继续加载之后数据
            [self doneLoadDataReloadingWithAnimationDelay];
            return;
        }
    }
    
    NSMutableArray * total = [NSMutableArray arrayWithArray:addArr];
    //添加原有数据
    [total addObjectsFromArray:_listDataArr];
    self.listDataArr = total;
    [self reloadData];
    [self doneLoadDataReloading];
}



//数据加载，用于加载更多
-(void)refreshTableViewWithLatestLoadMoreDataArray:(NSArray *)array
{
    //当加载更多的数据为空时，加载结束
    if (!array||[array count]==0)
    {
        //加载结束
        [self doneLoadDataReloadingAndEndLoadMoreWithString:OLBasicPageList_EndLoadMoreString];
        return;
    }
    
    //排重运算
    NSArray * addArr = nil;
    if (self.compareNumFromObjBlock)
    {
        //排重操作
        if (!addArr||[addArr count]==0)
        {
            //加载回来的数据不为空，但是排重之后为空，正常情况下服务器不能允许，
            //此时先作为加载失败处理一下，页数增加以便继续加载之后数据
            _pageIndex++;
            [self doneLoadDataReloadingWithAnimationDelay];
            return;
        }
    }
    
    _pageIndex++;
    NSMutableArray * total = [NSMutableArray arrayWithArray:_listDataArr];
    [total addObjectsFromArray:addArr];
    self.listDataArr = total;
    [self reloadData];
    [self doneLoadDataReloading];
}

-(void)refreshTableViewWithRefreshDataArray:(NSArray *)array andErrorStr:(NSString *)err
{
    //错误处理
    if (err)
    {
        //此处可以添加针对error的处理
        [self doneLoadDataReloadingWithAnimationDelay];
        return;
    }
    [self refreshTableViewWithRefreshDataArray:array];
}

-(void)refreshTableViewWithLatestLoadMoreDataArray:(NSArray *)array andErrorStr:(NSString *)err
{
    //错误处理
    if (err)
    {
        [self doneLoadDataReloadingWithAnimationDelay];
        return;
    }
    [self refreshTableViewWithLatestLoadMoreDataArray:array];
}


@end
