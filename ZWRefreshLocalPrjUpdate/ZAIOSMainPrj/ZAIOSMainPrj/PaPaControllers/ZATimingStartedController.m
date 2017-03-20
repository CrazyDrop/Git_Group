//
//  ZATimingStartedController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/17.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZATimingStartedController.h"
#import "TBCircularSlider.h"
#import "ZAPasswordController.h"
#import "LocalTimingRefreshManager.h"
#import "KKNavigationController.h"
#import "ZAWarnCancelTopVC.h"
#import "DPViewController+WebCheck.h"
#import "ZAShareLocationController.h"
#import "ZADoMenuController.h"
#import "DPViewController+SharePath.h"
#import "DPViewController+Message.h"
@interface ZATimingStartedController ()
{
    UILabel * pointLbl;
    TBCircularSlider * timeCircle;
//    NSInteger secondNum;
    ZAPasswordController * _showPWD;
    BaseRequestModel * _requestModel;
    UIButton * doMenuBtn;
}
@property (nonatomic, strong) ZADoMenuController *menuVC;
@property (nonatomic,strong) UIAlertView * diaAlert;
@end

//每分钟定时检查响应
@implementation ZATimingStartedController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self =  [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startRefreshCircleViewWithNotification:)
                                                     name:NOTIFICATION_TIMING_VIEWREFRESH_FORLOCK_STATE
                                                   object:nil];
    }
    return self;
}

-(void)startRefreshCircleViewWithNotification:(NSNotification *)not
{
    NSTimeInterval lastCount = [DZUtils endTimeSecondNeedContinue];
    NSTimeInterval extendCount = self.timingNum - lastCount;
    
    NSLog(@"%s %ld %f",__FUNCTION__,(long)self.timingNum,lastCount);

    if(lastCount>0 && extendCount>10)
    {
        self.timingNum = lastCount;
        
        LocalTimingRefreshManager * manager = [LocalTimingRefreshManager sharedInstance];
        [manager saveCurrentAndStartAutoRefresh];
    }


}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self setUpUI];
    
    __weak ZATimingStartedController * weakSelf = self;
    LocalTimingRefreshManager * manager = [LocalTimingRefreshManager sharedInstance];
    manager.refreshInterval = 1;
    manager.functionInterval = 1;
    manager.funcBlock = ^()
    {
        [weakSelf localTimeDidChange:nil];
    };
    [manager saveCurrentAndStartAutoRefresh];
    
    [self showTextWithCurrentTimingNum:nil];
//    [self refreshWebListenForSpecialController];
    
    if(self.doStr)
    {
        [self refreshLocalDoMenuBtnWithString:self.doStr];
    }
}
-(void)setUpUI
{
    [self showSpecialStyleTitle];
    self.leftBtn.hidden = YES;
    
    UIView * bgView = self.view;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
    img.image = [UIImage imageNamed:@"dark_blue_total"];
    img.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:img];
    [self.view sendSubviewToBack:img];
    
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame) ;
    startY += 20;
    
    CGFloat circleRadius = TBCIRCLESLIDER_COMMON_RADIUS;
    if(SCREEN_HEIGHT == 480) circleRadius *= 0.8;
    
    //使用相对的计算坐标
    TBCircularSlider * circle = [[TBCircularSlider alloc] initWithFrame:CGRectMake(0, 0, circleRadius * 2 + 2, circleRadius * 2 + 2)];
    [bgView addSubview:circle];
    circle.lineWidth = FLoatChange(3);
    circle.showPersent = YES;
    //    circle.backgroundColor = [UIColor redColor];
    circle.center = CGPointMake( SCREEN_WIDTH / 2.0, startY + circle.bounds.size.height / 2.0 );
    timeCircle = circle;
    circle.userInteractionEnabled = NO;
    
    
    CGFloat fontSize = FLoatChange(50);
    if(SCREEN_HEIGHT == 480) fontSize = FLoatChange(48);
    //    NSString * fontName = @"HelveticaNeue";
    
    UIFont * font = [UIFont fontWithName:@"STHeitiTC-Light" size:fontSize];
    NSString * str = @"000";
    CGFloat moveY = -FLoatChange(15);
    
    rect = circle.bounds;
    CGFloat lblHeight = rect.size.height * 1/3.0;
    rect.origin.y = rect.size.height / 2.0 - lblHeight + FLoatChange(10) + moveY;
    //     ;
    rect.size.height = lblHeight;
    
    UILabel * timeLbl = [[UILabel alloc] initWithFrame:rect];
    [circle addSubview:timeLbl];
    timeLbl.font = font;
    timeLbl.text = str;
    timeLbl.textAlignment = NSTextAlignmentCenter;
    //    timeLbl.center = CGPointMake( CGRectGetMidX(circle.bounds), CGRectGetMidY(circle.bounds));
    hourLbl = timeLbl;
    timeLbl.textColor = [UIColor whiteColor];
    
    str = @"MIN";
    font = [UIFont systemFontOfSize:FLoatChange(20)];
    timeLbl = [[UILabel alloc] initWithFrame:hourLbl.bounds];
    [circle addSubview:timeLbl];
    timeLbl.font = font;
    timeLbl.text = str;
    timeLbl.textAlignment = NSTextAlignmentCenter;
    timeLbl.center = CGPointMake( CGRectGetMidX(circle.bounds), CGRectGetMidY(circle.bounds)+ FLoatChange(10) + moveY);
    //    pointLbl = timeLbl;
    timeLbl.textColor = [UIColor whiteColor];
    
    
    //    str = @":";
    //    timeLbl = [[UILabel alloc] initWithFrame:circle.bounds];
    //    [hourLbl addSubview:timeLbl];
    //    timeLbl.font = [UIFont fontWithName:fontName size:fontSize];
    //    timeLbl.text = str;
    //    timeLbl.textAlignment = NSTextAlignmentCenter;
    //    timeLbl.center = CGPointMake( CGRectGetMidX(hourLbl.bounds), CGRectGetMidY(hourLbl.bounds) - 5);
    ////    pointLbl = timeLbl;
    //    timeLbl.textColor = [UIColor whiteColor];
    //    timeLbl.hidden = YES;
    
    str = @"320s";
    timeLbl = [[UILabel alloc] initWithFrame:circle.bounds];
    [circle addSubview:timeLbl];
    timeLbl.font = font;
    timeLbl.text = str;
    [timeLbl sizeToFit];
    timeLbl.textAlignment = NSTextAlignmentCenter;
    timeLbl.center = CGPointMake(hourLbl.center.x, circle.bounds.size.height - FLoatChange(70));
    secondLbl = timeLbl;
    timeLbl.textColor = [UIColor whiteColor];
    
    
    startY = CGRectGetMaxY(circle.frame);
    CGFloat btnWidth = FLoatChange(120);
    CGFloat sepY = (SCREEN_HEIGHT - startY - btnWidth) / 3.0;
    
    UILabel * txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
    txtLbl.font = [UIFont systemFontOfSize:FLoatChange(15)];
    txtLbl.text = @"      定时防护中";
    txtLbl.textAlignment = NSTextAlignmentCenter;
    [txtLbl sizeToFit];
    txtLbl.textColor = TB_SLIDER_HEIGHT1_LINE_COLOR;
    txtLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, startY + sepY - txtLbl.bounds.size.height / 2.0);
    [bgView addSubview:txtLbl];
    
    UIImage * image = [UIImage imageNamed:@"time_protect_started"];
    img = [[UIImageView alloc] initWithImage:image];
    [txtLbl addSubview:img];
    img.center = CGPointMake(img.bounds.size.width / 2.0, txtLbl.bounds.size.height / 2.0);
    txtLbl.hidden = YES;
    
    
    CGFloat helpBtnWidth = FLoatChange(115);
    CGSize btnSize = CGSizeMake(helpBtnWidth,helpBtnWidth * 95.0/268.0);
    //    CGSize imgSize =  CGSizeMake((40), (40));
    //    CGFloat btnSep = FLoatChange(20);
    CGFloat leftSep = FLoatChange(38);
    UIColor * color = [DZUtils colorWithHex:@"E57474"];
    UIFont * sizeFont = [UIFont systemFontOfSize:FLoatChange(14)];
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    [bgView addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnHelpBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(leftSep + btnSize.width /2.0, SCREEN_HEIGHT - sepY + FLoatChange(15) - btnSize.width / 2.0);
    NSString * title = @"立即求助";
    btn.titleLabel.font = sizeFont;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [[btn layer]setCornerRadius:FLoatChange(20)];//圆角
    //    [btn refreshZASelectedButtonWithCurrentBGColor:btn.backgroundColor];
    [btn setBackgroundImage:[UIImage imageNamed:@"timing_help_btn_bg"] forState:UIControlStateNormal];
    
    
    //    [btn setImage:[UIImage imageNamed:@"time_telphone"] forState:UIControlStateNormal];
    //    [btn setImage:[UIImage imageNamed:@"QQLogin"] forState:UIControlStateSelected];
    //    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    
    //    CGSize strSize = [title sizeWithFont:sizeFont];
    //    CGFloat titleHeight = strSize.height;
    //    CGFloat topY = (btnWidth - imgSize.height - btnSep - titleHeight ) / 2.0;
    //    UIEdgeInsets imgInset = UIEdgeInsetsMake(topY , (btnWidth - imgSize.width)/2.0, topY + titleHeight + btnSep, (btnWidth - imgSize.width)/2.0);
    //    UIEdgeInsets titleInset = UIEdgeInsetsMake( 0 ,- strSize.width / 2.0 , - imgSize.height , 0);
    //
    //    btn.imageEdgeInsets = imgInset;
    //    btn.titleEdgeInsets = titleInset;
    //    btn.titleLabel.backgroundColor = [UIColor clearColor];
    //    CALayer * layer = btn.layer;
    //    [layer setCornerRadius:btnWidth/2.0];
    //    layer.borderWidth = 1;
    //    layer.borderColor = [color CGColor];
    
    CGPoint pt = btn.center;
    pt.x = SCREEN_WIDTH - pt.x;
    
    color = [DZUtils colorWithHex:@"429AAB"];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    [bgView addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnSafeBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.center = pt;
    title = @"结束防护";
    btn.titleLabel.font = sizeFont;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [btn refreshZASelectedButtonWithCurrentBGColor:btn.backgroundColor];
    //    [btn setBackgroundImage:[UIImage imageNamed:@"timing_safe_btn_bg"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"timing_safe_btn_bg"] forState:UIControlStateNormal];
    
    //    [btn setImage:[UIImage imageNamed:@"QQLogin"] forState:UIControlStateSelected];
    //    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    //    btn.imageEdgeInsets = imgInset;
    //    btn.titleEdgeInsets = titleInset;
    //    btn.titleLabel.backgroundColor = [UIColor clearColor];
    //    layer = btn.layer;
    //    [layer setCornerRadius:btnWidth/2.0];
    //    layer.borderWidth = 1;
    //    layer.borderColor = [color CGColor];
    
    
    //    secondNum = 0;
    
    btnWidth = FLoatChange(100);
    CGFloat btnHeight = btnWidth/200.0*68.0;;
    // 分享轨迹按钮
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat shareBtnY = CGRectGetMaxY(circle.frame);
    
    shareBtn.frame = CGRectMake(0, shareBtnY+FLoatChange(20), btnWidth, btnHeight);
    [shareBtn setTitle:@"分享轨迹  " forState:UIControlStateNormal];
    [shareBtn setTitleColor:[UIColor colorWithRed:248.0 green:248.0 blue:248.0 alpha:1.0] forState:UIControlStateNormal];
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(13)];
    [bgView addSubview:shareBtn];
    [shareBtn addTarget:self action:@selector(tapedOnShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"started_share_btnbg"] forState:UIControlStateNormal];
    
    
    // 去做什么按钮
    UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    goBtn.frame = CGRectMake(SCREEN_WIDTH-btnWidth, shareBtnY+FLoatChange(20), btnWidth, btnHeight);
    [goBtn setTitle:@"  去做什么" forState:UIControlStateNormal];
    [goBtn setTitleColor:[UIColor colorWithRed:248.0 green:248.0 blue:248.0 alpha:1.0] forState:UIControlStateNormal];
    goBtn.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(13)];
    [bgView addSubview:goBtn];
    [goBtn addTarget:self action:@selector(tapedOnGoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [goBtn setBackgroundImage:[UIImage imageNamed:@"started_dowhat_btnbg"] forState:UIControlStateNormal];
    doMenuBtn = goBtn;

}

-(void)effectiveForWebStateCheck:(BOOL)connect
{
    if(!connect)
    {
        [self showDialogForWebConnectError];
    }else{
        [self.diaAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //鉴于密码页面增加了返回按钮，改变show的展示统计形式
    [KMStatis staticTimingViewEvent:StaticPaPaTimingEventType_Show];
    
}
-(void)showDialogForWebConnectError
{
    if(!self.diaAlert)
    {
        NSString * log = @"当前无网络，我们会在倒计时结束后与您联系。紧急情况建议您拨打110。";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"当前无网络"
                                                         message:log
                                                        delegate:nil
                                               cancelButtonTitle:@"确认"
                                               otherButtonTitles:nil, nil];
        self.diaAlert = alert;
    }
    [self.diaAlert show];
    
}
-(void)timeRefreshEndWithTimeStop
{
    //隐藏之前弹出的分享界面
    [self hideSharePathShareView];
    [self hideActionForPostMessageView];
    
    //提高级别
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    manager.priority = @"1";
    [manager refreshRefreshTimeWithHeighPriority];
    
    [[LocalTimingRefreshManager sharedInstance] endAutoRefreshAndClearTime];

    
    //改变本地数据状态，实际不改变也可以(考虑可能的时间差异改变)
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    local.showPWD = YES;
    local.endDate = nil;
    local.totalTime = 0;
    [local localSave];
    

    //关闭可能的倒计时强制界面
    if(self.viewDeckController.presentedViewController)
    {
        //进行处理，重新弹出界面
        [_showPWD dismissViewControllerAnimated:NO completion:nil];
    }
    [self showWarnCancelViewWithPushWithHelpStartedState:NO];
    return;
    //弹出倒计时强制界面
    //清空数据
    __weak ZATimingStartedController * weakSelf = self;
    ZAPasswordController * pwd = [[ZAPasswordController alloc] init];
    UINavigationController * pwdNa = [[UINavigationController alloc] initWithRootViewController:pwd];
    pwdNa.navigationBarHidden = YES;
    pwd.PWDCheckSuccessBlock = ^(PWDCheckFinishType type)
    {
        
        UIViewController * controller = weakSelf.viewDeckController;
        
        UINavigationController * nacon = [weakSelf rootNavigationController];
        [nacon popViewControllerAnimated:NO];
        
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    
    
//    ZAWarnCancelTopVC * warn = [[ZAWarnCancelTopVC alloc] init];
//    [pwdNa pushViewController:warn animated:NO];
//    warn.TapedCancelWarnBlock = ^()
//    {
//        [pwd.navigationController popViewControllerAnimated:YES];
//        [pwd restartPWDTimerRefresh];
//    };
    pwd.timeEndState = YES;
    _showPWD = pwd;
    [self.viewDeckController presentViewController:pwdNa animated:YES completion:nil];
    
}

//修改逻辑，改为秒数变化也可以改变弧度范围
-(void)localTimeDidChange:(id)sender
{
    NSInteger number = self.timingNum;
    number --;
    
    //响应最终事件
    if(number == 0 )
    {
        [[LocalTimingRefreshManager sharedInstance] endAutoRefreshAndClearTime];
        [self timeRefreshEndWithTimeStop];
        return;
    }
    self.timingNum = number;
    //进行闪烁
//    NSInteger second = number % 60;
//    secondLbl.text = [NSString stringWithFormat:@"%02lds",(long)second];
    
//    pointLbl.hidden = !pointLbl.hidden;
    pointLbl.hidden = NO;
    [UIView animateWithDuration:0.5
                     animations:^{
                         pointLbl.alpha = 1;
                     }];
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         pointLbl.alpha = 0.3;
                     } completion:nil];
    
    [self showTextWithCurrentTimingNum:nil];
}

-(void)showTextWithCurrentTimingNum:(id)sender
{
    NSInteger totalSecond = self.timingNum;
    
    if(totalSecond<0) return;
    
    NSInteger second = totalSecond % 60;
    NSInteger number = totalSecond / 60;
    
    NSInteger min = number % 60;
    NSInteger hour = number / 60;
    
//    hourLbl.text = [NSString stringWithFormat:@"%ld : %02ld",(long)number,(long)second];
    hourLbl.text = [NSString stringWithFormat:@"%ld",(long)number];
    if(number<100)
    {
        hourLbl.text = [NSString stringWithFormat:@" %02ld",(long)number];
    }
//    if(number<10)
//    {
//        hourLbl.text = [NSString stringWithFormat:@"  %ld",(long)number];
//    }
    secondLbl.text = [NSString stringWithFormat:@" %02ld",(long)second];
    
    CGFloat angleEx = (totalSecond + 0.0) / self.totalTimingNum;
//    timeCircle.angle = angleEx * 360.0;
    
    timeCircle.circleColor = second%2==0?[DZUtils colorWithHex:@"B8E9F2"]:[UIColor whiteColor];
    [timeCircle setSliderScale:angleEx];
    
//    NSLog(@"%s,time lamited %@",__FUNCTION__,secondLbl.text);
}


#pragma mark WarnTimingModel
handleSignal( WarningModel, requestError )
{
    [self hideLoading];
    //失败时，可以考虑本地保存，下次启动再次检查发送
    __weak typeof(self) weakSelf = self;
    [DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:^(BOOL netEnable) {
        if(!netEnable){
            [weakSelf showDialogForWebConnectError];
            return ;
        }
        [DZUtils noticeCustomerWithShowText:kAppNone_Service_Error];
    }];
}
handleSignal( WarningModel, requestLoading )
{
        [self showLoading];
}
handleSignal( WarningModel, requestLoaded )
{
    [self hideLoading];
//    [DZUtils noticeCustomerWithShowText:@"怕怕客服部门已经获知您的求助需求，很快会和您联系"];
//    [self showWarnCancelViewWithPush];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        //此时状态改变
        ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
        local.showPWD = YES;
        [local localSave];
        
        [self showWarnCancelViewWithPushWithHelpStartedState:YES];
    }

}
#pragma mark -
#pragma mark DoWhatModel
handleSignal( DoWhatModel, requestError )
{
//    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( DoWhatModel, requestLoading )
{
//    [self showLoading];
}
handleSignal( DoWhatModel, requestLoaded )
{
//    [self hideLoading];
    
    BOOL result = [DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:nil];
    if(result)
    {
        NSString * msg = @"已提交我们会在您的后方一直保护您";
        [DZUtils noticeCustomerWithShowText:msg];
        
        DoWhatModel * model = (DoWhatModel *)_requestModel;
        [self refreshLocalDoMenuBtnWithString:model.whattodo];
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        WarnTimingModel * local = total.timeModel;
        local.whattodo = model.whattodo;
        [total localSave];
    }
}

#pragma mark -
-(void)refreshLocalDoMenuBtnWithString:(NSString *)str
{
    NSString * show = @"其他";
    NSArray * arr = [ZADoMenuController ZATagMenuArray];
    if([arr containsObject:str])
    {
        show = str;
    }
    show = [NSString stringWithFormat:@"  %@",show];
    [doMenuBtn setTitle:show forState:UIControlStateNormal];
}

-(void)showWarnCancelViewWithPushWithHelpStartedState:(BOOL)help
{
    __weak typeof(self) weakSelf = self;
    
    ZAPasswordController * pwd = [[ZAPasswordController alloc] init];
    pwd.PWDCheckSuccessBlock = ^(PWDCheckFinishType type)
    {
        
        UIViewController * controller = weakSelf.viewDeckController;
        
        UINavigationController * nacon = [weakSelf rootNavigationController];
        [nacon popViewControllerAnimated:NO];
        
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    pwd.showBack = YES;
    
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    ZAConfigModel * config = [ZAConfigModel sharedInstanceManager];
    NSDate * notice = [NSDate dateWithTimeIntervalSinceNow:[config.quick_waiting_length intValue]];
    if(!help){
        notice = [NSDate dateWithTimeIntervalSinceNow:[config.timing_waiting_length intValue]];
    }
    total.noticeDate = notice;
    [total localSave];
    
    ZAWarnCancelTopVC * warn = [[ZAWarnCancelTopVC alloc] init];
    warn.startRecorder = help;
    warn.showRedTop = YES;
    warn.changeDate = notice;
    
    UINavigationController * pwdNa = [[UINavigationController alloc] initWithRootViewController:warn];
    pwdNa.navigationBarHidden = YES;
    warn.TapedCancelWarnBlock = ^()
    {
        [pwdNa pushViewController:pwd animated:YES];
//        [pwd restartPWDTimerRefresh];
        [pwd stopPWDTimerAndHiddenLbl];
    };
    
    [self.viewDeckController presentViewController:pwdNa animated:YES completion:nil];

}

-(void)showWarnCancelView
{
    __weak typeof(self) weakSelf = self;
    
    ZAPasswordController * pwd = [[ZAPasswordController alloc] init];
    UINavigationController * pwdNa = [[UINavigationController alloc] initWithRootViewController:pwd];
    pwdNa.navigationBarHidden = YES;
    pwd.PWDCheckSuccessBlock = ^(PWDCheckFinishType type)
    {
        
        UIViewController * controller = weakSelf.viewDeckController;
        
        UINavigationController * nacon = [weakSelf rootNavigationController];
        [nacon popViewControllerAnimated:NO];
        
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    
    
    ZAWarnCancelTopVC * warn = [[ZAWarnCancelTopVC alloc] init];
    [pwdNa pushViewController:warn animated:NO];
    warn.TapedCancelWarnBlock = ^()
    {
        [pwd.navigationController popViewControllerAnimated:YES];
//        [pwd restartPWDTimerRefresh];
        [pwd stopPWDTimerAndHiddenLbl];

    };
    
    [self.viewDeckController presentViewController:pwdNa animated:YES completion:nil];
}

-(void)startWhatToDoRequestWithString:(NSString *)str;
{
    if(!str || [str length]==0) return;
    self.doStr = str;
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    WarnTimingModel * local = total.timeModel;
    
    DoWhatModel * model = (DoWhatModel *)_requestModel;
    if(!model){
        model = [[DoWhatModel alloc] init];
        [model addSignalResponder:self];
        _requestModel = model;
    }
    model.warningId = local.timeId;
    model.whattodo = str;
    [model sendRequest];
}


//分享轨迹
-(void)tapedOnShareBtn:(id)sender
{
    [KMStatis staticSharePathStaticEvent:StaticPaPaSharePathEventType_Start];
    
    ZAShareLocationController *shareLocation = [ZAShareLocationController new];
    [[self navigationController] pushViewController:shareLocation animated:YES];
}

// 去做什么
-(void)tapedOnGoBtn:(id)sender
{
    [KMStatis staticDoMenuStartEvent:StaticPaPaDoMenuEventType_Start andText:nil];

    __weak typeof(self) weakSelf = self;
    ZADoMenuController * menu = self.menuVC;
    if(!menu)
    {
        menu = [[ZADoMenuController alloc]init];
        self.menuVC = menu;
    }
    menu.DoneDoMenuBlock = ^(NSString * str)
    {
        [KMStatis staticDoMenuStartEvent:StaticPaPaDoMenuEventType_Finish andText:str];
        [weakSelf.menuVC.view removeFromSuperview];
        [weakSelf startWhatToDoRequestWithString:str];
        weakSelf.menuVC = nil;
    };
    
    menu.currentStr = self.doStr;
    [self.view addSubview:menu.view];
//    [self presentViewController:menu animated:NO completion:nil];


}


-(void)tapedOnSafeBtn:(id)sender
{
    [KMStatis staticTimingViewEvent:StaticPaPaTimingEventType_Safe];

//    NSString * errStr = @"您的网络好像不太给力，请稍后再试";
    if(![DZUtils deviceWebConnectEnableCheck])
    {
//        [self showDialogForWebConnectError];
        //改为提示
        [DZUtils noticeCustomerWithShowText:kAppNone_Network_Error];
        return;
    }
    
    
    //
    __weak ZATimingStartedController * weakSelf = self;
    ZAPasswordController * pwd = [[ZAPasswordController alloc] init];
    _showPWD = pwd;
    pwd.showBack = YES;
    pwd.PWDCheckSuccessBlock = ^(PWDCheckFinishType type)
    {
        
        UIViewController * controller = weakSelf.viewDeckController;

        UINavigationController * nacon = [weakSelf rootNavigationController];
        [nacon popViewControllerAnimated:NO];
        
        [controller dismissViewControllerAnimated:YES completion:nil];
        
    };
    [self.viewDeckController presentViewController:pwd animated:YES completion:nil];

}
-(void)tapedOnHelpBtn:(id)sender
{
    [KMStatis staticTimingViewEvent:StaticPaPaTimingEventType_Help];

    if(![DZUtils deviceWebConnectEnableCheck])
    {
        [self showDialogForWebConnectError];
        return;
    }

    
    //    NSString * number = @"110";
    //    NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",number];
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager refreshRefreshTimeWithHeighPriority];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    WarnTimingModel * local = total.timeModel;
//    [WarnTimingModel warnTimingFromLocalSave];
//    if(!local||!local.timeId||[local.timeId length]==0) return;
    
    //数据上传，通知解除
    WarningModel * model = (WarningModel *) _dpModel;
    if(!model){
        model = [[WarningModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    model.timingId = local.timeId;
    model.scene = local.scene;
    model.type = WarningModel_TYPE_START;
    [model sendRequest];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
