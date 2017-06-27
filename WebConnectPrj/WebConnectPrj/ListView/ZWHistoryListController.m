//
//  ZWHistoryListController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/9.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWHistoryListController.h"
#import "ZALocationLocalModel.h"
#import "ZWDataDetailModel.h"
#import "MSAlertController.h"
#import "ZWSortHistroyController.h"
#import "Equip_listModel.h"
#import "EquipDetailArrayRequestModel.h"
@interface ZWHistoryListController (){
    BaseRequestModel * _detailListReqModel;
}
@property (nonatomic,strong) UIAlertView * contactAlert;
@property (nonatomic,assign) NSInteger countNumber;
@property (nonatomic,assign) BOOL totalHistory;
@property (nonatomic,strong) NSArray * detailsArr;
@end

@implementation ZWHistoryListController

- (void)viewDidLoad {
    self.viewTtle = @"历史";
    self.rightTitle = @"编辑";
    self.showRightBtn = YES;
    self.totalHistory = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.countNumber = 0;

    [self startShowLocalTotalSaveEquipListArray];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self startLocalZWListData];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailListReqModel;
    [model cancel];
    [model removeSignalResponder:self];
    _detailListReqModel = nil;
}

//加载数据
-(void)startShowLocalTotalSaveEquipListArray
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotal];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
}
//加载数据
-(void)startShowLocalTotalSoldOutEquipListArray
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithSoldOut];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
}

-(void)refreshLatestDatabaseListDataForEarnPriceIsNull
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithPlanFail];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
}
-(void)refreshLatestDatabaseListDataForEarnPriceModel
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithPlanBuy];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];


    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
}
-(void)refreshLatestDatabaseListDataForSoldOut
{
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithSoldOut];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
}
-(void)refreshLatestDatabaseListDataForPlanBuyUnSoldOut
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithPlanBuy];
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if([eveModel.sell_sold_time length] == 0 && [eveModel.sell_back_time length] == 0){
            if([eveModel preBuyEquipStatusWithCurrentExtraEquip]){
                [resultArr addObject:eveModel];
            }
        }
    }
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[resultArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = resultArr;
        [self.listTable reloadData];
    });;
}

-(void)refreshLatestDatabaseListDataForSoldOutWithUnPlanBuy
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithSoldOut];
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++) {
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if(eveModel.plan_total_price < eveModel.equip_price/100)
        {
            [resultArr addObject:eveModel];
        }
    }
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[resultArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = resultArr;
        [self.listTable reloadData];
    });;
}
-(void)refreshLatestDatabaseListDataForToday
{
    NSString * todayDate = [NSDate unixDate];
    todayDate = [todayDate substringToIndex:[@"2017-03-29" length]];
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListForTime:todayDate];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
}

-(void)refreshLatestDatabaseListDataForPriceError
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListEquipPriceError];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
}
-(void)refreshLatestDatabaseListDataForUnFinished
{
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListTotalWithUnFinished];
    
    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
}
//刷新最新的数据，补全是否售出   更新主表
-(void)startLatestDetailListRequestForShowed
{
    //启动批量网络请求，刷新回传数据，补充库表
    //缓存当前数据，触发对应请求
    
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(model.executing)
    {
        return;
    }
//    self.detailsArr = [NSArray arrayWithArray:self.dataArr];
//    NSMutableArray * urls = [NSMutableArray array];
//    for (NSInteger index = 0;index <[self.detailsArr count] ;index ++) {
//        CBGListModel * eveModel = [self.detailsArr objectAtIndex:index];
//        NSString * eveUrl = eveModel.detailDataUrl;
//        [urls addObject:eveUrl];
//    }
    
    [self startLatestDetailListRequestForShowedCBGListArr:self.dataArr];

}
-(void)finishDetailListRequestWithFinishedCBGListArray:(NSArray *)array
{
    
    //    [DZUtils noticeCustomerWithShowText:@"退出重新刷新"];
    //    //    [self refreshLatestShowTableView];
    //    [[self rootNavigationController] popViewControllerAnimated:YES];
    
}

-(void)finishDetailListRequestWithErrorCBGListArray:(NSArray *)array
{
    for (NSInteger index = 0;index < [array count] ;index ++ )
    {
        CBGListModel * eveList = [array objectAtIndex:index];
        NSLog(@"%ld %@ %@",(long)index,eveList.equip_name,eveList.detailDataUrl);
    }
}
-(void)showDetailChooseForHistory
{
    NSString * log = [NSString stringWithFormat:@"对历史数据如何处理？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"切换至全部" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf startShowLocalTotalSaveEquipListArray];
                             }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"估价有利列表" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForEarnPriceModel];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"今日记录" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForToday];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"全部售出" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForSoldOut];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"已售低估" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForSoldOutWithUnPlanBuy];
              }];
    
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"高估未售" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForPlanBuyUnSoldOut];
              }];
    
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"估价失败列表" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForEarnPriceIsNull];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"未完成列表" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForUnFinished];
              }];
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"价格异常" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForPriceError];
              }];
    
    [alertController addAction:action];


    action = [MSAlertAction actionWithTitle:@"WEB刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLatestDetailListRequestForShowed];
              }];
    [alertController addAction:action];
    
    
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}


-(void)submit
{
//    [self showDialogForNoContactsError];
    [self showDetailChooseForHistory];
}

- (void)didReceiveMemoryWarning
{
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
