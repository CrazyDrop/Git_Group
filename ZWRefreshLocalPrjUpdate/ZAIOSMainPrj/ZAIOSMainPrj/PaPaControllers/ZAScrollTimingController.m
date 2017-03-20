//
//  ZAScrollTimingController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAScrollTimingController.h"
#import "ScrollQuickController.h"
#import "ScrollTimingController.h"

@interface ZAScrollTimingController ()<UIScrollViewDelegate,ScrollContainControllerDelegate>
{
    ScrollQuickController * quick;
    ScrollTimingController * timing;
    
    UIScrollView * viewScroll;
    BOOL needAnimated;
    
    CGPoint topEndPoint;
}
@property (nonatomic,strong)  UIView * redCircle1;
@property (nonatomic,strong)  UIView * redCircle2;
@end

@implementation ZAScrollTimingController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        quick = [[ScrollQuickController alloc] init];
        quick.controllerDelegate = self;
        
        timing = [[ScrollTimingController alloc] init];
        timing.controllerDelegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshRedCircleForNotification:)
                                                     name:NOTIFICATION_CONTACT_REDCIRCLE_STATE
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noticeUserForCancelRecorder:)
                                                     name:NOTIFICATION_RECORDER_CANCEL_STATE
                                                   object:nil];
    }
    return self;
}
-(void)noticeUserForCancelRecorder:(NSNotification *)noti
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DZUtils noticeCustomerWithShowText:@"录音已取消"];
    });

}

-(NSString *)classNameForKMRecord
{
    NSString * str  = [super classNameForKMRecord];
    
    NSString * tag = @"_timing";
    CGPoint pt = CGPointZero;
    if(CGPointEqualToPoint(pt, topEndPoint))
    {
        tag = @"_quick";
    }
    
    str = [str stringByAppendingString:tag];
    return str;
}
-(void)refreshRedCircleForNotification:(NSNotification *)noti
{
    //展示状态，不再使用传递过来数据
    NSNumber * num = noti.object;
    BOOL showState = [num boolValue];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    showState = [ContactsModel contactNeedRedStateForContactListArr:total.contacts];
    
    //数据状态保存，以便下次刷新
    total.contactRed_Need_Show = showState;
    [total localSave];
    
    self.redCircle1.hidden = !showState;
    self.redCircle2.hidden = !showState;
}
-(UIView *)redCircle1
{
    if(!_redCircle1)
    {
        CGFloat redWidth = FLoatChange(8);
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, redWidth, redWidth)];
        aView.backgroundColor = [DZUtils colorWithHex:@"FF4D4D"];
        [aView.layer setCornerRadius:redWidth/2.0];
        self.redCircle1 = aView;
    }
    return _redCircle1;
}
-(UIView *)redCircle2
{
    if(!_redCircle2)
    {
        CGFloat redWidth = FLoatChange(8);
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, redWidth, redWidth)];
        aView.backgroundColor = [DZUtils colorWithHex:@"FF4D4D"];
        [aView.layer setCornerRadius:redWidth/2.0];
        self.redCircle2 = aView;
    }
    return _redCircle2;
}

-(UIButton *)coverBtn
{
    CGPoint pt = CGPointZero;
    if(CGPointEqualToPoint(pt, topEndPoint))
    {
        return quick.coverBtn;
    }
    return timing.coverBtn;
}

-(UIViewController *)scrollContainConrollerForHome
{
    return self;
}
-(void)scrollContainViewWithTimingString:(NSString *)str
{
//    NSLog(@"%s %@",__FUNCTION__,str);
    CGPoint prePt = viewScroll.contentOffset;
    
    //进入紧急模式
    CGPoint pt = CGPointZero;
    if(str && [str length]>0 && [str length]<4)//此处增加了none判定
    {
        pt = CGPointMake(SCREEN_WIDTH, 0);
        [timing refreshTimingLblWithString:str];
    }
    topEndPoint = pt;
    
    if(!CGPointEqualToPoint(pt, prePt))
    {
        [self scrollTopViewWithDelayAndCancel];
    }
}
-(void)scrollTopViewWithDelayAndCancel
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollTopControllerView) object:nil];
//    [self performSelector:@selector(scrollTopControllerView) withObject:nil afterDelay:0.1];
    [self scrollTopControllerView];
}
-(void)scrollTopControllerView
{
    [viewScroll setContentOffset:topEndPoint];
    
//    [viewScroll setContentOffset:topEndPoint animated:YES];
//    [UIView animateWithDuration:0.4 animations:^{
//        [viewScroll setContentOffset:topEndPoint];
//    }];
}

//-(UIButton *)coverBtn
//{
//    if(CGPointEqualToPoint(topEndPoint, CGPointZero)){
//        return quick.coverBtn;
//    }
//    return timing.coverBtn;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showSpecialStyleTitle];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.size.height -= ZA_TABBAR_HEIGHT;
    UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:rect];
    scroll.pagingEnabled = YES;
    viewScroll = scroll;
    scroll.delegate = self;
    [self.view addSubview:scroll];
    scroll.scrollEnabled = NO;
    scroll.contentSize = CGSizeMake(rect.size.width * 2,rect.size.height);
    [scroll addSubview:quick.view];
    
    UIView * timingView = timing.view;
    timingView.frame = CGRectMake(rect.size.width, 0, rect.size.width, rect.size.height);
    [scroll addSubview:timingView];
    
//    [self performSelector:@selector(scrollContainViewWithTimingString:) withObject:@"3" afterDelay:3];
    
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(model.main_Tips_Showed)
    {
        [self scrollContainViewWithTimingString:@"30"];
    }
    

    CGFloat redWidth = self.redCircle1.bounds.size.width;
    rect = quick.leftBtn.bounds;
    CGPoint pt = CGPointMake(rect.size.width - redWidth * 1.2 ,1.3 * redWidth);
    [quick.leftBtn addSubview:self.redCircle1];
    self.redCircle1.center = pt;
    
    [timing.leftBtn addSubview:self.redCircle2];
    self.redCircle2.center = pt;
    
    BOOL show = model.contactRed_Need_Show;
    self.redCircle1.hidden = !show;
    self.redCircle2.hidden = !show;
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
