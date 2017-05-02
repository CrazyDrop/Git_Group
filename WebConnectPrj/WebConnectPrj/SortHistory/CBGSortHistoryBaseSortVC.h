//
//  CBGSortHistoryBaseSortVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/4/24.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseDetailVC.h"

//实现数据分组功能，分组后进行展示
typedef enum : NSUInteger
{
    CBGStaticSortShowStyle_None = 0,    //无分组
    CBGStaticSortShowStyle_School,      //门派 分组
    CBGStaticSortShowStyle_Rate,        //利差 分组
    CBGStaticSortShowStyle_Space,       //间隔 分组  3分 10分 30 1小时  1天  其他
    CBGStaticSortShowStyle_Server,      //服务器 分组
} CBGStaticSortShowStyle;//账号分组方式


//实现数据分组功能，分组后进行展示
typedef enum : NSUInteger
{
    CBGStaticOrderShowStyle_None = 0,   //无排序
    CBGStaticOrderShowStyle_School,     //根据门派排序
    CBGStaticOrderShowStyle_Rate,       //根据利差排序，无数据时根据比值排序
    CBGStaticOrderShowStyle_Price,      //根据价格排序
    CBGStaticOrderShowStyle_Space,      //根据间隔排序
    CBGStaticOrderShowStyle_Create,     //根据上架时间排序
    CBGStaticOrderShowStyle_MorePrice,     //根据宝宝和装备附加值排序
} CBGStaticOrderShowStyle;//账号排序方式



typedef enum : NSUInteger
{
    CBGSortShowFinishStyle_None = 0,//默认都全部数据
    CBGSortShowFinishStyle_Total,
    CBGSortShowFinishStyle_UnFinish,
    CBGSortShowFinishStyle_Finished,
    CBGSortShowFinishStyle_Sold,
    CBGSortShowFinishStyle_Back,
} CBGSortShowFinishStyle;//账号状态筛选

//进行排序相关
@interface CBGSortHistoryBaseSortVC : CBGSortHistoryBaseDetailVC

//状态筛选
@property (nonatomic, assign) CBGSortShowFinishStyle  finishStyle;

//分组
@property (nonatomic, assign) CBGStaticSortShowStyle  sortStyle;

//排序
@property (nonatomic, assign) CBGStaticOrderShowStyle orderStyle;


//根据最新的规则，分组或筛选数据
-(void)refreshLatestShowTableView;



@end
