//
//  CBGHistoryMianListVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGHistoryMianListVC.h"
#import "CBGPlanListDetailCheckVC.h"
#import "CBGTotalHistroySortVC.h"
#import "CBGMaxHistoryListRefreshVC.h"
#import "ZALocationLocalModel.h"
#import "CBGCombinedScrolledHandleVC.h"
#import "CBGDaysDetailSortHistoryVC.h"
#import "CBGTotalHistroySortVC.h"
@interface CBGHistoryMianListVC ()

@end

@implementation CBGHistoryMianListVC

- (void)viewDidLoad {
    self.viewTtle = @"历史主页";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray * testFuncArr = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:CBGHistoryMianFunctionStyle_TotalHistory],
                             [NSNumber numberWithInt:CBGHistoryMianFunctionStyle_UpdateTotal],
                             
                             [NSNumber numberWithInt:CBGHistoryMianFunctionStyle_TodayHistory],
                             [NSNumber numberWithInt:CBGHistoryMianFunctionStyle_MonthHistory],
                             
                             [NSNumber numberWithInt:CBGHistoryMianFunctionStyle_PartHistory],
//                             [NSNumber numberWithInt:CBGHistoryMianFunctionStyle_RepeatHistory],
                             [NSNumber numberWithInt:CBGHistoryMianFunctionStyle_HistoryTotal],

                             
                             nil];
    
    UIView * bgView = self.view;
    for(NSInteger index = 0 ;index < [testFuncArr count]; index ++)
    {
        NSNumber * num = [testFuncArr objectAtIndex:index];
        NSString * title = [self functionNamesForDetailFunctionStyle:[num integerValue]];
        UIButton * btn = [self customTestButtonForIndex: index andMoreTag:[num integerValue]];
        [btn setTitle:title forState:UIControlStateNormal];
        [bgView addSubview:btn];
    }
    
//    UITextView * txt = [[UITextView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, 80)];
//    [bgView addSubview:txt];
//    self.textView = txt;
}
-(NSString *)functionNamesForDetailFunctionStyle:(CBGHistoryMianFunctionStyle)style
{
    NSString * name = @"未知";
    switch (style)
    {
        case CBGHistoryMianFunctionStyle_None:
        {
//            name = @"全部历史";
        }
            break;

        case CBGHistoryMianFunctionStyle_TotalHistory:
        {
            name = @"全部历史";
        }
            break;
        case CBGHistoryMianFunctionStyle_UpdateTotal:
        {
            name = @"更新全部";
        }
            break;
        case CBGHistoryMianFunctionStyle_RepeatHistory:
        {
            name = @"倒卖历史";
        }
            break;
        case CBGHistoryMianFunctionStyle_PartHistory:
        {
            name = @"分段历史";
        }
            break;
        case CBGHistoryMianFunctionStyle_MonthHistory:
        {
            name = @"本月历史";
        }
            break;
        case CBGHistoryMianFunctionStyle_TodayHistory:
        {
            name = @"当天历史";
        }
            break;
        case CBGHistoryMianFunctionStyle_HistoryTotal:{
            name = @"全部历史";
        }
            break;
    }
    
    return name;
}

-(UIButton * )customTestButtonForIndex:(NSInteger)indexNum andMoreTag:(NSInteger)tag
{
    NSInteger lineNum = indexNum/2;
    NSInteger rowNum = indexNum%2;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag + RefreshListMoreAppendTagNum;
    btn.frame = CGRectMake(0, 0,FLoatChange(120) ,FLoatChange(50));
    btn.backgroundColor = [UIColor grayColor];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tapedOnTestButtonWithSender:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame) + FLoatChange(20) + btn.bounds.size.height/2.0;
    CGFloat sepHeight = FLoatChange(10);
    CGFloat startX = SCREEN_WIDTH / 2.0 /2.0;
    btn.center = CGPointMake( startX + rowNum * SCREEN_WIDTH / 2.0 ,startY + (sepHeight + btn.bounds.size.height) * lineNum);
    
    return btn;
}


-(void)tapedOnTestButtonWithSender:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger indexNum = btn.tag - RefreshListMoreAppendTagNum;
    
    [self debugDetailTestWithIndexNum:indexNum andTitle:btn.titleLabel.text];
}
-(void)debugDetailTestWithIndexNum:(NSInteger)indexNum andTitle:(NSString *)title
{
    NSLog(@"%s %@",__FUNCTION__,title);
    switch (indexNum) {
        case CBGHistoryMianFunctionStyle_TotalHistory:
        {
            CBGTotalHistroySortVC * history = [[CBGTotalHistroySortVC alloc] init];
            [[self rootNavigationController] pushViewController:history animated:YES];
        }
            break;
        case CBGHistoryMianFunctionStyle_UpdateTotal:
        {
            ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
            NSArray *   soldout = [dbManager localSaveEquipHistoryModelListTotal];
            
            CBGMaxHistoryListRefreshVC * list = [[CBGMaxHistoryListRefreshVC alloc] init];
            list.startArr = soldout;
            [[self rootNavigationController] pushViewController:list animated:YES];        }
            break;

        case CBGHistoryMianFunctionStyle_MonthHistory:
        {
            NSString * todayDate = [NSDate unixDate];
            
            if(todayDate)
            {
                todayDate = [todayDate substringToIndex:[@"2017-03" length]];
            }
            
            CBGCombinedScrolledHandleVC * combine = [[CBGCombinedScrolledHandleVC alloc] init];
            combine.selectedDate = todayDate;
            combine.showStyle = CBGCombinedHandleVCStyle_Plan;
            
            [[self rootNavigationController] pushViewController:combine animated:YES];        }
            break;

        case CBGHistoryMianFunctionStyle_PartHistory:
        {
            CBGDaysDetailSortHistoryVC * plan = [[CBGDaysDetailSortHistoryVC alloc] init];
            [[self rootNavigationController] pushViewController:plan animated:YES];
        }
            break;
        case CBGHistoryMianFunctionStyle_TodayHistory:
        {
            NSString * todayDate = [NSDate unixDate];
            
            if(todayDate)
            {
                todayDate = [todayDate substringToIndex:[@"2017-03-29" length]];
            }
            
            CBGCombinedScrolledHandleVC * combine = [[CBGCombinedScrolledHandleVC alloc] init];
            combine.selectedDate = todayDate;
            combine.showStyle = CBGCombinedHandleVCStyle_Plan;
            
            [[self rootNavigationController] pushViewController:combine animated:YES];
        }
            break;
        case CBGHistoryMianFunctionStyle_RepeatHistory:
        {
            CBGPlanListDetailCheckVC * combine = [[CBGPlanListDetailCheckVC alloc] init];
            [[self rootNavigationController] pushViewController:combine animated:YES];
            
        }
            break;
        case CBGHistoryMianFunctionStyle_HistoryTotal:
        {
            CBGTotalHistroySortVC * combine = [[CBGTotalHistroySortVC alloc] init];
            [[self rootNavigationController] pushViewController:combine animated:YES];
        }
            break;


    }
    
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
