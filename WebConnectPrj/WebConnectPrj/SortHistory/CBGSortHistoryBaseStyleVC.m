//
//  CBGSortHistoryBaseStyleVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/4.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGSortHistoryBaseStyleVC.h"
#define  CBGPlanSortHistoryStyleAddTAG  100

@interface CBGSortHistoryBaseStyleVC ()

@end

@implementation CBGSortHistoryBaseStyleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * bgView = self.view;
    CGFloat btnWidth = SCREEN_WIDTH/3.0;
    CGFloat btnHeight = 40;
    UIButton * btn = nil;
    NSArray * namesArr = @[@"未结束",@"已结束",@"全部"];//按钮点击时，从全部库表选取
    
    CGFloat btnStartY = SCREEN_HEIGHT - btnHeight;
//    for (NSInteger index = 0; index < [namesArr count]; index ++)
//    {
//        NSString * name = [namesArr objectAtIndex:index];
//        btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake(index * btnWidth  , btnStartY, btnWidth - 1, btnHeight);
//        btn.backgroundColor = [UIColor greenColor];
//        [btn setTitle:name forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [bgView addSubview:btn];
//        btn.tag = CBGPlanSortHistoryStyleAddTAG + index;
//        [btn addTarget:self action:@selector(pricePlanBuySelectedTapedOnBtn:) forControlEvents:UIControlEventTouchUpInside];
//    }
    
    //增加分组、门派分组
    namesArr = @[@"时差分组",@"利差分组",@"门派分组",@"无分组"];
    for (NSInteger index = 0; index < [namesArr count]; index ++)
    {
        CGFloat startY = btnStartY - (index) * (btnHeight + 2);
        CGFloat startX = SCREEN_WIDTH - btnWidth;
        NSString * name = [namesArr objectAtIndex:index];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btn.frame = CGRectMake(startX , startY, btnWidth - 1, btnHeight);
        btn.backgroundColor = [UIColor greenColor];
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [bgView addSubview:btn];
        btn.tag = CBGPlanSortHistoryStyleAddTAG + index;
        [btn addTarget:self action:@selector(tapedOnExchangeSortStyleWithTapedBtn:) forControlEvents:UIControlEventTouchUpInside];
    }

}

-(void)tapedOnExchangeSortStyleWithTapedBtn:(id)sender
{
    //重新排序
    UIButton * btn = (UIButton *)sender;
    NSInteger tagIndex = btn.tag - CBGPlanSortHistoryStyleAddTAG;
    switch (tagIndex) {
        case 0:
        {
            self.sortStyle = CBGStaticSortShowStyle_Space;
        }
            break;
        case 1:
        {
            self.sortStyle = CBGStaticSortShowStyle_Rate;
        }
            break;
        case 2:
        {
            self.sortStyle = CBGStaticSortShowStyle_School;
        }
            break;

        default:
            self.sortStyle = CBGStaticSortShowStyle_None;
            break;
    }
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
