//
//  ZWBaseRefreshController.h
//  WebConnectPrj
//
//  Created by Apple on 2017/5/15.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
#define NOTIFICATION_ZWPANIC_REFRESH_STATE           @"NOTIFICATION_ZWPANIC_REFRESH_STATE"

//进行数据展示，数据提醒，web页面提前加载
@interface ZWBaseRefreshController : DPWhiteTopController
{
    NSLock * requestLock;
    BaseRequestModel * _detailArrModel;
    NSString * _tagString;
}

//指定tag值，开启检索

@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,strong) NSArray * showArray;
@property (nonatomic,strong) NSArray * tagArray;
@property (nonatomic,strong) NSArray * dataArr;


@property (nonatomic, strong, readonly) UIView * tipsView;

-(void)refreshTableViewWithLatestCacheArray:(NSArray *)cacheArr;
-(void)refreshTitleViewTitleWithLatestTitleName:(NSString *)title;
-(BOOL)checkListInputForNoticeWithArray:(NSArray *)array;
-(void)refreshTableViewWithInputLatestListArray:(NSArray *)array  cacheArray:(NSArray *)cacheArr;



@end
