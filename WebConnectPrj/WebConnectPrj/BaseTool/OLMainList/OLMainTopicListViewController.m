//
//  OLMainTopicListViewController.m
//  WebConnectPrj
//
//  Created by Apple on 14-11-4.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "OLMainTopicListViewController.h"
#import "OLMainTopicListTableView.h"
#import "OLTopicListRequest.h"
#import "NTConnectClient.h"

@interface OLMainTopicListViewController ()
{
    OLMainTopicListTableView * _listView;
    
}
@property (nonatomic,assign) NSInteger pageIndex;
@end

@implementation OLMainTopicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageIndex = 1;
    // Do any additional setup after loading the view.
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    OLMainTopicListViewController * weakSelf = self;
    _listView = [[OLMainTopicListTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [self.view addSubview:_listView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _listView.loadRefreshNewDataBlock = ^(OLEGOCustomListTableView * table){
        OLTopicListRequest * request = [[OLTopicListRequest alloc] init];
        request.page = 1;
        [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:request
                                                             andEndBlock:^(id responseData, NSError *error)
         {
             if (error)
             {
                 [table doneLoadDataReloading];
                 return ;
             }
             NSArray * arr = [request responseCheckForWebData:responseData];
             if (!arr||[arr count]==0)
             {
                 [table doneLoadDataReloadingAndEndLoadMoreWithString:@"无更多数据"];
                 return;
             }
             OLMainTopicListTableView * ol = (OLMainTopicListTableView *)table;
             ol.dataArr = arr;
             [ol reloadData];
             [ol doneLoadDataReloading];
             
         }];
    };
    _listView.loadMoreDataBlock = ^(OLEGOCustomListTableView * table){
        OLTopicListRequest * request = [[OLTopicListRequest alloc] init];
        request.page = weakSelf.pageIndex+1;
        [[NTConnectClient sharedNTConnectClient] requestWithBasicRequest:request
                                                             andEndBlock:^(id responseData, NSError *error)
         {
             if (error)
             {
                 [table doneLoadDataReloading];
                 return ;
             }
             NSArray * arr = [request responseCheckForWebData:responseData];
             if (!arr||[arr count]==0)
             {
                 [table doneLoadDataReloadingAndEndLoadMoreWithString:@"无更多数据"];
                 return;
             }
             weakSelf.pageIndex = request.page;
             
             OLMainTopicListTableView * ol = (OLMainTopicListTableView *)table;
             NSMutableArray *  totalArr = [NSMutableArray arrayWithArray:ol.dataArr];
             [totalArr addObjectsFromArray:arr];
             ol.dataArr = totalArr;
             [ol reloadData];
             [ol doneLoadDataReloading];
             
         }];
    };
    
    

}

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
