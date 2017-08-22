//
//  ServerCheckMainVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/21.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ServerCheckMainVC.h"
#import "ServerCheckPlanTestVC.h"
#import "ServerCheckEquipDBTestVC.h"
#import "ServerCheckSignalTestVC.h"

@interface ServerCheckMainVC ()

@end

@implementation ServerCheckMainVC

- (void)viewDidLoad {
    self.viewTtle = @"校验主页";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray * testFuncArr = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:CBGServerEquipCheckMainFunctionStyle_JuSeList],
                             [NSNumber numberWithInt:CBGServerEquipCheckMainFunctionStyle_EquipSignal],
                             
                             [NSNumber numberWithInt:CBGServerEquipCheckMainFunctionStyle_EquipList],
                             //                             [NSNumber numberWithInt:CBGHistoryMianFunctionStyle_RepeatHistory],
                             
                             
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
-(NSString *)functionNamesForDetailFunctionStyle:(CBGServerEquipCheckMainFunctionStyle)style
{
    NSString * name = @"未知";
    switch (style)
    {
        case CBGServerEquipCheckMainFunctionStyle_None:
        {
            //            name = @"全部历史";
        }
            break;
            
        case CBGServerEquipCheckMainFunctionStyle_JuSeList:
        {
            name = @"角色列表";
        }
            break;
        case CBGServerEquipCheckMainFunctionStyle_EquipList:
        {
            name = @"全部列表";
        }
            break;
        case CBGServerEquipCheckMainFunctionStyle_EquipSignal:
        {
            name = @"单个物品";
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
        case CBGServerEquipCheckMainFunctionStyle_JuSeList:
        {
            ServerCheckPlanTestVC * list = [[ServerCheckPlanTestVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;
        case CBGServerEquipCheckMainFunctionStyle_EquipList:
        {
            ServerCheckEquipDBTestVC * list = [[ServerCheckEquipDBTestVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
        }
            break;
        case CBGServerEquipCheckMainFunctionStyle_EquipSignal:
        {
            ServerCheckSignalTestVC * list = [[ServerCheckSignalTestVC alloc] init];
            [[self rootNavigationController] pushViewController:list animated:YES];
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
