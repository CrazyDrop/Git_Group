//
//  CBGMixedServerMobileRefreshVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/28.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGMixedServerMobileRefreshVC.h"
#import "ZWRefreshListController.h"
#import "ZWServerRefreshListVC.h"
@interface CBGMixedServerMobileRefreshVC ()
@property (nonatomic, strong) ZWServerRefreshListVC * webVC;
@property (nonatomic, strong) ZWRefreshListController * mobileVC;
@end

@implementation CBGMixedServerMobileRefreshVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(ZWServerRefreshListVC *)webVC
{
    if(!_webVC)
    {
        ZWServerRefreshListVC * aWeb = [[ZWServerRefreshListVC alloc] init];
        [self addChildViewController:aWeb];
        _webVC = aWeb;
    }
    return _webVC;
}
-(ZWRefreshListController *)mobileVC
{
    if(!_mobileVC){
        ZWRefreshListController * aWeb = [[ZWRefreshListController alloc] init];
        aWeb.onlyList = YES;
        [self addChildViewController:aWeb];
        _mobileVC = aWeb;
    }
    return _mobileVC;
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
