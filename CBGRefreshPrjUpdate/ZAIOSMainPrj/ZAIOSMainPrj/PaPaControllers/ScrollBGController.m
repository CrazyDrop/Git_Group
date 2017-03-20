//
//  ScrollBGController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ScrollBGController.h"

@interface ScrollBGController ()

@end

@implementation ScrollBGController

- (IIViewDeckController*)viewDeckController
{
    UIViewController * vc = nil;
    if(self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(scrollContainConrollerForHome)])
    {
        vc = [self.controllerDelegate scrollContainConrollerForHome];
    }
    
    return vc.viewDeckController;
}

- (void)showLoading
{
    DPViewController * vc = nil;
    if(self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(scrollContainConrollerForHome)])
    {
        vc = (DPViewController *)[self.controllerDelegate scrollContainConrollerForHome];
    }
    [vc showLoading];
    
}
- (void)hideLoading
{
    DPViewController * vc = nil;
    if(self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(scrollContainConrollerForHome)])
    {
        vc = (DPViewController *)[self.controllerDelegate scrollContainConrollerForHome];
    }
    [vc hideLoading];
}


-(NSString *)classNameForKMRecord
{
    return nil;
//    NSString * str  = [super classNameForKMRecord];
//    return str;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showSpecialStyleTitle];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
    img.image = [UIImage imageNamed:@"dark_blue_total"];
    img.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:img];
    
    [self.view sendSubviewToBack:img];
    
    // Do any additional setup after loading the view.
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
