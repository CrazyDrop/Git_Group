//
//  ZAContactAddController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactAddController.h"
#import "ZAAddressController.h"
@interface ZAContactAddController ()
{
    UITextView * contactLbl;
}
@end

@implementation ZAContactAddController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showSpecialStyleTitle];
    
    //通讯录
    UIButton * tapTestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tapTestBtn.frame = CGRectMake(0, 0, 100, 100);
    [tapTestBtn setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:tapTestBtn];
    [tapTestBtn setTitle:@"添加" forState:UIControlStateNormal];
    [tapTestBtn addTarget:self action:@selector(tapedOnTestBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UITextView * lbl =  [[UITextView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_HEIGHT, 100)];
    [self.view addSubview:lbl];
    lbl.backgroundColor = [UIColor clearColor];
    contactLbl = lbl;
    
}

-(void)tapedOnTestBtn:(id)sender
{
//    __weak typeof(self)  weakSelf = self;
    
//#ifdef __IPHONE_8_0
//    [[ZCAddressBook shareControl] initWithTarget:self PhoneView:^(BOOL success, NSDictionary *dic) {
//        if(success)
//        {
//            [weakSelf refreshContactWithBackDic:dic];
//        }
//    }];
//    return;
//#endif

    ZAAddressController * address  = [[ZAAddressController alloc] init];
    [[self rootNavigationController] pushViewController:address animated:YES];
    
}

-(void)refreshContactWithBackDic:(NSDictionary *)dic
{
    contactLbl.text = [dic description];
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
