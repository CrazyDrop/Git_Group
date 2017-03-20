//
//  ZAWebNoticeController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/26.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAWebNoticeController.h"
@interface ZAWebNoticeController ()
@property (nonatomic,strong) UIView * topErrorView;     //网络状态的提醒
@property (nonatomic,strong) UIView * topLocationView;  //定位功能的提醒
@property (nonatomic,assign) BOOL locationEnable;
@property (nonatomic,assign) BOOL webEnable;
@end

@implementation ZAWebNoticeController

-(void)loadView
{
    CGFloat viewHeight = FLoatChange(58);
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, viewHeight);
    UIView * aView = [[UIView alloc] initWithFrame:rect];
    aView.hidden = YES;
    self.view = aView;

}
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.webEnable = YES;
    self.locationEnable = YES;
    
    [self.view addSubview:self.topErrorView];
    self.topErrorView.hidden = YES;//默认隐藏
    
    [self.view addSubview:self.topLocationView];
    self.topLocationView.hidden = YES;//默认隐藏
//    [self startWebStateNotificationListen];
}
-(UIView *)topLocationView
{
    if(!_topLocationView)
    {
        CGFloat viewHeight = self.view.bounds.size.height;
        CGFloat btnWidth = FLoatChange(40);
        CGFloat startWidth = FLoatChange(10);
        CGRect rect = CGRectMake(0,0 , SCREEN_WIDTH, viewHeight);
        
        UIView * aView = [[UIView alloc] initWithFrame:rect];
        aView.backgroundColor = RGB(233, 121, 103);
//        aView.hidden = YES;
        
        UIButton * endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        endBtn.frame = CGRectMake(0, 0 , btnWidth, viewHeight);
        [endBtn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(12)]];
        [endBtn addTarget:self action:@selector(tapedOnSettingBtn:) forControlEvents:UIControlEventTouchUpInside];
        [aView addSubview:endBtn];
        [endBtn setTitle:@"" forState:UIControlStateNormal];
        endBtn.backgroundColor = [UIColor clearColor];
        //    [endBtn setBackgroundImage:[UIImage imageNamed:@"notice_stop"] forState:UIControlStateNormal];
        endBtn.center = CGPointMake(SCREEN_WIDTH - btnWidth/2.0 , viewHeight/2.0);
        endBtn.hidden = !iOS8_constant_or_later;
        
        UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_arrow"]];
        rect = img.bounds;
        CGFloat extend = rect.size.width/rect.size.height;
        CGFloat imgHeight = FLoatChange(15);
        rect.size = CGSizeMake(imgHeight * extend,imgHeight);
        img.frame = rect;
        img.center = CGPointMake(endBtn.bounds.size.width/2.0 , endBtn.bounds.size.height/2.0);
        [endBtn addSubview:img];
        CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI);
        img.transform = transform;
        
        
        CGFloat smallWidth = FLoatChange(20);
        endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        endBtn.frame = CGRectMake(0, 0 , smallWidth, smallWidth);
        [aView addSubview:endBtn];
        [endBtn setImage:[UIImage imageNamed:@"notice_icon"] forState:UIControlStateNormal];
        endBtn.backgroundColor = [UIColor clearColor];
        endBtn.center = CGPointMake(startWidth + smallWidth/2.0, viewHeight/2.0);
        
        
        
        CGFloat startX = startWidth * 2 + smallWidth;
        rect = aView.bounds;
        rect.origin.x = startX;
        rect.size.width = (SCREEN_WIDTH - startX - btnWidth);
        UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
        [aView addSubview:lbl];
        lbl.numberOfLines = 0;
        lbl.text = @"请允许我们使用您的位置,保障\n您的安全";
//        if(SCREEN_WIDTH>320)
//        {
//            lbl.text = @"请允许我们使用您的位置,保障您的安全";
//        }
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont systemFontOfSize:FLoatChange(16)];
//        
//        endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        endBtn.frame = CGRectMake(0, 0 , btnWidth, viewHeight);
//        [endBtn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(14)]];
//        [endBtn addTarget:self action:@selector(tapedOnSettingBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [aView addSubview:endBtn];
//        [endBtn setTitle:@"去设置" forState:UIControlStateNormal];
//        endBtn.backgroundColor = [UIColor clearColor];
//        //    [endBtn setBackgroundImage:[UIImage imageNamed:@"notice_stop"] forState:UIControlStateNormal];
//        endBtn.center = CGPointMake(SCREEN_WIDTH - btnWidth/2.0 - FLoatChange(10), viewHeight/2.0);
//        endBtn.hidden = !iOS8_constant_or_later;
        
        self.topLocationView = aView;
    }
    return _topLocationView;
}


-(UIView *)topErrorView
{
    if(!_topErrorView)
    {
        CGFloat viewHeight = self.view.bounds.size.height;
        CGFloat btnWidth = FLoatChange(20);
        CGFloat startWidth = FLoatChange(10);
        CGRect rect = CGRectMake(0,0 , SCREEN_WIDTH, viewHeight);
        
        UIView * aView = [[UIView alloc] initWithFrame:rect];
        aView.backgroundColor = RGB(233, 121, 103);
//        aView.hidden = YES;
        
//        UIButton * endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        endBtn.frame = CGRectMake(0, 0 , btnWidth, btnWidth);
//        [endBtn addTarget:self action:@selector(hideTopErrorView) forControlEvents:UIControlEventTouchUpInside];
//        [aView addSubview:endBtn];
//        [endBtn setImage:[UIImage imageNamed:@"notice_stop"] forState:UIControlStateNormal];
//        endBtn.backgroundColor = [UIColor clearColor];
//        //    [endBtn setBackgroundImage:[UIImage imageNamed:@"notice_stop"] forState:UIControlStateNormal];
//        endBtn.center = CGPointMake(SCREEN_WIDTH - btnWidth/2.0, viewHeight/2.0);
//
        UIButton * endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        endBtn.frame = CGRectMake(0, 0 , btnWidth, btnWidth);
//        [endBtn addTarget:self action:@selector(hideTopErrorView) forControlEvents:UIControlEventTouchUpInside];
        [aView addSubview:endBtn];
        [endBtn setImage:[UIImage imageNamed:@"notice_icon"] forState:UIControlStateNormal];
        endBtn.backgroundColor = [UIColor clearColor];
        endBtn.center = CGPointMake(startWidth + btnWidth/2.0, viewHeight/2.0);
        
//        forget
        
        CGFloat startX = startWidth * 2 + btnWidth;
        rect = aView.bounds;
        rect.origin.x = startX;
        rect.size.width = (SCREEN_WIDTH - startX);
        UILabel * lbl = [[UILabel alloc] initWithFrame:rect];
        [aView addSubview:lbl];
        lbl.numberOfLines = 0;
        lbl.text = @"当前无网络，无法使用服务";
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont systemFontOfSize:FLoatChange(16)];
        
        self.topErrorView = aView;
    }
    return _topErrorView;
}
-(void)tapedOnSettingBtn:(id)sender
{
    //打开
    //没启动定位功能，用户拒绝后再次点击
    NSString * log = nil;
    if(![ZALocation locationStatusEnableInBackground])
    {
        
        if(iOS8_constant_or_later)
        {
            [[ZALocation sharedInstance] openSystemLocationSettingPage:nil];
//            log = @"我们怕怕需要您的位置信息,需要您许可该功能,请在设置中打开";
//            BlockAlertView * alert = [BlockAlertView alertWithTitle:@"提示" message:log];
//            [alert setDestructiveButtonWithTitle:@"确定" block:^{
//                [[ZALocation sharedInstance] openSystemLocationSettingPage:nil];
//            }];
//            [alert show];
//            return;
        }else{
            //进行提示
            log = @"您尚未允许我们使用您的位置信息，请在 设置->隐私->定位服务->怕怕 中开启后使用";
            [DZUtils noticeCustomerWithShowText:log];
        }
        return;
    }

}


-(void)hideTopErrorView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WEBCHECK_NOTICE_SHOW_STATE
                                                        object:[NSNumber numberWithBool:YES]];
}

#pragma mark - Public Methods
-(void)startWebStateNotificationListen
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webStateChanged:)
                                                 name:NOTIFICATION_WEBCHECK_NOTICE_SHOW_STATE
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationStateChanged:)
                                                 name:NOTIFICATION_LOCATION_NOTICE_SHOW_STATE
                                               object:nil];

    //延迟，刷新界面，针对刚展示的界面展示无网络提示
//    [self performSelector:@selector(showWebStateNoticeViewForController) withObject:nil afterDelay:1];
}


-(void)webStateChanged:(NSNotification *)noti
{
    NSNumber * num = noti.object;
    self.webEnable = [num boolValue];
    [self refreshTotalViewsWithCurrentState];
}
-(void)locationStateChanged:(NSNotification *)noti
{
    NSNumber * num = noti.object;
    self.locationEnable = [num boolValue];
    [self refreshTotalViewsWithCurrentState];
}
//刷新状态
-(void)refreshTotalViewsWithCurrentState
{
    self.topErrorView.hidden = self.webEnable;
    self.topLocationView.hidden = self.locationEnable;
    
    //两者都为yes，则全部隐藏
    self.view.hidden = self.webEnable && self.locationEnable;
}


#pragma mark ----

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
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
