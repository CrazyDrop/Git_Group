//
//  ZATimingController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZATimingController.h"
#import "ZATimerStartedController.h"
#import "TBCircularSlider.h"
#import "ZACircularSlider.h"
#import "Samurai_UILabel.h"
#import "ZAHomeTabBarController.h"
#import "ZAPasswordController.h"
#import "MainTestActivity.h"
#import "ZAContactListController.h"
#import "ZAStartUserController.h"
#import "ZATopNumView.h"
#import "ZATipsCoverView.h"
#import "KKNavigationController.h"
#import "LocalTimingRefreshManager.h"
#import "PWDTimeManager.h"
#import "ZAWarnCancelTopVC.h"
#import "ZALoginController.h"
@interface ZATimingController ()
{
    //普通状态可见
    UILabel * normalCountLbl;
    UILabel * normalMinLbl;
    UILabel * normalHourLbl;
    UILabel * showLbl;
    UIButton * startBtn;
    UIView * touchBtn;
    TBCircularSlider * showCircle;
    
    //设置状态可见
    ZACircularSlider * slider;
    UILabel * settingCountLbl;
    UILabel * settingBlackMinLbl;
    UILabel * settingHourLbl;
    UIButton * cancelBtn;
    
    NSInteger editNum;
    BaseRequestModel * _bgRequestModel;
    BaseRequestModel * _bgCheckModel;
    BOOL startCheck;
}
@end

@implementation ZATimingController
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshDragBackEnable:NO];
//    if(!startCheck) return;
//    startCheck = NO;
    //启动检查，尽在启动时进行检查
//    [self loginStateCheck];
//    [self startInfoCheck];
//    [self backgroundWebTimingStop];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showSpecialStyleTitle];
    startCheck = YES;
    
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame);
    CGRect rect = self.view.bounds;
    
    startY += 20;
    
    CGFloat circleRadius = TBCIRCLESLIDER_COMMON_RADIUS;
    if(SCREEN_HEIGHT == 480)         circleRadius *= 0.8;
    
    //使用相对的计算坐标
    TBCircularSlider * circle = [[TBCircularSlider alloc] initWithFrame:CGRectMake(0, 0, circleRadius * 2 + 2, circleRadius * 2 + 2)];
    [self.view addSubview:circle];
//    circle.backgroundColor = [UIColor redColor];
    circle.lineWidth = FLoatChange(22);
//    CGFloat extendY = FLoatChange(5);
    circle.center = CGPointMake( SCREEN_WIDTH / 2.0, startY + circle.bounds.size.height / 2.0 );
    circle.clipsToBounds = YES;
    showCircle = circle;
    circle.userInteractionEnabled = NO;
    
    UIView * btn = [[UIView alloc] initWithFrame:circle.bounds];
//    [btn addTarget:self action:@selector(tapedOnEditBtn:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn];
    btn.center = circle.center;
    btn.backgroundColor = [UIColor clearColor];
    CALayer * layer = btn.layer;
    [layer setCornerRadius:btn.bounds.size.height/2.0];
    touchBtn = btn;
    
    UILongPressGestureRecognizer * press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnEditBtn:)];
    [btn addGestureRecognizer:press];
    
    NSString * fontName = @"AppleSDGothicNeo-UltraLight";
    fontName = @"AvenirNextCondensed-UltraLight";
    fontName = @"HelveticaNeue-Thin";
    
    NSString * str = @"00:00";
    UILabel * timeLbl = [[UILabel alloc] initWithFrame:circle.bounds];
    [circle addSubview:timeLbl];
    timeLbl.font = [UIFont fontWithName:fontName size:FLoatChange(60)];
    timeLbl.text = str;
    timeLbl.hidden = YES;
    timeLbl.textAlignment = NSTextAlignmentCenter;
    timeLbl.center = CGPointMake( CGRectGetMidX(circle.bounds), CGRectGetMidY(circle.bounds));
    normalHourLbl = timeLbl;
//    timeLbl.textColor = TB_SLIDER_HEIGHT1_LINE_COLOR;

    str = @"分钟";
    timeLbl = [[UILabel alloc] initWithFrame:circle.bounds];
    [circle addSubview:timeLbl];
    timeLbl.font = [UIFont fontWithName:fontName size:FLoatChange(26)];
    timeLbl.text = str;
    timeLbl.textAlignment = NSTextAlignmentCenter;
    [timeLbl sizeToFit];
//    timeLbl.backgroundColor = [UIColor redColor];
    normalMinLbl = timeLbl;
    rect = timeLbl.frame ;
    rect.size.width = SCREEN_WIDTH / 2.0;
    timeLbl.frame = rect;
    CGFloat minHeight = timeLbl.bounds.size.height;
    timeLbl.textColor = TB_SLIDER_HEIGHT1_LINE_COLOR;

    
    str = @"60";
    timeLbl = [[UILabel alloc] initWithFrame:self.view.bounds];
    [circle addSubview:timeLbl];
    timeLbl.font = [UIFont fontWithName:fontName size:FLoatChange(115)];
    if(SCREEN_HEIGHT == 480) timeLbl.font = [UIFont fontWithName:fontName size:90];
    timeLbl.text = str;
    timeLbl.textAlignment = NSTextAlignmentCenter;
    timeLbl.backgroundColor = [UIColor clearColor];
    [timeLbl sizeToFit];
    normalCountLbl = timeLbl;
    rect = timeLbl.frame ;
    rect.size.width = SCREEN_WIDTH ;
    timeLbl.frame = rect;
    timeLbl.textColor = [DZUtils colorWithHex:@"007a3c"];
    
    CGFloat spaceY = (circle.bounds.size.height - normalCountLbl.bounds.size.height - minHeight ) / 2.0;
    CGFloat midX = normalHourLbl.center.x;
    normalCountLbl.center = CGPointMake(midX,spaceY + normalCountLbl.bounds.size.height / 2.0 );
    normalMinLbl.center = CGPointMake(midX,circle.bounds.size.height * 0.72);
    

    UILabel * noticeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,startY, SCREEN_WIDTH, 30)];
    [self.view addSubview:noticeLbl];
    noticeLbl.text = @"长按圆圈设置时间";
    noticeLbl.font = [UIFont systemFontOfSize:FLoatChange(14)];
    [noticeLbl sizeToFit];
    noticeLbl.textColor = [UIColor grayColor];
    noticeLbl.textAlignment = NSTextAlignmentCenter;
    showLbl = noticeLbl;
    
    
    CGFloat bottomSep = FLoatChange(35);
    if(SCREEN_HEIGHT == 480) bottomSep = 15;
    CGFloat btnWidth = circleRadius * 2 * 0.8;
    CGSize btnSize = CGSizeMake(btnWidth, FLoatChange(52));
    UIButton * tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tapBtn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    [tapBtn setTitle:@"开始防护" forState:UIControlStateNormal];
    [tapBtn addTarget:self action:@selector(tapedOnStartButton:) forControlEvents:UIControlEventTouchUpInside];
//    startBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:tapBtn];
    startBtn = tapBtn;
    layer = tapBtn.layer;
    [layer setCornerRadius:btnSize.height/2.0];
    layer.borderWidth = 0.5;
    layer.borderColor = [[DZUtils colorWithHex:@"27ad53"] CGColor];
    
    
    [tapBtn setTitleColor:[DZUtils colorWithHex:@"27ad53"] forState:UIControlStateNormal];
    tapBtn.center = CGPointMake(SCREEN_WIDTH / 2.0 , SCREEN_HEIGHT - ZA_TABBAR_HEIGHT - btnSize.height /2.0 - bottomSep);
    
    CGFloat lblMidY = ( circle.center.y + circle.bounds.size.height / 2.0  + tapBtn.center.y - tapBtn.bounds.size.height / 2.0 ) / 2.0;
    noticeLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, lblMidY);
    
    
    //编辑页面的控件
    tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tapBtn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    [tapBtn setTitle:@"取消设置" forState:UIControlStateNormal];
    [tapBtn addTarget:self action:@selector(tapedOnEditCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    //    startBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:tapBtn];
    cancelBtn = tapBtn;
    layer = tapBtn.layer;
    [layer setCornerRadius:btnSize.height/2.0];
    layer.borderWidth = 0.5;
    layer.borderColor = [[DZUtils colorWithHex:@"27ad53"] CGColor];
    [tapBtn setTitleColor:[DZUtils colorWithHex:@"27ad53"] forState:UIControlStateNormal];
    tapBtn.center = startBtn.center;
    
    
    UIFont * txtFont = [UIFont fontWithName:fontName size:FLoatChange(60)];
    timeLbl = [[UILabel alloc] initWithFrame:rect];
    timeLbl.text = str;
    timeLbl.textAlignment = NSTextAlignmentCenter;
    timeLbl.font = txtFont;
    [self.view addSubview:timeLbl];
    [timeLbl sizeToFit];
    rect = timeLbl.frame ;
    rect.size.width = SCREEN_WIDTH / 2.0;
    timeLbl.frame = rect;
    timeLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, timeLbl.bounds.size.height / 2.0 + 30);
    settingCountLbl = timeLbl;
//    timeLbl.backgroundColor = [UIColor redColor];
    
    str= @"1:10";
    txtFont = [UIFont fontWithName:fontName size:FLoatChange(60)];
    timeLbl = [[UILabel alloc] initWithFrame:rect];
    timeLbl.text = str;
    timeLbl.textAlignment = NSTextAlignmentCenter;
    timeLbl.font = txtFont;
    [self.view addSubview:timeLbl];
    [timeLbl sizeToFit];
    rect = timeLbl.frame ;
    rect.size.width = SCREEN_WIDTH / 2.0;
    timeLbl.frame = rect;
    timeLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, settingCountLbl.center.y);
    settingHourLbl = timeLbl;
    timeLbl.hidden = YES;
    
    
    str = @"分钟";
    rect = circle.bounds;
    txtFont = [UIFont systemFontOfSize:FLoatChange(20)];
    timeLbl = [[UILabel alloc] initWithFrame:rect];
    timeLbl.text = str;
    timeLbl.textAlignment = NSTextAlignmentCenter;
    timeLbl.font = txtFont;
    [self.view addSubview:timeLbl];
    [timeLbl sizeToFit];
    rect = timeLbl.frame ;
    rect.size.width = SCREEN_WIDTH / 2.0;
    timeLbl.frame = rect;
    timeLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, CGRectGetMaxY(settingCountLbl.frame) + timeLbl.bounds.size.height / 2.0 - 3);
//    timeLbl.backgroundColor = [UIColor redColor];
    timeLbl.textColor = [UIColor grayColor];
    settingBlackMinLbl = timeLbl;
    
    
    rect = showCircle.bounds;
    rect.size.width = SCREEN_WIDTH;
    rect.size.height = SCREEN_WIDTH;
    ZACircularSlider * circleSlider = [[ZACircularSlider alloc] initWithFrame:rect];
    circleSlider.lineWidth = FLoatChange(26);
    circleSlider.effectiveRadius = showCircle.bounds.size.width/2.0 - 1 - FLoatChange(26) / 2.0;
    [self.view addSubview:circleSlider];
    
//    circleSlider.backgroundColor = [UIColor redColor];
    CGFloat centerY = ( SCREEN_HEIGHT - 10 - ZA_TABBAR_HEIGHT ) / 2.0 + 10;
    if(SCREEN_HEIGHT == 480) centerY += 10;
    circleSlider.center = CGPointMake(SCREEN_WIDTH / 2.0, centerY);
    slider = circleSlider;
    [circleSlider addTarget:self action:@selector(circleSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [circleSlider addTarget:self action:@selector(circleSliderDoneEdit:) forControlEvents:UIControlEventEditingDidEnd];
    [self.view sendSubviewToBack:circleSlider];
    

//    UIButton * tapTestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    tapTestBtn.frame = CGRectMake(SCREEN_WIDTH - 100, 0, 100, 100);
//    [tapTestBtn setBackgroundColor:[UIColor redColor]];
//    [self.view addSubview:tapTestBtn];
//    [tapTestBtn addTarget:self action:@selector(tapedOnTestBtn:) forControlEvents:UIControlEventTouchUpInside];
    
//    tapTestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    tapTestBtn.frame = CGRectMake(SCREEN_WIDTH - 100, 0, 100, 100);
//    [tapTestBtn setBackgroundColor:[UIColor redColor]];
//    [self.view addSubview:tapTestBtn];
//    [tapTestBtn addTarget:self action:@selector(tapedOnSecondTestBtn:) forControlEvents:UIControlEventTouchUpInside];

    [self refreshSubViewsStateWithStartedState:YES animated:NO];
    [self checkAndShowMainCoverView];
    [self refreshLocalTimePreSetting];

    
}
-(void)refreshLocalTimePreSetting
{
    NSInteger localNum = 10;
    NSString * timeNum = [DZUtils localSaveObjectFromLocalSaveKeyStr:USERDEFAULT_TIMINGSETTING_LOCAL];
    if(!timeNum)
    {
        timeNum = [NSString stringWithFormat:@"%ld",localNum];
        [DZUtils localSaveObject:timeNum withKeyStr:USERDEFAULT_TIMINGSETTING_LOCAL];
        
    }
    
    
    settingCountLbl.text = timeNum;
    [self refreshSubViewsStateWithStartedState:YES animated:YES];
    
    NSInteger number = [settingCountLbl.text intValue];
    [self refreshNormalCountLblWithMinNumber:number];
    
}
-(void)checkAndShowMainCoverView
{
    if(!IOS7_OR_LATER) return;
    ZALocalStateTotalModel * local  = [ZALocalStateTotalModel currentLocalStateModel];
    if(!local.main_Tips_Showed)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        ZATipsCoverView * cover = [[ZATipsCoverView alloc] initWithFrame:rect];
        cover.tipsIdentifier = USERDEFAULT_CoverView_Tips_Main_Show;
        [self.tabBarController.view addSubview:cover];
        
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, 200)];
        lbl.numberOfLines = 0;

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;// 字体的行间距
        NSString * strTxt = @"定时防护用于提前预警防护\n  紧急防护则用于危机状态";
        NSString * fontName = @"Hannotate SC Bold";
        fontName = @"Marion-Bold";
        NSDictionary *ats = @{
                              
                              NSFontAttributeName : [UIFont fontWithName:fontName size:FLoatChange(15)],
                              NSParagraphStyleAttributeName : paragraphStyle,
                              };
        NSAttributedString * attTxt = [[NSAttributedString alloc] initWithString:strTxt attributes:ats];
        lbl.attributedText = attTxt;
        lbl.textColor = [UIColor whiteColor];
//        lbl.text = @"紧急防护则用于危机状态";
        [cover addSubview:lbl];
        [lbl sizeToFit];
        
        lbl.center = CGPointMake(SCREEN_WIDTH/2.0,SCREEN_HEIGHT - ZA_TABBAR_HEIGHT - lbl.bounds.size.height/2.0 - 20);
        
        CGFloat centerY = SCREEN_HEIGHT - ZA_TABBAR_HEIGHT/2.0;
        CGFloat circleWidth = ZA_TABBAR_HEIGHT;
        rect.size = CGSizeMake(circleWidth, circleWidth);
        UIView * bgView = [[UIView alloc] initWithFrame:rect];
        [cover addSubview:bgView];
        CALayer * layer = bgView.layer;
        [layer setCornerRadius:rect.size.height/2.0];
        bgView.center = CGPointMake(SCREEN_WIDTH/4.0,centerY);
        bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time_selected"]];
        [bgView addSubview:img];
        img.center = CGPointMake(circleWidth/2.0, circleWidth/3) ;
        lbl = [[UILabel alloc] initWithFrame:rect];
        lbl.backgroundColor = [UIColor clearColor];
        [bgView addSubview:lbl];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = @"定时防护";
        lbl.center = CGPointMake(circleWidth/2.0, circleWidth/4*3) ;
        lbl.textColor = [UIColor whiteColor];
        
        bgView = [[UIView alloc] initWithFrame:rect];
        [cover addSubview:bgView];
        layer = bgView.layer;
        [layer setCornerRadius:rect.size.height/2.0];
        bgView.center = CGPointMake(SCREEN_WIDTH/4.0*3,centerY);
        bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"quick_selected"]];
        [bgView addSubview:img];
        img.center = CGPointMake(circleWidth/2.0, circleWidth/3) ;
        lbl = [[UILabel alloc] initWithFrame:rect];
        lbl.backgroundColor = [UIColor clearColor];
        [bgView addSubview:lbl];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = @"紧急防护";
        lbl.center = CGPointMake(circleWidth/2.0, circleWidth/4*3) ;
        lbl.textColor = [UIColor whiteColor];
    }
}
-(void)startInfoCheck
{
    
    
    BOOL show = [[DZUtils localSaveObjectFromLocalSaveKeyStr:USERDEFAULT_StartInfo_Finished] boolValue];
    if(!show)
    {
        ZAStartUserController * pwd = [[ZAStartUserController alloc] init];
        UINavigationController * pwdNa = [[KKNavigationController alloc] initWithRootViewController:pwd];
        pwdNa.navigationBarHidden = YES;
        pwdNa.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.viewDeckController presentViewController:pwdNa animated:NO completion:nil];
        return;
    }
    
//    ZAContactListController * list = [[ZAContactListController alloc] init];
//    [[self rootNavigationController] pushViewController:list animated:YES];

    
    
}
-(void)loginStateCheck
{
    //本地状态检查，针对无登录的用户弹出登录界面处理
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(!model.isUserLogin)
    {
        //展示登录页面
        ZALoginController * pwd = [[ZALoginController alloc] init];
        UINavigationController * pwdNa = [[KKNavigationController alloc] initWithRootViewController:pwd];
        pwdNa.navigationBarHidden = YES;
        pwdNa.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.viewDeckController.centerController presentViewController:pwdNa animated:NO completion:nil];
        return ;
    }
    
    if(model.isNeedUpdate)
    {
        //展示登录页面
        ZAStartUserController * pwd = [[ZAStartUserController alloc] init];
        UINavigationController * pwdNa = [[KKNavigationController alloc] initWithRootViewController:pwd];
        pwdNa.navigationBarHidden = YES;
        pwdNa.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.viewDeckController presentViewController:pwdNa animated:NO completion:nil];
        return ;
    }
}



-(void)backgroundWebTimingStop
{
    //通知服务器未完成的关闭请求
    //此处为实现关闭请求失败的二次操作，希望能在此处添加 (紧急模式下、倒计时代码未获取成功，密码页面即关闭 保留)
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(!total.isUserLogin) return;
    
    WarnTimingModel * local = total.timeModel;

    //执行此处操作，表明界面一定不会展示密码页面
    //数据上传，通知解除
    WarningModel * model = (WarningModel *) _bgRequestModel;
    if(!model){
        model = [[WarningModel alloc] init];
        [model addSignalResponder:self];
        _bgRequestModel = model;
    }
    
    //可以考虑此处
    model.timingId = local.timeId;
    model.scene = local.scene;
    model.type = WarningModel_TYPE_STOP;
    [model sendRequest];
}
-(void)refreshSubViewsStateWithStartedState:(BOOL)started animated:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;
    void(^ChangeStateBlock)(void) = ^()
    {
        //初始状态展示
        weakSelf.titleBar.hidden = !started;
        showCircle.hidden = !started;
        showLbl.hidden = !started;
        startBtn.hidden = !started;
        touchBtn.hidden = !started;
        
        //编辑状态展示
        settingCountLbl.hidden = started;
        settingHourLbl.hidden = started;
        settingBlackMinLbl.hidden = started;
        slider.hidden = started;
        cancelBtn.hidden = started;
        
//        ZAHomeTabBarController * tab = (ZAHomeTabBarController * )weakSelf.tabBarController;
//        [tab setBottomTabBarEnable:started];
    };

    if(animated)
    {
        [UIView animateWithDuration:0.2 animations:^{
            ChangeStateBlock();
        }];
    }else
    {
        ChangeStateBlock();
    }

    
    
}

-(void)circleSliderValueChanged:(id)sender
{
    NSInteger num = slider.angle;
    if(num < 5) num = 5; //最小值是5

    [self refreshSettingCountLblWithMinNumber:num];
    
}
-(void)refreshSettingCountLblWithMinNumber:(NSInteger)number
{
    settingCountLbl.text = [NSString stringWithFormat:@"%ld",(long)number];
    
    BOOL needHidden = number>60;
    
    NSString * minTxt = [NSString stringWithFormat:@"%ld分钟",(long)number];
    if(!needHidden) minTxt = @"分钟";
    settingBlackMinLbl.text = minTxt;
    
    settingCountLbl.hidden = needHidden;
    settingHourLbl.hidden = !needHidden;
    
    NSInteger min = number % 60;
    NSInteger hour = number / 60;
    
    settingHourLbl.frame = CGRectMake(0,0 , SCREEN_WIDTH, 80);
    settingHourLbl.text = [NSString stringWithFormat:@"%ld:%02ld",(long)hour,(long)min];
    [settingHourLbl sizeToFit];
    settingHourLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, settingCountLbl.center.y);
    
}
-(void)refreshNormalCountLblWithMinNumber:(NSInteger)number
{
    //设置正常状态的数据
    normalCountLbl.text = [NSString stringWithFormat:@"%ld",(long)number];
    
    BOOL needHidden = number>60;
    
    normalMinLbl.hidden = needHidden;
    normalCountLbl.hidden = needHidden;
    normalHourLbl.hidden = !needHidden;
    
    NSInteger min = number % 60;
    NSInteger hour = number / 60;
    normalHourLbl.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)hour,(long)min];
}

//点击完成
-(void)circleSliderDoneEdit:(id)sender
{
    [DZUtils localSaveObject:settingCountLbl.text withKeyStr:USERDEFAULT_TIMINGSETTING_LOCAL];
    [KMStatis staticResetTimeEvent:StaticPaPaTimingResetTimeEventType_Confirm];
    [self refreshSubViewsStateWithStartedState:YES animated:YES];
    
    NSInteger number = [settingCountLbl.text intValue];
    [self refreshNormalCountLblWithMinNumber:number];
}
//取消回来的
-(void)tapedOnEditCancelBtn:(id)sender
{
    [KMStatis staticResetTimeEvent:StaticPaPaTimingResetTimeEventType_Cancel];
    NSInteger number = [normalCountLbl.text intValue];
    [self refreshSettingCountLblWithMinNumber:number];

    [self refreshSubViewsStateWithStartedState:YES animated:YES];

}

//开始编辑
-(void)tapedOnEditBtn:(UILongPressGestureRecognizer *)ges
{
//    UIGestureRecognizerStateBegan
    if(ges.state != UIGestureRecognizerStateBegan) return;
    
    [KMStatis staticResetTimeEvent:StaticPaPaTimingResetTimeEventType_Start];

    [self refreshSubViewsStateWithStartedState:NO animated:YES];
    NSInteger number = [normalCountLbl.text integerValue];
    slider.angle = (int)number;
    slider.maxAngle = 60 * 3;
    
    [self refreshSettingCountLblWithMinNumber:number];
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

//进入倒计时启动界面
-(void)tapedOnStartButton:(id)sender
{

    NSString * log = nil;
    ZALocation * locationInstance = [ZALocation sharedInstance];
    __weak ZATimingController * weakSelf = self;
    
    //点击登录按钮
    //未设置过，弹出提示页面，确认后弹出系统请求页面
    if([ZALocation locationStatusNeverSetting])
    {
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Timing_Fail];
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
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Timing_Fail];
        if(iOS8_constant_or_later)
        {
            log = @"我们怕怕需要您的位置信息,需要您许可前后台使用该功能,请在设置中设置始终允许";
            BlockAlertView * alert = [BlockAlertView alertWithTitle:@"提示" message:log];
            [alert setDestructiveButtonWithTitle:@"确定" block:^{
                [[ZALocation sharedInstance] openSystemLocationSettingPage:nil];
            }];
            [alert show];
            return;
        }
        //进行提示
        log = @"您尚未允许我们使用您的位置信息，请在 设置->隐私->定位服务->怕怕 中开启后使用";
        [DZUtils noticeCustomerWithShowText:log];
        return;
    }
    
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        log = kAppNone_Network_Error;
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Timing_Fail];
        [DZUtils noticeCustomerWithShowText:log];
        return;
    }
    
    [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Timing_Success];

    //前提判定
    NSInteger total = [normalCountLbl.text intValue];
    //如果时间展示发生变化，计算方式需要改变
    
    //数据上传
    WarnTimingModel * model = (WarnTimingModel *) _dpModel;
    if(!model){
        model = [[WarnTimingModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    model.duration = [NSString stringWithFormat:@"%ld",total*60];
    model.scene = @"1";
    [model sendRequest];
    
    //启动定时的定位服务
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager refreshRefreshTimeWithNormalPriority];
}
#pragma mark WarningModel
handleSignal( WarningModel, requestError )
{
    //当前服务器未处理，也认为已经告知服务器
//    [self hideLoading];
//    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( WarningModel, requestLoading )
{
//    [self showLoading];
}

handleSignal( WarningModel, requestLoaded )
{
//    [self hideLoading];
    //清空调用标识

}
#pragma mark -

#pragma mark WarnTimingModel
handleSignal( WarnTimingModel, requestError )
{
    [self hideLoading];
    
    
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
    
    //保存失败,当超时时存储
    [self localSaveTimingStartedState:NO];
    
}
handleSignal( WarnTimingModel, requestLoading )
{
    [self showLoading];
}

handleSignal( WarnTimingModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [self localSaveTimingStartedState:YES];
        [self refreshWithSuccess];
    }
}
#pragma mark -
-(void)localSaveTimingStartedState:(BOOL)success
{
    NSInteger total = [normalCountLbl.text intValue];
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
    NSInteger total = [normalCountLbl.text intValue];

    ZATimerStartedController * start = [[ZATimerStartedController alloc] init];
    start.totalTimingNum = total * 60 ;
    start.timingNum = total * 60 ;
    
    [DZUtils localTimeNotificationAppendedWithTimeLength:start.timingNum];
    
    [[self rootNavigationController] pushViewController:start animated:YES];
}
-(void)tapedOnSecondTestBtn:(id)sender
{
    ZAWarnCancelTopVC * cancel =[[ZAWarnCancelTopVC alloc] init];
    [[self rootNavigationController] pushViewController:cancel animated:YES];
    
    return;
    ZAContactListController * start = [[ZAContactListController alloc] init];
    [[self rootNavigationController] pushViewController:start animated:YES];
}

-(void)tapedOnTestBtn:(id)sender
{
    ZAWarnCancelTopVC * cancel =[[ZAWarnCancelTopVC alloc] init];
    [[self rootNavigationController] pushViewController:cancel animated:YES];
    
//    return;
//    
//    ZAStartUserController * user = [[ZAStartUserController alloc] init];
//    [[self rootNavigationController] pushViewController:user animated:YES];
//    
//    return;
//    MainTestActivity * test = [[MainTestActivity alloc] init];
//    [[self rootNavigationController] pushViewController:test animated:YES];
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
