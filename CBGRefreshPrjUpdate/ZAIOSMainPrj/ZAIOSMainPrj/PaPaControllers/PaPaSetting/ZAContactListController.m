//
//  ZAContactListController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/15.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactListController.h"
#import "ContactsModel.h"
#import "ZAContactListController+DataSource.h"
#import "ZAContactListController+DataRequest.h"
#import "DPViewController+WebNotice.h"
@interface ZAContactListController ()

@end

@implementation ZAContactListController
@synthesize listTable = _listTable;
@synthesize errorView = _errorView;
- (void)viewDidLoad
{
    startedRrefresh = YES;
    loadingState = YES;
//    selectDic = [NSMutableDictionary dictionary];
    self.viewTtle = @"联系人设置";
//    self.rightTitle = @"保存";
//    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    [self.view addSubview:self.listTable];
    [self.view addSubview:self.errorView];
    self.errorView.hidden = YES;
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if([DZUtils deviceWebConnectEnableCheck])
    {
        startedRrefresh = YES;
        NSArray * arr = total.contacts;
        if(!arr)
        {
            arr = [NSArray array];
        }
        self.dataList = [arr copy];
        [self refreshLocalTableView];
    }else{
        startedRrefresh = NO;
        loadingState = NO;
        
        self.errorView.hidden = NO;
        [self.errorView refreshErrorViewWithLoading:NO];
    }
    
    [self  appendContactRedNotificationObserve];
    
}
-(void)appendContactRedNotificationObserve
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshListRedCircleForNotification:)
                                                 name:NOTIFICATION_CONTACT_REDCIRCLE_STATE
                                               object:nil];
}
-(void)refreshListRedCircleForNotification:(NSNotification *)noti
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    self.dataList = total.contacts;
    [self refreshLocalTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat topHeight = CGRectGetMaxY(self.titleBar.frame);
    [self refreshWebNoticeViewForCustomWithStartY:topHeight];
    
    if(!_refreshList && !startedRrefresh) return;
    [self requestForContactList];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self refreshWebNoticeViewForNormal];
}

#pragma mark -----
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
