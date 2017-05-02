//
//  CBGPlanListDetailCheckVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanListDetailCheckVC.h"
#import "CBGOwnerRepeatListVC.h"
#import "CBGOthersBuyRepeatListVC.h"
#import "CBGPlanCommonCheckListVC.h"
#import "CBGPlanCheckSpecialListVC.h"
#import "EquipExtraModel.h"
#define PlanCheckDetailListAddNum 100
@interface CBGPlanListDetailCheckVC ()
@property (nonatomic,strong) UITextView * textView;

@end

@implementation CBGPlanListDetailCheckVC

- (void)viewDidLoad {
    
    self.viewTtle = @"买卖分析";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //copy信息抓去，解析，展示
    
    NSArray * titles = [NSArray arrayWithObjects:
                        @"倒卖列表",
                        @"购买列表",//标识
                                               
                        @"合服异常",//特殊数据
                        @"分项检查",//特殊数据
                        
                        @"售出检查",//特征数据
                        nil];
    
    UIView * bgView = self.view;
    for(NSInteger index = 0 ;index < [titles count]; index ++)
    {
        NSString * title = [titles objectAtIndex:index];
        UIButton * btn = [self customTestButtonForIndex: index];
        [btn setTitle:title forState:UIControlStateNormal];
        [bgView addSubview:btn];
    }
    
    
//    UITextView * txt = [[UITextView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, 80)];
//    [bgView addSubview:txt];
//    self.textView = txt;
    
    
}
-(UIButton * )customTestButtonForIndex:(NSInteger)indexNum
{
    NSInteger lineNum = indexNum/2;
    NSInteger rowNum = indexNum%2;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = indexNum + PlanCheckDetailListAddNum;
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
    NSInteger indexNum = btn.tag - PlanCheckDetailListAddNum;
    
    [self debugDetailTestWithIndexNum:indexNum andTitle:btn.titleLabel.text];
}
-(void)debugDetailTestWithIndexNum:(NSInteger)indexNum andTitle:(NSString *)title
{
    switch (indexNum) {
        case 0:
        {
            CBGOthersBuyRepeatListVC * others = [[CBGOthersBuyRepeatListVC alloc] init];
            [[self rootNavigationController] pushViewController:others animated:YES];
        }
            break;

        case 1:
        {
            CBGOwnerRepeatListVC * others = [[CBGOwnerRepeatListVC alloc] init];
            [[self rootNavigationController] pushViewController:others animated:YES];
        }
            break;

        case 2:
        {
            CBGPlanCommonCheckListVC * others = [[CBGPlanCommonCheckListVC alloc] init];
            [[self rootNavigationController] pushViewController:others animated:YES];
        }
            break;
        case 3:{
            EquipExtraModel * extra = [[EquipExtraModel alloc] init];
            [extra detailSubCheck];
        }
            break;
        case 4:
        {
            CBGPlanCheckSpecialListVC * plan = [[CBGPlanCheckSpecialListVC alloc] init];
            [[self rootNavigationController] pushViewController:plan animated:YES];
        }
            break;

        default:
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
