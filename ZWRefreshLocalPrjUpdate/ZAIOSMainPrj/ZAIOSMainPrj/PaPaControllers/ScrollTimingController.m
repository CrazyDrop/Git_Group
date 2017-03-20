//
//  ScrollTimingController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ScrollTimingController.h"
#import "ZATimerStartedController.h"
#import "UIImageView+WebCache.h"
#import "CircleStateView.h"
#import "ZAShareLocationController.h"
#import "ZATimerStartedController.h"
#import "ZASoundLineAnimationView.h"

#import "ZWTopRefreshListController.h"
@interface ScrollTimingController ()
{
    UILabel * topLbl;
    
    BaseRequestModel * uploadModel;
    UIButton * iconBtn;
}
@property (nonatomic,strong) UIAlertView * diaAlert;
@property (nonatomic,strong) UIAlertView * contactAlert;
@property (nonatomic,strong) UIAlertView * watchAlert;
@end

@implementation ScrollTimingController

//刷新倒计时时间长度
-(void)refreshTimingLblWithString:(NSString *)str
{
    //刷新文本
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGPoint pt = topLbl.center;
    topLbl.frame = rect;
    topLbl.text = str;
    [topLbl sizeToFit];
    topLbl.center = pt;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CGRect rect = [[UIScreen mainScreen] bounds];
    
    UIView * bgView = self.view;
    
    CGFloat btnHeight = FLoatChange(95);
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    rect.size.height = btnHeight;
//    rect.size.width *= 0.8;
    btn.frame = rect;
    [btn setTitle:@"开始防护" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(25)];
    [btn setBackgroundImage:[UIImage imageNamed:@"start_btn_bg"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"start_btn_bg_selected"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(tapedOnStartButton:) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - ZA_TABBAR_HEIGHT - btn.bounds.size.height/2.0);
    [bgView addSubview:btn];
    
//    CAShapeLayer *borderLayer = [CAShapeLayer layer];
//    borderLayer.bounds = CGRectMake(0, 0, rect.size.width  , rect.size.height);
//    borderLayer.position = CGPointMake(CGRectGetMidX(btn.bounds), CGRectGetMidY(btn.bounds));
//    borderLayer.path = [UIBezierPath bezierPathWithRect:borderLayer.bounds].CGPath;
////    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:CGRectGetWidth(borderLayer.bounds)/2].CGPath;
//    borderLayer.lineDashPattern = @[@8, @8];
//    borderLayer.fillColor = [UIColor clearColor].CGColor;
//    borderLayer.strokeColor = [UIColor redColor].CGColor;
//    borderLayer.lineWidth = 2. / [[UIScreen mainScreen] scale];
//    [btn.layer addSublayer:borderLayer];
//    [btn setBackgroundColor:[UIColor clearColor]];
    
    
    CGFloat centerY = (CGRectGetMaxY(self.titleBar.frame) + CGRectGetMinY(btn.frame))/2.0;
    centerY -= 10;
    CGFloat extend = FLoatChange(10);
    
    rect = [[UIScreen mainScreen] bounds];
    UILabel * numLbl = [[UILabel alloc] initWithFrame:rect];
    numLbl.textAlignment = NSTextAlignmentCenter;
    numLbl.font = [UIFont systemFontOfSize:FLoatChange(80)];
    numLbl.textColor = [UIColor whiteColor];
    numLbl.text = @"30";
    [numLbl sizeToFit];
    [bgView addSubview:numLbl];
    numLbl.center = CGPointMake(SCREEN_WIDTH/2.0, centerY - extend - numLbl.bounds.size.height/2.0);
    topLbl = numLbl;
    
    
    UILabel * minLbl = [[UILabel alloc] initWithFrame:rect];
    minLbl.textAlignment = NSTextAlignmentCenter;
    minLbl.font = [UIFont systemFontOfSize:FLoatChange(30)];
    minLbl.textColor = [UIColor whiteColor];
    minLbl.text = @"MIN";
    [minLbl sizeToFit];
    [bgView addSubview:minLbl];
    minLbl.center = CGPointMake(SCREEN_WIDTH/2.0, centerY + extend + minLbl.bounds.size.height/2.0);
    
    
//    ZASoundLineAnimationView * soundView = [[ZASoundLineAnimationView alloc] initWithFrame:CGRectMake(0, 0, FLoatChange(150), FLoatChange(45))];
//    [bgView addSubview:soundView];
//    soundView.center = CGPointMake(SCREEN_WIDTH/2.0, FLoatChange(320));
//    [soundView refreshSoundViewSize];
//    [soundView startAnimation];
    
//
//    UIButton * tapTestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    tapTestBtn.frame = CGRectMake(SCREEN_WIDTH - 200, 0, 200, 200);
//    [self.view addSubview:tapTestBtn];
//    [tapTestBtn setBackgroundColor:[UIColor redColor]];
//    iconBtn = tapTestBtn;
//
//    
//    NSString * urlStr = @"http://42.96.139.57/data/website/media/junchi/pic/company/157/product/2206/J0{]2]62IVP7)H4ZOICYU_S_5rb5o34.png";
//    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL * url = [NSURL URLWithString:urlStr];
//
//    [tapTestBtn sd_setImageWithURL:url];
//
//    
//    
//    NSTimeInterval showTimeInterval = 0.1;
//    
//    //    针对每个点，单独动画
//    CABasicAnimation *animation1 = [[self class] opacityForever_Animation_ForHidden:showTimeInterval];
//    [tapTestBtn.layer addAnimation:animation1 forKey:nil];
//
    
//    CGFloat circleWidth = 100;
//    CGFloat aWidth = circleWidth * (305.0/516.0);
//    CircleStateView * circle = [[CircleStateView alloc] initWithFrame:CGRectMake(0, 0,aWidth ,aWidth )];
//    [bgView addSubview:circle];
//    circle.center = CGPointMake(100, 100);
//    [circle setState:CircleStateViewStateType_UPLOAD_ING];
//    [circle refreshForLoadingAnimation];
}

+(CAAnimation *)opacityForever_Animation_ForHidden:(float)time //永久闪烁的动画
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue=[NSNumber numberWithFloat:1.0];
    animation.toValue=[NSNumber numberWithFloat:0.0];
    animation.duration=time;
    animation.repeatCount=0;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    
    CABasicAnimation *animation2=[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation2.fromValue=[NSNumber numberWithFloat:0.0];
    animation2.toValue=[NSNumber numberWithFloat:1.0];
    animation2.duration=time;
    animation2.repeatCount=0;
    animation2.removedOnCompletion=NO;
    animation2.beginTime = 1;
    animation2.fillMode=kCAFillModeForwards;
    
    
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.repeatCount = MAXFLOAT;
    group.removedOnCompletion=NO;
    group.duration = 2;
    group.animations = @[animation,animation2];
    return group;
    return animation;
}

-(void)showDialogForNoLocationError
{
    if(!self.diaAlert)
    {
        NSString * log = @"当前无网络，请检查您的网络，您的救助请求已发送，我们仍会和您及您的朋友联系。";
        log = @"我们怕怕需要您的位置信息,需要您许可前后台使用该功能,请在设置中设置始终允许";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:log
                                                        delegate:self
                                               cancelButtonTitle:@"确认"
                                               otherButtonTitles:nil, nil];
        self.diaAlert = alert;
    }
    [self.diaAlert show];
}

-(void)showDialogForNoContactsError
{
    if(!self.contactAlert)
    {
        NSString * log = @"您没有有效的紧急联系人号码，设置后就能正常使用啦~";
//        log = @"我们怕怕需要您的位置信息,需要您许可前后台使用该功能,请在设置中设置始终允许";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:log
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"去设置", nil];
        self.contactAlert = alert;
    }
    [self.contactAlert show];
    //    您还没有设置紧急联系人，无法开启防护哦~
}
-(void)showDialogForNoWatchStartedError
{
    if(!self.watchAlert)
    {
        NSString * log = @"已在Apple watch上启动防护，请勿重复开启防护。";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:log
                                                        delegate:nil
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil];
        self.watchAlert = alert;
    }
    [self.watchAlert show];
    //    您还没有设置紧急联系人，无法开启防护哦~
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == self.diaAlert)
    {
        //进行首次的定位功能启动提示
        [[ZALocation sharedInstance] openSystemLocationSettingPage:nil];
        
        return;
    }
    
    if(alertView == self.contactAlert)
    {
        //展示添加紧急联系人页面
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SETTING_ADD_CONTACT_STATE object:nil];
    }

}


#pragma mark WarnTimingModel
handleSignal( WarnTimingModel, requestError )
{
    [self hideLoading];
    
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:^(BOOL netEnable) {
        NSString * log = kAppNone_Service_Error;
        if(!netEnable)
        {
            log = kAppNone_Network_Error;
        }
        [DZUtils noticeCustomerWithShowText:log];
    }];
    
    //保存失败,当超时时存储
//    [self localSaveTimingStartedState:NO];
    
}
handleSignal( WarnTimingModel, requestLoading )
{
    [self showLoading];
}

handleSignal( WarnTimingModel, requestLoaded )
{
    [self hideLoading];
    
    
    ZAHTTPResponse *resp = signal.object;
    if(resp&&[resp.returnCode intValue] == HTTPReturnNoneContacts)
    {
        [self showDialogForNoContactsError];
        return;
    }
    
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [self localSaveTimingStartedState:YES];
        [self refreshWithSuccess];
    }
}
#pragma mark -
-(void)localSaveTimingStartedState:(BOOL)success
{
    NSInteger total = [topLbl.text intValue];
    WarnTimingModel * model = (WarnTimingModel *)_dpModel;
    
    
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    //本地保存，实现与服务器通信超时时的处理
    //如果时间展示发生变化，计算方式需要改变
    local.timeModel = model;
    local.warningId = [model.timeId copy];
    local.totalTime = total;
    local.showPWD = NO;
    local.endDate = [NSDate dateWithTimeIntervalSinceNow:total * 60];
    
    [local localSave];
}

-(void)refreshWithSuccess
{
    NSInteger total = [topLbl.text intValue];
    
    ZATimerStartedController * start = [[ZATimerStartedController alloc] init];
    start.totalTimingNum = total * 60 ;
    start.timingNum = total * 60 ;
    
    [DZUtils localTimeNotificationAppendedWithTimeLength:start.timingNum];
    
    [[self rootNavigationController] pushViewController:start animated:YES];
    
//    [self startPrepareForUploadRecorderAudio];

}
-(void)checkUpCurrentLocationWithString:(CLLocation *)str
{
    //如果有定位的数据返回，则用户同意，启动定位功能
    if(!str) return;
    
    //启动定时
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    //    [manager refreshRefreshTimeWithNormalPriority];
    [manager endAutoRefreshAndClearTime];
}

-(void)showListViewForCurrentNext
{
    int total = [topLbl.text intValue];
    //如果时间展示发生变化，计算方式需要改变
    
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    BOOL alarm = YES;
    if(total>50)
    {
        alarm = NO;
    }
    model.isAlarm = alarm;
    [model localSave];
    

    
    ZWTopRefreshListController * start = [[ZWTopRefreshListController alloc] init];
    [[self rootNavigationController] pushViewController:start animated:YES];

}


//进入倒计时启动界面
-(void)tapedOnStartButton:(id)sender
{
    [self showListViewForCurrentNext];
    return;
//    [self startUploadRecorderAutoWithPath:nil];
//    [self showLoading];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self hideLoading];
//    });
//    return;
    
    NSString * log = nil;
    ZALocation * locationInstance = [ZALocation sharedInstance];
    __weak typeof(self) weakSelf = self;
    
    NSString * timeLength = topLbl.text;
    
    //点击登录按钮
    //未设置过，弹出提示页面，确认后弹出系统请求页面
    if([ZALocation locationStatusNeverSetting])
    {
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Timing_Fail andTimeLength:timeLength];
        //也可以考虑替换 BlockAlertView
        //        log = @"我们怕怕需要您的位置信息,以判定您可能的危险";
        //        BlockAlertView * alert = [BlockAlertView alertWithTitle:@"提示" message:log];
        //        [alert setDestructiveButtonWithTitle:@"确定" block:^{
        //        }];
        //        [alert show];
        
        [locationInstance startLocationRequestUserAuthorization];
        [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *str)
         {
             [weakSelf checkUpCurrentLocationWithString:str];
         }];
        return;
    }
    
    //没启动定位功能，用户拒绝后再次点击
    if(![ZALocation locationStatusEnableInBackground])
    {
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Timing_Fail andTimeLength:timeLength];
        if(iOS8_constant_or_later)
        {
//            BlockAlertView * alert = [BlockAlertView alertWithTitle:@"提示" message:log];
//            [alert setDestructiveButtonWithTitle:@"确定" block:^{
//                [[ZALocation sharedInstance] openSystemLocationSettingPage:nil];
//            }];
//            [alert show];
            [self showDialogForNoLocationError];
            return;
        }
        //进行提示
        log = @"您尚未允许我们使用您的位置信息，请在 设置->隐私->定位服务->怕怕 中开启后使用";
        [DZUtils noticeCustomerWithShowText:log];
        return;
    }
    
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    if(local.isNeedStartedAddContact)
    {
        [self showDialogForNoContactsError];
        return;
    }
    
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        log = kAppNone_Network_Error;
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Timing_Fail andTimeLength:timeLength];
        [DZUtils noticeCustomerWithShowText:log];
        return;
    }
    if(![DZUtils localWarningStateCheckIsNone])
    {
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Timing_Fail andTimeLength:timeLength];
        [self showDialogForNoWatchStartedError];
        [weakSelf hideLoading];
        return;
    }
    
    [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Timing_Success andTimeLength:timeLength];
    
    //前提判定
    int total = [topLbl.text intValue];
    //如果时间展示发生变化，计算方式需要改变
    
    //数据上传
    WarnTimingModel * model = (WarnTimingModel *) _dpModel;
    if(!model){
        model = [[WarnTimingModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    model.duration = [NSString stringWithFormat:@"%d",total*60];
    model.scene = @"1";
    [model sendRequest];
    
    //启动定时的定位服务
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager refreshRefreshTimeWithNormalPriority];
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
