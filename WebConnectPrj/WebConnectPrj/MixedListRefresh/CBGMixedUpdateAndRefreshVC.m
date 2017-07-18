//
//  CBGMixedUpdateAndRefreshVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/18.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGMixedUpdateAndRefreshVC.h"
#import "CBGMaxHistoryListRefreshVC.h"
#import "ZWRefreshListController.h"
#import "ZALocationLocalModel.h"
@interface CBGMixedUpdateAndRefreshVC ()
@property (nonatomic, strong) CBGMaxHistoryListRefreshVC * webVC;
@property (nonatomic, strong) ZWRefreshListController * mobileVC;
@end

@implementation CBGMixedUpdateAndRefreshVC

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

-(CBGMaxHistoryListRefreshVC *)webVC
{
    if(!_webVC)
    {
        CBGMaxHistoryListRefreshVC * aWeb = [[CBGMaxHistoryListRefreshVC alloc] init];
        [self addChildViewController:aWeb];
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        NSArray *   soldout = [dbManager localSaveEquipHistoryModelListTotalWithUnFinished];
        aWeb.startArr = soldout;
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
