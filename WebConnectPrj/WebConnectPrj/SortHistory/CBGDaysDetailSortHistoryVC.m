//
//  CBGDaysDetailSortHistoryVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/1.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGDaysDetailSortHistoryVC.h"
#import "CBGCombinedHistoryHandleVC.h"
#import "NSDate+Extension.h"
#import "CBGCombinedScrolledHandleVC.h"
#define HOUR_NUM_SCALE 50 //为实现循环滚动，小时数据源放大倍数
#define MINU_NUM_SCALE 30  //为实现循环滚动，分钟数据源放大倍数
@interface CBGDaysDetailSortHistoryVC ()<UIPickerViewDelegate>
{
}
@property (nonatomic,weak) UIDatePicker * pickView;

@end

@implementation CBGDaysDetailSortHistoryVC

- (void)viewDidLoad {
    
    self.viewTtle = @"选择时间";
    self.rightTitle = @"分类";
    self.showRightBtn = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.listTable.hidden = YES;
    UIView * bgView = self.view;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.size.height = FLoatChange(138);
    CGPoint pt = rect.origin;
    pt.y = FLoatChange(158);
    rect.origin = pt;
    
    UIDatePicker * pickerView = [[UIDatePicker alloc] initWithFrame:rect];
    [bgView addSubview:pickerView];
    self.pickView = pickerView;
    pickerView.datePickerMode = UIDatePickerModeDate;

    
    [pickerView setDate:[NSDate date]];
    
    
    UIButton * bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomBtn.frame = CGRectMake(0, 0, 100, 80);
    [bottomBtn setBackgroundColor:[UIColor greenColor]];
    [bottomBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [bottomBtn setTitle:@"分类" forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:bottomBtn];
    bottomBtn.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(pickerView.frame) + 100);
}


-(void)showDetailSortHistoryWithDataInDays:(BOOL)day inPlanStyle:(BOOL)plan
{
    NSDate * date = self.pickView.date;
    
    NSString * todayDate = [[NSDate format] stringFromDate:date];

    if(day)
    {
        todayDate = [todayDate substringToIndex:[@"2017-03-29" length]];
    }else
    {
        todayDate = [todayDate substringToIndex:[@"2017-03" length]];
    }
    
    CBGCombinedScrolledHandleVC * combine = [[CBGCombinedScrolledHandleVC alloc] init];
    combine.selectedDate = todayDate;
    combine.showStyle = plan?CBGCombinedHandleVCStyle_Plan:CBGCombinedHandleVCStyle_Statist;
    
    [[self rootNavigationController] pushViewController:combine animated:YES];
}
-(void)showYearSortHistoryWithPlanStyle:(BOOL)plan
{
    NSDate * date = self.pickView.date;
    
    NSString * todayDate = [[NSDate format] stringFromDate:date];
    todayDate = [todayDate substringToIndex:[@"2017" length]];
    
    //    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    //    NSArray * dbArray = [manager localSaveEquipHistoryModelListForTime:todayDate];
    
    CBGCombinedScrolledHandleVC * combine = [[CBGCombinedScrolledHandleVC alloc] init];
    combine.selectedDate = todayDate;
    combine.showStyle = plan?CBGCombinedHandleVCStyle_Plan:CBGCombinedHandleVCStyle_Statist;
    
    [[self rootNavigationController] pushViewController:combine animated:YES];

}
-(void)showWithDeepStudyStyleWithDateLength:(NSInteger)length
{
    NSDate * date = self.pickView.date;
    
    NSString * todayDate = [[NSDate format] stringFromDate:date];
    todayDate = [todayDate substringToIndex:length];
    
    //    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    //    NSArray * dbArray = [manager localSaveEquipHistoryModelListForTime:todayDate];
    
    CBGCombinedScrolledHandleVC * combine = [[CBGCombinedScrolledHandleVC alloc] init];
    combine.selectedDate = todayDate;
    combine.showStyle = CBGCombinedHandleVCStyle_Study;
    
    [[self rootNavigationController] pushViewController:combine animated:YES];
    
}

-(void)showDetailChooseForHistory
{//纵横两个维度看
    //    1、通过进入数据，控制数据的相关程度
    //    2、估价情况  1、有利  2、值得  3、不值  4、全部
    //    3、列表筛选  筛选  已售出  未售出 全部
    NSString * log = [NSString stringWithFormat:@"选择数据展示形式？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"估价历史(天)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf showDetailSortHistoryWithDataInDays:YES inPlanStyle:YES];
                             }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"估价历史(月)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showDetailSortHistoryWithDataInDays:NO inPlanStyle:YES];
                  
              }];
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"估价历史(年)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showYearSortHistoryWithPlanStyle:YES];
                  
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"统计历史(天)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showDetailSortHistoryWithDataInDays:YES inPlanStyle:NO];

              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"统计历史(月)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showDetailSortHistoryWithDataInDays:NO inPlanStyle:NO];

              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"统计历史(年)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showYearSortHistoryWithPlanStyle:NO];
                  
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"历史图表(天)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showWithDeepStudyStyleWithDateLength:[@"2017-03-29" length]];
                  
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"历史图表(月)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showWithDeepStudyStyleWithDateLength:[@"2017-03" length]];
                  
              }];
    
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"历史图表(年)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showWithDeepStudyStyleWithDateLength:[@"2017" length]];
                  
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
