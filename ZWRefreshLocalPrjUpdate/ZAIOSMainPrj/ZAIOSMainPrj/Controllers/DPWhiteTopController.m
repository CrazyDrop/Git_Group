//
//  DPWhiteTopController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/15.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"

@interface DPWhiteTopController ()

@end

@implementation DPWhiteTopController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(IOS7_OR_LATER)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = Custom_View_Gray_BGColor;

}
//
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

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
