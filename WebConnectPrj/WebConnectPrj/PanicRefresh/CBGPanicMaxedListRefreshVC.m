//
//  CBGPanicMaxedListRefreshVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/19.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPanicMaxedListRefreshVC.h"
#import "CBGWebListRefreshVC.h"
#import "ZWPanicRefreshController.h"
@interface CBGPanicMaxedListRefreshVC ()
@property (nonatomic, strong) CBGWebListRefreshVC * webVC;
@property (nonatomic, strong) ZWPanicRefreshController * mobileVC;
@end

@implementation CBGPanicMaxedListRefreshVC

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

-(CBGWebListRefreshVC *)webVC
{
    if(!_webVC){
        CBGWebListRefreshVC * aWeb = [[CBGWebListRefreshVC alloc] init];
        [self addChildViewController:aWeb];
        _webVC = aWeb;
    }
    return _webVC;
}
-(ZWPanicRefreshController *)mobileVC
{
    if(!_mobileVC){
        ZWPanicRefreshController * aWeb = [[ZWPanicRefreshController alloc] init];
//        aWeb.ingoreDB = YES;
        [self addChildViewController:aWeb];
        _mobileVC = aWeb;
    }
    return _mobileVC;
}


@end
