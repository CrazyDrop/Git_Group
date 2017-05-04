//
//  CBGStatisticsDetailHistoryVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGStatisticsDetailHistoryVC.h"
#import "RefreshListCell.h"
#import "ZACBGDetailWebVC.h"
#import "CBGDepthStudyVC.h"
#define  CBGStatisticsHistoryAddTAG  100

@interface CBGStatisticsDetailHistoryVC ()


@end

@implementation CBGStatisticsDetailHistoryVC


-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice
{
    NSString * title = [NSString stringWithFormat:@"统计(%@)",self.selectedDate];
    self.titleV.text = title;

    [self startShowedLatestHistoryDBList];
}

- (void)viewDidLoad {
    self.viewTtle = @"统计历史";
    self.rightTitle = @"筛选";
    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortStyle = CBGStaticSortShowStyle_Space;
    self.orderStyle = CBGStaticOrderShowStyle_Rate;

    //分组  门派  rate
    //排序  rate  价格
    UIView * bgView = self.view;
    CGFloat btnWidth = SCREEN_WIDTH/3.0;
    CGFloat btnHeight = 40;
    UIButton * btn = nil;
    NSArray * namesArr = @[@"未结束",@"售出",@"全部"];//按钮点击时，从全部库表选取
    
    CGFloat btnStartY = SCREEN_HEIGHT - btnHeight;
    for (NSInteger index = 0; index < [namesArr count]; index ++)
    {
        CGFloat startY = btnStartY - (index) * (btnHeight + 2);

        NSString * name = [namesArr objectAtIndex:index];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btn.frame = CGRectMake(0  , startY, btnWidth - 1, btnHeight);
        btn.backgroundColor = [UIColor greenColor];
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [bgView addSubview:btn];
        btn.tag = CBGStatisticsHistoryAddTAG + index;
        [btn addTarget:self action:@selector(pricePlanBuySelectedTapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //控制起始数据源，db筛选规则
    [self startShowedLatestHistoryDBList];
}
-(void)startShowedLatestHistoryDBList
{
    self.finishStyle = CBGSortShowFinishStyle_Total;
    [self refreshLatestShowTableView];
}

-(void)pricePlanBuySelectedTapedOnBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger tagIndex = btn.tag - CBGStatisticsHistoryAddTAG;
    switch (tagIndex) {
        case 0:
        {
            self.finishStyle = CBGSortShowFinishStyle_UnFinish;
        }
            break;
        case 1:
        {
            self.finishStyle = CBGSortShowFinishStyle_Sold;
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


-(void)showDetailChooseForHistory
{//纵横两个维度看
    //    1、通过进入数据，控制数据的相关程度
    //    2、估价情况  1、有利  2、值得  3、不值  4、全部
    //    3、列表筛选  筛选  已售出  未售出 全部
    NSString * log = [NSString stringWithFormat:@"对统计数据如何处理？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = nil;
    
    if(self.exchangeDelegate)
    {
        action =[MSAlertAction actionWithTitle:@"估价历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                 {
                     if(weakSelf.exchangeDelegate && [weakSelf.exchangeDelegate respondsToSelector:@selector(historyHandelExchangeHistoryShowWithPlanShow:)]){
                         [weakSelf.exchangeDelegate historyHandelExchangeHistoryShowWithPlanShow:CBGCombinedHandleVCStyle_Plan];
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
    
    action = [MSAlertAction actionWithTitle:@"服务器分组" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.sortStyle = CBGStaticSortShowStyle_Server;
                  [weakSelf refreshLatestShowTableView];
              }];
    
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"价格排序" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.orderStyle = CBGStaticOrderShowStyle_Price;
                  [weakSelf refreshLatestShowTableView];
              }];
    
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"利差排序" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.orderStyle = CBGStaticOrderShowStyle_Rate;
                  [weakSelf refreshLatestShowTableView];

              }];
    
    [alertController addAction:action];


    action = [MSAlertAction actionWithTitle:@"比例排序" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.orderStyle = CBGStaticOrderShowStyle_Rate;
                  [weakSelf refreshLatestShowTableView];
              }];
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"附加排序" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.orderStyle = CBGStaticOrderShowStyle_MorePrice;
                  [weakSelf refreshLatestShowTableView];
              }];
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"空号排序" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.orderStyle = CBGStaticOrderShowStyle_EquipPrice;
                  [weakSelf refreshLatestShowTableView];
              }];
    [alertController addAction:action];

    
//    action = [MSAlertAction actionWithTitle:@"WEB刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
//              {
//                  [weakSelf startLatestDetailListRequestForShowedCBGListArr:[weakSelf latestTotalShowedHistoryList]];
//              }];
//    [alertController addAction:action];
    
    
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
