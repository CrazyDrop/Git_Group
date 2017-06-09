//
//  ZWPanicMaxCombinedVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicMaxCombinedVC.h"
#import "ZWPaincCombineBaseVC.h"
#import "PanicRefreshManager.h"

@interface ZWPanicMaxCombinedVC ()
@property (nonatomic,strong) NSArray * panicTagArr;
@property (nonatomic,strong) NSArray * baseVCArr;
@property (nonatomic,strong) UIScrollView * coverScroll;
@end

@implementation ZWPanicMaxCombinedVC

-(NSArray *)panicTagArr
{
    if(!_panicTagArr){
        NSMutableArray * tag = [NSMutableArray array];
        NSInteger totalNum  = 15;
        NSArray * sepArr = @[@1,@2,@6,@7,@4,@10,@11];
        for (NSInteger index = 1 ; index <= totalNum ; index ++)
        {
            NSNumber * num = [NSNumber numberWithInteger:index];
            if([sepArr containsObject:num])
            {
                NSString * eve1 = [NSString  stringWithFormat:@"%ld_1",(long)index];
                NSString * eve2 = [NSString  stringWithFormat:@"%ld_2",(long)index];
                [tag addObject:eve1];
                [tag addObject:eve2];
            }else{
                NSString * eve = [NSString  stringWithFormat:@"%ld_0",(long)index];
                [tag addObject:eve];
            }
        }
        self.panicTagArr = tag;
    }
    return _panicTagArr;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    [self startLocationDataRequest];
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s disappear",__FUNCTION__);
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [UIApplication sharedApplication].idleTimerDisabled=NO;

    PanicRefreshManager * manager = [PanicRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];

    [[ZALocation sharedInstance] stopUpdateLocation];

}
-(void)startLocationDataRequest
{
    ZALocation * locationInstance = [ZALocation sharedInstance];
    [locationInstance startLocationRequestUserAuthorization];
    __weak typeof(self) weakSelf = self;
    
    
    [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *location){
        [weakSelf backLocationDataWithString:location];
    }];
}
-(void)backLocationDataWithString:(id)obj
{
    PanicRefreshManager * manager = [PanicRefreshManager sharedInstance];
    if(manager.isRefreshing) return;
    [self startOpenTimesRefreshTimer];
}
-(void)startOpenTimesRefreshTimer
{
    
    PanicRefreshManager * manager = [PanicRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    //    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger time = 3;
    //    if(total.refreshTime && [total.refreshTime intValue]>0){
    //        time = [total.refreshTime intValue];
    //    }
    manager.refreshInterval = time;
    manager.functionInterval = time;
    manager.funcBlock = ^()
    {
        NSArray * vcArr = weakSelf.baseVCArr;
        for (ZWPaincCombineBaseVC * eveBase in vcArr)
        {
            [eveBase performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                                       withObject:nil
                                    waitUntilDone:NO];
            
            [eveBase performSelectorOnMainThread:@selector(startRefreshLatestDetailModelRequest)
                                       withObject:nil
                                    waitUntilDone:NO];

        }
    };
    [manager saveCurrentAndStartAutoRefresh];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIView * bgView = self.view;
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:rect];
    [bgView addSubview:scrollView];
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    self.coverScroll = scrollView;
    
    NSInteger vcNum = [self.panicTagArr count];
    NSMutableArray * vcArr = [NSMutableArray array];
    scrollView.contentSize = CGSizeMake(rect.size.width * vcNum, rect.size.height);
    
    CGRect subRect = rect;
    for (NSInteger index = 0; index < vcNum; index ++)
    {
        NSString * eveTag = [self.panicTagArr objectAtIndex:index];
        ZWPaincCombineBaseVC * eveVC = [[ZWPaincCombineBaseVC alloc] init];
        eveVC.tagString = eveTag;
        [self addChildViewController:eveVC];
        [vcArr addObject:eveVC];
        
        subRect.origin.x = index * SCREEN_WIDTH;
        eveVC.view.frame = subRect;
        [scrollView addSubview:eveVC.view];
    }
    
    self.baseVCArr = vcArr;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPaincVCScrollWithRefreshNoti:)
                                                 name:NOTIFICATION_ZWPANIC_REFRESH_STATE
                                               object:nil];
    
    
}
-(void)refreshPaincVCScrollWithRefreshNoti:(NSNotification *)not
{
    NSString * tag = not.object;
    if([tag length] > 0)
    {
        NSInteger index = [self.panicTagArr indexOfObject:tag];
        CGPoint pt = CGPointMake(SCREEN_WIDTH * index, 0);
        [self.coverScroll setContentOffset:pt animated:YES];
    }
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
