//
//  ZAContactListController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/15.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"
#import "DPViewController+Message.h"
#import "ZAWebErrorView.h"
@interface ZAContactListController : DPWhiteTopController
{
    DelContactsModel * _delModel;
    ContactTellModel * tellModel;
    BOOL loadingState;//加载框展示状态
    UILabel * noticeLbl;
    BOOL startedRrefresh;
    UITableView * _listTable;
    ZAWebErrorView * _errorView;
}

@property (nonatomic,assign) BOOL refreshList;

@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,strong) ZAWebErrorView * errorView;



@end
