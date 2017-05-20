//
//  CBGPanicMixedNightListVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPanicMixedNightListVC.h"
#import "ZWRefreshListController.h"
#import "ZWPanicRefreshController.h"
@interface CBGPanicMixedNightListVC ()
@property (nonatomic, strong) ZWRefreshListController * webVC;
@property (nonatomic, strong) ZWPanicRefreshController * mobileVC;
@end

@implementation CBGPanicMixedNightListVC

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

-(ZWRefreshListController *)webVC
{
    if(!_webVC){
        ZWRefreshListController * aWeb = [[ZWRefreshListController alloc] init];
        aWeb.maxRefresh = YES;
        [self addChildViewController:aWeb];
        _webVC = aWeb;
    }
    return _webVC;
}
-(ZWPanicRefreshController *)mobileVC
{
    if(!_mobileVC){
        ZWPanicRefreshController * aWeb = [[ZWPanicRefreshController alloc] init];
        aWeb.ingoreFirst = YES;
        aWeb.requestNum = 20;
        [self addChildViewController:aWeb];
        _mobileVC = aWeb;
    }
    return _mobileVC;
}



@end
