//
//  CBGPlanSortHistoryVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanSortHistoryVC.h"
#import "ZALocationLocalModel.h"
#define  CBGPlanSortHistoryAddTAG  100
@interface CBGPlanSortHistoryVC ()
@end

@implementation CBGPlanSortHistoryVC

-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice
{
    self.titleV.text = [NSString stringWithFormat:@"估价(%@)",self.selectedDate];
    [self selectHistoryForPlanStartedLoad];
}

- (void)viewDidLoad {
    self.viewTtle = @"估价历史";

    self.rightTitle = @"筛选";
    self.showRightBtn = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
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
    UIButton * btn = (UIButton *)sender;
    NSInteger tagIndex = btn.tag - CBGPlanSortHistoryAddTAG;
    
    NSMutableArray * sortArr = [NSMutableArray array];
    NSArray * latestArr = [NSArray arrayWithArray:self.dbHistoryArr];
    
    switch (tagIndex) {
        case 0:
        {
            for (NSInteger index = 0; index < [latestArr count]; index ++)
            {
                CBGListModel * eveModel  =[latestArr objectAtIndex:index];
                BOOL unFinished = ([eveModel.sell_sold_time length] == 0 && [eveModel.sell_back_time length] == 0);
                if(unFinished)
                {
                    [sortArr addObject:eveModel];
                }
            }
        }
            break;
        case 1:
        {
            for (NSInteger index = 0; index < [latestArr count]; index ++)
            {
                CBGListModel * eveModel  =[latestArr objectAtIndex:index];
                BOOL finish = ([eveModel.sell_sold_time length] != 0 || [eveModel.sell_back_time length] != 0);
                if(finish)
                {
                    [sortArr addObject:eveModel];
                }
            }

        }
            break;

        case 2:
        {
            [sortArr addObjectsFromArray:latestArr];

        }
            break;

        default:
            break;
    }
    [self refreshNumberLblWithLatestNum:[sortArr count]];
    
    self.dataArr = sortArr;
    [self.listTable reloadData];
    
}
-(void)selectHistoryForPlanStartedLoad
{
    if(!self.dbHistoryArr) return;
    
    NSArray * sortArr = [NSArray arrayWithArray:self.dbHistoryArr];
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //视已取回和售出一样
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if(eveModel.style  == CBGEquipPlanStyle_PlanBuy || eveModel.style == CBGEquipPlanStyle_Worth)
        {
            [resultArr addObject:eveModel];
        }
    }
    
     [resultArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CBGListModel * eve1 = (CBGListModel *)obj1;
        CBGListModel * eve2 = (CBGListModel *)obj2;
        return [[NSNumber numberWithInteger:eve2.plan_rate] compare:[NSNumber numberWithInteger:eve1.plan_rate]];
    }];
    
    //    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[resultArr count]];
    //    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    [self refreshNumberLblWithLatestNum:[resultArr count]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = resultArr;
        [self.listTable reloadData];
    });
}

-(void)selectHistoryForLatestEquipPlanStyle:(CBGEquipPlanStyle)style
{
    NSArray * sortArr = [NSArray arrayWithArray:self.dataArr];
    
    NSMutableArray * resultArr = [NSMutableArray array];
    for (NSInteger index = 0; index < [sortArr count]; index ++)
    {
        //视已取回和售出一样
        CBGListModel * eveModel = [sortArr objectAtIndex:index];
        if(style == eveModel.style){
            [resultArr addObject:eveModel];
        }
    }
    
//    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[resultArr count]];
//    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    [self refreshNumberLblWithLatestNum:[resultArr count]];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = resultArr;
        [self.listTable reloadData];
    });

}
-(void)selectHistoryForSoldOutQuickly
{
    NSArray * sortArr = [NSArray arrayWithArray:self.dataArr];
    
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
    
    //    NSString * noticeStr = [NSString stringWithFormat:@"%lu",[resultArr count]];
    //    [DZUtils noticeCustomerWithShowText:noticeStr];
    
    [self refreshNumberLblWithLatestNum:[resultArr count]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = resultArr;
        [self.listTable reloadData];
    });
    
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
    
//    if(notice){
//        NSString * noticeStr = [NSString stringWithFormat:@"%lu",[resultArr count]];
//        [DZUtils noticeCustomerWithShowText:noticeStr];
//    }
    
    [self refreshNumberLblWithLatestNum:[resultArr count]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataArr = resultArr;
        [self.listTable reloadData];
    });
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
    
    action = [MSAlertAction actionWithTitle:@"全部" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  NSArray * arr = [NSArray arrayWithArray:weakSelf.dataArr];
                  
//                  NSString * noticeStr = [NSString stringWithFormat:@"%lu",[arr count]];
//                  [DZUtils noticeCustomerWithShowText:noticeStr];
                  [weakSelf refreshNumberLblWithLatestNum:[arr count]];

                  weakSelf.dataArr = arr;
                  [weakSelf.listTable reloadData];
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
                  [weakSelf startLatestDetailListRequestForShowedCBGListArr:weakSelf.dataArr];
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
    self.dataArr = array;
    [self.listTable reloadData];
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
