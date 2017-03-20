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

    [self startShowLocalTotalSoldOutEquipListArray];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self startLocalZWListData];
}

//加载数据
-(void)startShowLocalTotalSaveEquipListArray
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localTotalSaveEquipArray];
    
    NSString * noticeStr = [NSString stringWithFormat:@"全部缓存数据%lu",[sortArr count]];
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
    NSArray * sortArr = [manager localSaveEquipArrayForSoldOut];
    
    NSString * noticeStr = [NSString stringWithFormat:@"全部销售数据%lu",[sortArr count]];
    [DZUtils noticeCustomerWithShowText:noticeStr];
    
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
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"刷新估价" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshSoldOutEquipPreSoldPrice];
              }];
    [alertController addAction:action];
    

    action = [MSAlertAction actionWithTitle:@"筛选利差号" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf checkCurrentEquipForEarnPreBuy];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"清空全部售出" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf clearAllLocalTotalSoldOutEquipArray];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"清空全部库表" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                    [weakSelf clearAllLocalSaveTotalEquipArray];
              }];
    
    action = [MSAlertAction actionWithTitle:@"切换至全部" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf exchangeShowListViewForTotalSave];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"切换至售出" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf exchangeShowListViewForSoldOutDatabase];
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
    [self startShowLocalTotalSoldOutEquipListArray];
}
-(void)checkCurrentEquipForEarnPreBuy
{
    NSMutableArray * showArr = [NSMutableArray array];
    NSArray * array = self.dataArr;
    
    for (NSInteger index = 0; index < [array count]; index ++)
    {
        Equip_listModel * list = [array objectAtIndex:index];
        
        if([list preBuyEquipStatusWithCurrentExtraEquip])
        {
            [showArr addObject:list];
        }
    }
    
    self.dataArr = showArr;
    [self.listTable reloadData];
}
-(void)exchangeShowListViewForSoldOutDatabase
{
    [self startShowLocalTotalSoldOutEquipListArray];
}
-(void)exchangeShowListViewForTotalSave
{
    [self startShowLocalTotalSaveEquipListArray];
}
-(void)clearAllLocalTotalSoldOutEquipArray
{
    [[ZALocationLocalModelManager sharedInstance] clearTotalSoldOutLocations];
    [self startShowLocalTotalSoldOutEquipListArray];
}
-(void)clearAllLocalSaveTotalEquipArray
{
    [[ZALocationLocalModelManager sharedInstance] clearTotalLocations];
    [self startShowLocalTotalSoldOutEquipListArray];
}
-(NSArray *)tableViewShowedPathes
{
    CGRect rect = self.listTable.bounds;
    rect.origin = self.listTable.contentOffset;
    NSArray * cells = [self.listTable indexPathsForRowsInRect:rect];
    return cells;
}
-(NSArray *)latestShowedDataArray
{
    NSArray * cells = [self tableViewShowedPathes];
    NSMutableArray * models = [NSMutableArray array];

    if([cells count]>0)
    {
        NSIndexPath * start = [cells firstObject];
        NSIndexPath * last = [cells lastObject];
        
        NSRange range = NSMakeRange(start.section, last.section - start.section);
        NSIndexSet * set = [NSIndexSet indexSetWithIndexesInRange:range];
        NSArray * arr = [self.dataArr objectsAtIndexes:set];
        [models addObjectsFromArray:arr];
    }
    
    return models;
}
-(void)refreshSoldOutEquipPreSoldPrice
{
    NSArray * array = [self latestShowedDataArray];
    NSInteger minNum = [array count];
    for (NSInteger index = 0; index < minNum; index ++)
    {
        Equip_listModel * list = [array objectAtIndex:index];
        
        EquipDetailArrayRequestModel * manager = [EquipDetailArrayRequestModel sharedInstance];
        EquipExtraModel * extra = [manager extraModelFromLatestEquipDESC:list.detaiModel];
        list.detaiModel.equipExtra = extra;
        
        extra.buyPrice = [extra createExtraPrice];
    }
    
    
    [[ZALocationLocalModelManager sharedInstance] localSaveSoldOutEquipModelArray:array];
    NSArray * cells = [self tableViewShowedPathes];
    [self.listTable reloadRowsAtIndexPaths:cells withRowAnimation:UITableViewRowAnimationNone];
}
-(void)showSortHistroyDetail
{
    ZWSortHistroyController * sort = [[ZWSortHistroyController alloc] init];
    [[self rootNavigationController] pushViewController:sort animated:YES];
}

-(void)exchangeLocalHistroy
{
    self.totalHistory = !self.totalHistory;
    [self startShowLocalTotalSoldOutEquipListArray];
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
