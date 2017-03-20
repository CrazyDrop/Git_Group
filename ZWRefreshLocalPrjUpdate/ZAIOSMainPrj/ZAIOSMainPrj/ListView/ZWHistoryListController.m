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
@interface ZWHistoryListController ()
@property (nonatomic,strong) UIAlertView * contactAlert;
@property (nonatomic,assign) NSInteger countNumber;
@property (nonatomic,assign) BOOL totalHistory;

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

    [self startLocalZWListData];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self startLocalZWListData];
}


//加载数据
-(void)startLocalZWListData
{
    NSArray * array = nil;
    if(!self.totalHistory){
        array = [[ZALocationLocalModelManager sharedInstance] localLocationsArrayForCurrent];
    }else{
        array = [[ZALocationLocalModelManager sharedInstance] localLocationsArrayForAppendingDB];
    }

    NSArray * sortArr = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ZWDataDetailModel * model1 = (ZWDataDetailModel  *)obj1;
        ZWDataDetailModel * model2 = (ZWDataDetailModel *)obj2;
        
        return [model2.created_at compare:model1.created_at];
        
    }];
    
    //置空售价和利润数据
    [sortArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel * model1 = (ZWDataDetailModel  *)obj;
        model1.sellRate = nil;
        model1.earnRate = nil;
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = sortArr;
        [self.listTable reloadData];
    });;
}
-(void)showDetailChooseForHistory
{
    NSString * log = [NSString stringWithFormat:@"对历史数据如何处理？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"历史保存" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf historySaveFromCurrentTempList];
              }];
    [alertController addAction:action];
    

    action = [MSAlertAction actionWithTitle:@"筛选售罄和高利率" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf clearCurrentTempHistroyForSave];
              }];
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"切换历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf exchangeLocalHistroy];
              }];
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"筛选高利率+大金额" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf clearLowEarnPriceFromHistory];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"统计数据" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showSortHistroyDetail];
              }];
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"清空全部" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf clearAllLocalHistory];
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
-(void)clearLowEarnPriceFromHistory
{
    NSMutableArray * deleteArr = [NSMutableArray array];
    NSArray * array = self.dataArr;
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel * model1 = (ZWDataDetailModel  *)obj;
        DetailModelSaveType type = model1.currentModelState;
        if(type != DetailModelSaveType_Buy || [model1.total_money intValue]< 3000)
        {
            [deleteArr addObject:model1];
        }
    }];
    
    [[ZALocationLocalModelManager sharedInstance] clearUploadedLocations:deleteArr];
    [self startLocalZWListData];
}
-(void)clearCurrentTempHistroyForSave
{
    NSMutableArray * showArr = [NSMutableArray array];
    NSArray * array = self.dataArr;
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel * model1 = (ZWDataDetailModel  *)obj;
        model1.sellRate = nil;
        CGFloat earnRate = [model1.earnRate floatValue];
        CGFloat totalMoney = [model1.total_money floatValue];
        
        if(earnRate > 14 || ( model1.disappearNum != 1 && totalMoney > 2*10000))
        {
            [showArr addObject:model1];
        }
    }];
    
    self.dataArr = showArr;
    [self.listTable reloadData];
}
-(void)clearMaxEarnPriceFromHistory
{
    NSMutableArray * deleteArr = [NSMutableArray array];
    NSArray * array = self.dataArr;
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZWDataDetailModel * model1 = (ZWDataDetailModel  *)obj;
        model1.sellRate = nil;
        CGFloat earnRate = [model1.earnRate floatValue];
        if(earnRate < 16)
        {
            [deleteArr addObject:model1];
        }
    }];
    
    [[ZALocationLocalModelManager sharedInstance] clearUploadedLocations:deleteArr];
    [self startLocalZWListData];
}
-(void)clearAllLocalHistory
{
    [[ZALocationLocalModelManager sharedInstance] clearTotalLocations];
    [self startLocalZWListData];
}
-(void)historySaveFromCurrentTempList
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    [manager exchangeLocalSaveLocationsToSave];
    
}
-(void)showSortHistroyDetail
{
    ZWSortHistroyController * sort = [[ZWSortHistroyController alloc] init];
    [[self rootNavigationController] pushViewController:sort animated:YES];
}

-(void)exchangeLocalHistroy
{
    self.totalHistory = !self.totalHistory;
    [self startLocalZWListData];
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
