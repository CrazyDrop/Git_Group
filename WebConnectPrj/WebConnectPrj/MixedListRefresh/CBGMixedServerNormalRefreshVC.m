//
//  CBGMixedServerNormalRefreshVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/6.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGMixedServerNormalRefreshVC.h"
#import "ZWRefreshListController.h"
#import "ZWServerEquipListVC.h"
@interface CBGMixedServerNormalRefreshVC ()
@property (nonatomic, strong) ZWServerEquipListVC * webVC;
@property (nonatomic, strong) ZWRefreshListController * mobileVC;
@end

@implementation CBGMixedServerNormalRefreshVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView * bgView = self.view;
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGFloat partHeight = SCREEN_HEIGHT/2.0;
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:rect];
    [bgView addSubview:scrollView];
    //    scrollView.contentSize = CGSizeMake(rect.size.width * 2, rect.size.height);
    scrollView.pagingEnabled = YES;
    [scrollView addSubview:self.webVC.view];
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    
    rect.size.height = partHeight;
    self.webVC.view.frame = rect;
    
    UIView * mobileView = self.mobileVC.view;
    rect = mobileView.frame;
    rect.origin.y = partHeight;
    rect.size.height = partHeight;
    mobileView.frame = rect;
    [scrollView addSubview:mobileView];
    self.mobileVC.leftBtn.hidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(ZWServerEquipListVC *)webVC
{
    if(!_webVC)
    {
        ZWServerEquipListVC * aWeb = [[ZWServerEquipListVC alloc] init];
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
