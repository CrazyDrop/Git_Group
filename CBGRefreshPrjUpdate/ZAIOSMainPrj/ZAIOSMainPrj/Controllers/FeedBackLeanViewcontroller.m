//
//  FeedBackLeanViewcontroller.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/1.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "FeedBackLeanViewcontroller.h"
#import "LeanCloudRefreshManager.h"

@interface FeedBackLeanViewcontroller()
@property (nonatomic,assign) BOOL needStop;
@end

@implementation FeedBackLeanViewcontroller
- (instancetype)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.navigationBarStyle = LCUserFeedbackNavigationBarStyleNone;
        self.contactHeaderHidden = YES;
        self.presented = NO;
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        NSString * str = [NSString stringWithFormat:@"刷新间隔 %d",[total.refreshTime intValue]];
        self.viewTtle = str;
        
        NSString * tel = total.userInfo.mobile;
        NSString * contact = [DZUtils currentDeviceIdentifer];
        if(tel){
            contact = [tel stringByAppendingFormat:@"|%@",contact];
        }
        self.contact = contact;
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.needStop = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.needStop) return ;
        [self startLeanCloudRefreshTimer];
    });
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.needStop = YES;
    [[LeanCloudRefreshManager sharedInstance] endAutoRefreshAndClearTime];
}
-(void)startLeanCloudRefreshTimer
{
    LeanCloudRefreshManager * manager = [LeanCloudRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    manager.refreshInterval = 10;
    manager.functionInterval = 10;
    manager.funcBlock = ^()
    {
        [weakSelf localBackgroundUnreadBackNumRefresh];
    };
    [manager saveCurrentAndStartAutoRefresh];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view bringSubviewToFront:topBgView];
    [self.view bringSubviewToFront:self.titleBar];
    
    
    
    CGFloat top = CGRectGetMaxY(self.titleBar.frame);
//    _tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
    
    CGRect rect = _tableView.frame;
    CGFloat moveY = top - rect.origin.y;
    rect.origin.y = top;
    rect.size.height -= moveY;
    
    _tableView.frame = rect;
}


@end
