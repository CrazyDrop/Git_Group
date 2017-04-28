//
//  CBGPlanSortHistoryVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanSortHistoryVC.h"
#import "ZALocationLocalModel.h"
#import "CBGFutureStatusSortVC.h"
#define  CBGPlanSortHistoryAddTAG  100
@interface CBGPlanSortHistoryVC ()
@property (nonatomic, strong) NSArray * preTotalArr;
@end

@implementation CBGPlanSortHistoryVC

-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice
{
    self.preTotalArr = [NSArray arrayWithArray:self.dbHistoryArr];

    self.titleV.text = [NSString stringWithFormat:@"估价(%@)",self.selectedDate];
    [self selectHistoryForPlanStartedLoad];
    
}

- (void)viewDidLoad {
    self.viewTtle = @"估价历史";

    self.rightTitle = @"筛选";
    self.showRightBtn = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.orderStyle = CBGStaticOrderShowStyle_Rate;
    self.sortStyle = CBGStaticSortShowStyle_School;

//    列表选择时，从当前列表选取
    
    UIView * bgView = self.view;
    CGFloat btnWidth = SCREEN_WIDTH/3.0;
    CGFloat btnHeight = 40;
    UIButton * btn = nil;
    NSArray * namesArr = @[@"未结束",@"已结束",@"全部"];//按钮点击时，从全部库表选取

    CGFloat btnStartY = SCREEN_HEIGHT - btnHeight;
    for (NSInteger index = 0; index < [namesArr count]; index ++)
    {
        NSString * name = [namesArr objectAtIndex:index];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(index * btnWidth  , btnStartY, btnWidth - 1, btnHeight);
        btn.backgroundColor = [UIColor greenColor];
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [bgView addSubview:btn];
        btn.tag = CBGPlanSortHistoryAddTAG + index;
        [btn addTarget:self action:@selector(pricePlanBuySelectedTapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //展示售出  有利
    [self selectHistoryForPlanStartedLoad];
}



-(void)pricePlanBuySelectedTapedOnBtn:(id)sender
{
    self.sortStyle = CBGStaticSortShowStyle_None;
    //从全部中选取
    self.dbHistoryArr = [NSArray arrayWithArray:self.preTotalArr];
    UIButton * btn = (UIButton *)sender;
    NSInteger tagIndex = btn.tag - CBGPlanSortHistoryAddTAG;
    
    switch (tagIndex) {
        case 0:
        {
            self.finishStyle = CBGSortShowFinishStyle_UnFinish;
        }
            break;
        case 1:
        {
            self.finishStyle = CBGSortShowFinishStyle_Finished;

        }
            break;

        case 2:
        {
            self.finishStyle = CBGSortShowFinishStyle_Total;
        }
            break;

        default:
            break;
    }

    [self refreshLatestShowTableView];
    
}
-(void)selectHistoryForPlanStartedLoad
{
    if(!self.preTotalArr) return;

    NSArray * sortArr = [NSArray arrayWithArray:self.preTotalArr];
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //视已取回和售出一样
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if(CBGEquipPlanStyle_Worth == eveModel.style ||  CBGEquipPlanStyle_PlanBuy == eveModel.style){
            [resultArr addObject:eveModel];
        }
    }
    
    self.dbHistoryArr = resultArr;
    
    self.finishStyle = CBGSortShowFinishStyle_Total;
    [self refreshLatestShowTableView];
}

-(void)selectHistoryForLatestEquipPlanStyle:(CBGEquipPlanStyle)style
{
    NSArray * sortArr = [NSArray arrayWithArray:[self latestTotalShowedHistoryList]];
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //视已取回和售出一样
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if(style == eveModel.style){
            [resultArr addObject:eveModel];
        }
    }
    
    self.dbHistoryArr = resultArr;
    [self refreshLatestShowTableView];
}
-(void)selectHistoryForSoldOutQuickly
{
    self.sortStyle = CBGStaticSortShowStyle_School;
    NSArray * sortArr = [NSArray arrayWithArray:[self latestTotalShowedHistoryList]];
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //视已取回和售出一样
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        NSString * create = eveModel.sell_create_time;
        NSDate * createDate = [NSDate fromString:create];
        NSString * sold = eveModel.sell_sold_time;
        NSDate * soldDate = [NSDate fromString:sold];
        
        //秒数
        NSTimeInterval count = [soldDate timeIntervalSinceDate:createDate];
        if(count < MINUTE * 10 && [sold length] > 0){
            [resultArr addObject:eveModel];
        }
    }
    
    self.dbHistoryArr = resultArr;
    [self refreshLatestShowTableView];
}

-(void)selectHistoryForWithHighPlanBuyAndUnSoldOutWithNotice:(BOOL)notice
{
    NSArray * sortArr = [NSArray arrayWithArray:self.dbHistoryArr];
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if([eveModel.sell_sold_time length] == 0 && [eveModel.sell_back_time length] == 0){
            if(eveModel.style == CBGEquipPlanStyle_PlanBuy){
                [resultArr addObject:eveModel];
            }
        }
    }
    
}
-(void)showDetailFutureStatusSortVC
{
    CBGFutureStatusSortVC * future = [[CBGFutureStatusSortVC alloc] init];
    future.dbHistoryArr = [NSArray arrayWithArray:[self latestTotalShowedHistoryList]];
    [[self rootNavigationController] pushViewController:future animated:YES];
}

//经有dbHistoryArr数据进行筛选  展示
-(void)selectHistoryForWithHighPlanBuyAndUnSoldOut
{
    [self selectHistoryForWithHighPlanBuyAndUnSoldOutWithNotice:YES];
}

-(void)showDetailChooseForHistory
{//纵横两个维度看
//    1、通过进入数据，控制数据的相关程度
//    2、估价情况  1、有利  2、值得  3、不值  4、全部
//    3、列表筛选  筛选  已售出  未售出 全部
    NSString * log = [NSString stringWithFormat:@"对估价数据如何处理？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = nil;
    
    if(self.exchangeDelegate)
    {
        action =[MSAlertAction actionWithTitle:@"切换统计历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                 {
                     if(weakSelf.exchangeDelegate && [weakSelf.exchangeDelegate respondsToSelector:@selector(historyHandelExchangeHistoryShowWithPlanShow:)]){
                         [weakSelf.exchangeDelegate historyHandelExchangeHistoryShowWithPlanShow:CBGCombinedHandleVCStyle_Statist];
                     }
                 }];
        [alertController addAction:action];
        
        action = [MSAlertAction actionWithTitle:@"图表统计" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                  {
                      if(weakSelf.exchangeDelegate && [weakSelf.exchangeDelegate respondsToSelector:@selector(historyHandelExchangeHistoryShowWithPlanShow:)]){
                          [weakSelf.exchangeDelegate historyHandelExchangeHistoryShowWithPlanShow:CBGCombinedHandleVCStyle_Study];
                      }
                  }];
        [alertController addAction:action];

    }
    action = [MSAlertAction actionWithTitle:@"化圣相关" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showDetailFutureStatusSortVC];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"全部" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf selectHistoryForPlanStartedLoad];
              }];
    
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"估价有利" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  
                  [weakSelf selectHistoryForLatestEquipPlanStyle:CBGEquipPlanStyle_PlanBuy];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"估价值得" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  
                  [weakSelf selectHistoryForLatestEquipPlanStyle:CBGEquipPlanStyle_Worth];
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"估价不值" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  
                  [weakSelf selectHistoryForLatestEquipPlanStyle:CBGEquipPlanStyle_NotWorth];
              }];
    
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"10分售出" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  
                  [weakSelf selectHistoryForSoldOutQuickly];
              }];
    
    [alertController addAction:action];

    
    action = [MSAlertAction actionWithTitle:@"WEB刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLatestDetailListRequestForShowedCBGListArr:[weakSelf latestTotalShowedHistoryList]];
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

-(void)finishDetailListRequestWithFinishedCBGListArray:(NSArray *)array
{
    [DZUtils noticeCustomerWithShowText:@"退出重新刷新"];
    //    [self refreshLatestShowTableView];
    [[self rootNavigationController] popViewControllerAnimated:YES];

}


-(void)submit
{
    //    [self showDialogForNoContactsError];
    [self showDetailChooseForHistory];
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
