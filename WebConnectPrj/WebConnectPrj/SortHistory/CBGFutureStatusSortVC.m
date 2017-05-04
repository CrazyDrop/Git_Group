//
//  CBGFutureStatusSortVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/4/28.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGFutureStatusSortVC.h"
#define  CBGFutureStatusAddTAG  100

@interface CBGFutureStatusSortVC ()
@property (nonatomic, strong) NSArray * preTotalArr;

@end

@implementation CBGFutureStatusSortVC

- (void)viewDidLoad {
    self.viewTtle = @"化圣相关";
    
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
    NSArray * namesArr = @[@"化圣",@"准化圣",@"全部"];//按钮点击时，从全部库表选取
    
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
        btn.tag = CBGFutureStatusAddTAG + index;
        [btn addTarget:self action:@selector(pricePlanBuySelectedTapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    self.preTotalArr = [NSArray arrayWithArray:self.dbHistoryArr];
    //展示售出  有利
    [self selectHistoryForPlanStartedLoad];
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
        if(eveModel.equip_accept == 2)
        {
            [resultArr addObject:eveModel];
        }
    }
    
    self.dbHistoryArr = resultArr;
    
    self.finishStyle = CBGSortShowFinishStyle_Total;
    [self refreshLatestShowTableView];
}

-(void)pricePlanBuySelectedTapedOnBtn:(id)sender
{
    
    self.finishStyle = CBGSortShowFinishStyle_Total;
    //从全部中选取
    
    NSArray * total = self.preTotalArr;
    NSMutableArray * selectedArr = [NSMutableArray array];
    UIButton * btn = (UIButton *)sender;
    NSInteger tagIndex = btn.tag - CBGFutureStatusAddTAG;
    
    for (NSInteger index = 0;index < [total count] ;index ++ )
    {
        CBGListModel * list = [total objectAtIndex:index];
        NSInteger status = list.equip_accept;
        
        switch (tagIndex) {
            case 0:
            {
                if(status == 2)
                {
                    [selectedArr addObject:list];
                }
            }
                break;
            case 1:
            {
                if(status == 1)
                {
                    [selectedArr addObject:list];
                }
                
            }
                break;
                
            case 2:
            {
                if(status != 0)
                {
                    [selectedArr addObject:list];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    self.dbHistoryArr = selectedArr;
    
    [self refreshLatestShowTableView];
    
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
