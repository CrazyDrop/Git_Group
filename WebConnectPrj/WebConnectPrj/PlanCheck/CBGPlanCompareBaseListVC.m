//
//  CBGPlanCompareBaseListVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanCompareBaseListVC.h"
#import "RefreshListCell.h"
#import "ZACBGDetailWebVC.h"
#import "CBGCompareSameRoleVC.h"
#import "ZALocalStateTotalModel.h"
#import "CBGFutureStatusSortVC.h"
#define  CBGPlanCompareHistoryAddTAG  100

@interface CBGPlanCompareBaseListVC ()
@end

@implementation CBGPlanCompareBaseListVC

- (void)viewDidLoad {
    
    self.showRightBtn = YES;
    self.rightTitle = @"筛选";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortStyle = CBGStaticSortShowStyle_School;
    
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
        btn.tag = CBGPlanCompareHistoryAddTAG + index;
        [btn addTarget:self action:@selector(pricePlanBuySelectedTapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //控制起始数据源，db筛选规则
    [self startShowedLatestHistoryDBList];
}
-(void)refreshLatestShowedDBArrayWithNotice:(BOOL)notice{
    [self startShowedLatestHistoryDBList];
}

-(void)startShowedLatestHistoryDBList
{
    if(!self.dbHistoryArr) return;
    
    [self refreshLatestShowTableView];
}

-(void)pricePlanBuySelectedTapedOnBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger tagIndex = btn.tag - CBGPlanCompareHistoryAddTAG;
    
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
-(void)showDetailFutureStatusSortVC
{
    CBGFutureStatusSortVC * future = [[CBGFutureStatusSortVC alloc] init];
    future.dbHistoryArr = [NSArray arrayWithArray:[self latestTotalShowedHistoryList]];
    [[self rootNavigationController] pushViewController:future animated:YES];
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
    
    action = [MSAlertAction actionWithTitle:@"化圣相关" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showDetailFutureStatusSortVC];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"WEB刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf startLatestDetailListRequestForShowedCBGListArr:[weakSelf latestTotalShowedHistoryList]];
              }];
    [alertController addAction:action];
    
    NSArray * funcArr =  [self moreFunctionsForDetailSubVC];
    for (MSAlertAction * eveAlert in funcArr )
    {
        [alertController addAction:eveAlert];
    }
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}
-(NSArray *)moreFunctionsForDetailSubVC
{
    return nil;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    NSArray * subArr = [self.showSortArr objectAtIndex:secNum];
    CBGListModel * contact = [subArr objectAtIndex:rowNum];
    NSString * selectId = contact.owner_roleid;
    
    
    CBGEquipRoleState state = contact.latestEquipListStatus;
    NSMutableArray * showArr = [NSMutableArray array];
    
    for (NSInteger index = -2;index <= 2; index ++)
    {
        NSInteger eveIndex = rowNum + index;
        if(eveIndex >= 0 && [subArr count] > eveIndex)
        {
            CBGListModel * eveModel = [subArr objectAtIndex:eveIndex];
            if([selectId isEqualToString:eveModel.owner_roleid])
            {
                [showArr addObject:eveModel];
            }
        }
    }
    
    
    //跳转条件  1详情页面时，非自己id   2非详情页面、仅历史库表取出数据
    //    BOOL detailSelect = (self.selectedRoleId > 0 && self.selectedRoleId != [contact.owner_roleid integerValue]);
    //    BOOL nearSelect = (self.selectedRoleId == 0 && state == CBGEquipRoleState_PayFinish);
    CBGCompareSameRoleVC * compare = [[CBGCompareSameRoleVC alloc] init];
    compare.compareArr = showArr;
    [[self rootNavigationController] pushViewController:compare animated:YES];
    
    
}

#pragma mark -

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
