//
//  CBGMixedListCheckVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/29.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGMixedListCheckVC.h"
#import "CBGWebListRefreshVC.h"
#import "ZWRefreshListController.h"
@interface CBGMixedListCheckVC ()
@property (nonatomic, strong) CBGWebListRefreshVC * webVC;
@property (nonatomic, strong) ZWRefreshListController * mobileVC;
@end

@implementation CBGMixedListCheckVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * bgView = self.view;
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:rect];
    [bgView addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(rect.size.width * 2, rect.size.height);
    scrollView.pagingEnabled = YES;
    [scrollView addSubview:self.webVC.view];
    scrollView.bounces = NO;
    
    UIView * mobileView = self.mobileVC.view;
    rect = mobileView.frame;
    rect.origin.x = rect.size.width;
    mobileView.frame = rect;
    [scrollView addSubview:mobileView];
    self.mobileVC.leftBtn.hidden = YES;
    
}

-(CBGWebListRefreshVC *)webVC
{
    if(!_webVC){
        CBGWebListRefreshVC * aWeb = [[CBGWebListRefreshVC alloc] init];
        [self addChildViewController:aWeb];
        _webVC = aWeb;
    }
    return _webVC;
}
-(ZWRefreshListController *)mobileVC
{
    if(!_mobileVC){
        ZWRefreshListController * aWeb = [[ZWRefreshListController alloc] init];
        aWeb.ingoreDB = YES;
        [self addChildViewController:aWeb];
        _mobileVC = aWeb;
    }
    return _mobileVC;
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
