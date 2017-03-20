//
//  ZAQuickCancelController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/21.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAQuickCancelController.h"
#import "CancelWarningRefreshManager.h"
#import "ZAWarnCancelTopVC.h"
#import "ZAPasswordController.h"
#import "ZAShakingAnimationView.h"

@interface ZAQuickCancelController()
{
    UILabel * timeNumLbl;
    BOOL needRequest;
    ZAShakingAnimationView * shakeView;
}
@property (nonatomic,strong) UIAlertView * diaAlert;
@property (nonatomic,strong) UIAlertView * errAlert;
@end

@implementation ZAQuickCancelController
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self tapedOnCancelWarningBtn:nil];
}
-(void)showDialogForWebConnectError
{
    if(!self.diaAlert)
    {
        NSString * log = @"主人，手机网络异常，无法发起求助。请检查网络后再试~";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"当前无网络"
                                                         message:log
                                                        delegate:self
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil, nil];
        self.diaAlert = alert;
    }
    [self.diaAlert show];
    
}
-(void)showDialogForOurWebConnectError
{
    if(!self.errAlert)
    {
        NSString * log = @"服务器异常，请稍后再试~";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:log
                                                        delegate:self
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil, nil];
        self.errAlert = alert;
    }
    [self.errAlert show];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [shakeView startAnimation];
}

-(void)viewDidLoad
{
    [KMStatis staticQuickCancelViewEvent:StaticQuickCancelEventType_Show];
    
    self.viewTtle = @"即将发出求助请求";
    self.showLeftBtn = NO;
    needRequest = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showSpecialStyleTitle];
    self.titleBar.hidden = YES;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
    img.backgroundColor = RGB(245, 249, 251);
//    img.image = [UIImage imageNamed:@"dark_blue_total"];
    img.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:img];
    [self.view sendSubviewToBack:img];
    
    UIView * bgView = self.view;
    rect.size.height = FLoatChange(390);
    if(SCREEN_HEIGHT==480)
    {
        rect.size.height *= 0.85;
    }
    
    
    CGFloat btnWidth = SCREEN_WIDTH;
    CGFloat btnHeight = FLoatChange(55);
    //    if(SCREEN_HEIGHT == 480) btnHeight = 50;
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, SCREEN_HEIGHT - btnHeight, btnWidth, btnHeight);
    [btn addTarget:self action:@selector(tapedOnCancelWarningBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btn.titleLabel.font = [UIFont systemFontOfSize:FLoatChange(15)];
    [btn setTitle:@"取消求助" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"quick_cancel_bg"] forState:UIControlStateNormal];
//    [btn setBackgroundImage:[UIImage imageNamed:@"cancel_bottom_btn"] forState:UIControlStateNormal];
 
    
    UILabel * aLbl = [[UILabel alloc] initWithFrame:btn.bounds];
    aLbl.font =[UIFont systemFontOfSize:FLoatChange(11)];
    aLbl.text = @"如您安全，请尽快取消";
    [bgView addSubview:aLbl];
    aLbl.textColor = [DZUtils colorWithHex:@"282828"];
    [aLbl sizeToFit];
    aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - btnHeight - FLoatChange(25));
    
    
    CGFloat topHeight = FLoatChange(58);
    UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topHeight)];
    [bgView addSubview:aView];
    aView.backgroundColor = Custom_BG_Dark_Brown_Color;
    
    aLbl = [[UILabel alloc] initWithFrame:aView.bounds];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(16)];
    aLbl.text = @"即将发出求助";
    aLbl.textColor = [UIColor whiteColor];
    [aView addSubview:aLbl];
    [aLbl sizeToFit];
    aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, FLoatChange(35));
    
    
    CGFloat circleWidth = FLoatChange(175);
    CGFloat circleTop = FLoatChange(193);
    if(SCREEN_Check_Special){
        circleWidth = FLoatChange(135);
        circleTop = FLoatChange(180);
    }
    ZAShakingAnimationView * circle = [[ZAShakingAnimationView alloc] initWithFrame:CGRectMake(0, 0, circleWidth, circleWidth)];
    shakeView = circle;
    [bgView addSubview:circle];
    circle.backgroundColor = [DZUtils colorWithHex:@"EC6255"];
    [circle.layer setCornerRadius:circleWidth/2.0];
    circle.center = CGPointMake(SCREEN_WIDTH/2.0, circleTop);
    
    aLbl = [[UILabel alloc] initWithFrame:circle.bounds];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(52)];
    aLbl.text = @"5";
    aLbl.textAlignment = NSTextAlignmentCenter;
    aLbl.textColor = [UIColor whiteColor];
    [circle addSubview:aLbl];
    timeNumLbl = aLbl;
    
    NSString *text = @"怕怕将自动开启30秒录音，并通过电话及短信\n快速通知您的紧急联系人";
    //创建NSMutableAttributedString实例，并将text传入
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:text];
    //创建NSMutableParagraphStyle实例
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    //设置行距
    [style setLineSpacing:FLoatChange(8)];
    //根据给定长度与style设置attStr式样
    [attStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [attStr length])];
    
    aLbl = [[UILabel alloc] initWithFrame:bgView.bounds];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
//    aLbl.text = @"怕怕将自动开启30秒录音，并通过电话及短信\n快速通知您的紧急联系人";
    aLbl.attributedText = attStr;
    aLbl.textColor = [DZUtils colorWithHex:@"00334F"];
    aLbl.numberOfLines = 0;
    aLbl.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:aLbl];
    [aLbl sizeToFit];
    aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - FLoatChange(220));
    if(SCREEN_Check_Special){
        aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - FLoatChange(160));
    }
    
    
    [self startLocalTimingRefreshTimer];
}

-(void)startLocalTimingRefreshTimer
{
    CancelWarningRefreshManager * manager = [CancelWarningRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    manager.refreshInterval = 1;
    manager.functionInterval = 1;
    manager.funcBlock = ^()
    {
        [weakSelf localSecondTimeDidChange:nil];
    };
    timeNumLbl.hidden = NO;
    [manager saveCurrentAndStartAutoRefresh];
    timeNumLbl.text = @"5";

}
-(void)localSecondTimeDidChange:(id)sender
{
    [[CancelWarningRefreshManager sharedInstance] finishFunctionAndSaveCurrentTime];
    UILabel * showLbl = timeNumLbl;
    NSString * time =  showLbl.text;
    NSInteger number = NSNotFound;
    number = [time intValue];
    
    number --;
    
    if(number>=0)
    {
        showLbl.text = [NSString stringWithFormat:@"%ld",(long)number];
    }
    
    if(number == 0)
    {
        [self localSecondTimeDidStopChangeForFinish];
    }
}
-(void)localSecondTimeDidStopChangeForFinish
{
    [shakeView stopAnimation];
    [[CancelWarningRefreshManager sharedInstance] endAutoRefreshAndClearTime];

    if(!needRequest) return;
    [self startQuickWebRequest];
}


-(void)tapedOnCancelWarningBtn:(id)sender
{
    [KMStatis staticQuickCancelViewEvent:StaticQuickCancelEventType_Cancel];

    needRequest = NO;
    _dpModel = nil;
    [self hideLoading];
    
    if(self.TapedCancelWarnBlock)
    {
        self.TapedCancelWarnBlock();
    }
}

-(void)startQuickWebRequest
{
    [KMStatis staticQuickCancelViewEvent:StaticQuickCancelEventType_Request];
    
    //数据上传，通知解除
    QuickWarningModel * model = (QuickWarningModel *) _dpModel;
    if(!model){
        model = [[QuickWarningModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    NSInteger total = 60 * 24;
    model.duration = [NSString stringWithFormat:@"%ld",total*60];
    model.scene = @"2";
    [model sendRequest];
}

#pragma mark QuickWarningModel
handleSignal( QuickWarningModel, requestError )
{
    [self hideLoading];
    [self showDialogForWebConnectError];
}
handleSignal( QuickWarningModel, requestLoading )
{
    [self showLoading];
}

handleSignal( QuickWarningModel, requestLoaded )
{
    [self hideLoading];
    
    BOOL result =     [DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:^(BOOL netEnable) {
        NSString * log = kAppNone_Service_Error;
        if(!netEnable)
        {
            log = @"您的网络好像不太给力，请稍后再试";
            [self showDialogForWebConnectError];
            return ;
        }
//        [DZUtils noticeCustomerWithShowText:log];
        [self showDialogForOurWebConnectError];
        
    }];;
    
    if(!result) return;
    
    QuickWarningModel * quick = (QuickWarningModel *)_dpModel;
    if(quick.timeId && [quick.timeId length]>0)
    {
        [KMStatis staticQuickCancelViewEvent:StaticQuickCancelEventType_Request_Success];
        [self localSaveTimingStartedState:YES];
        
        //进入下一界面
        [self showWarningCancelViewWithRecorder];
    }else {
        [self showDialogForOurWebConnectError];
    }
    

}
-(void)showWarningCancelViewWithRecorder
{
    UINavigationController * pwdNa = self.navigationController;
    
    ZAPasswordController * pwd = [[ZAPasswordController alloc] init];
    pwd.PWDCheckSuccessBlock = ^(PWDCheckFinishType type)
    {
        AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIViewController * controller = appDel.homeCon.viewDeckController;
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    pwd.showBack = YES;
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    
    ZAWarnCancelTopVC * warn = [[ZAWarnCancelTopVC alloc] init];
    warn.startRecorder = YES;
    warn.showRedTop = YES;
    warn.changeDate = total.noticeDate;
    
    if(!pwdNa)
    {
       pwdNa = [[UINavigationController alloc] initWithRootViewController:warn];
    }
    
    pwdNa.navigationBarHidden = YES;
    warn.TapedCancelWarnBlock = ^()
    {
        [pwdNa pushViewController:pwd animated:YES];
        //        [pwd restartPWDTimerRefresh];
        [pwd stopPWDTimerAndHiddenLbl];
    };
    
    if(self.navigationController)
    {
        [pwdNa pushViewController:warn animated:YES];
    }else{
        [self.viewDeckController presentViewController:pwdNa animated:YES completion:nil];
    }
    
    
//    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//    WarnTimingModel * local = total.timeModel;
//    {
//        //倒计时未完成
//        LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
//        if(local.scene && [local.scene length]>0)
//        {
//            manager.scene = local.scene;
//        }
//        manager.priority = @"0";
//        [manager refreshRefreshTimeWithNormalPriority];
//    }
}

-(void)localSaveTimingStartedState:(BOOL)success
{
    QuickWarningModel * quick = (QuickWarningModel *)_dpModel;
    
    WarnTimingModel * model = [[WarnTimingModel alloc] init];
    model.timeId = quick.timeId;
    model.scene = quick.scene;
    model.duration = quick.duration;
    
    NSInteger total = 24 * 60;
    
    ZAConfigModel * config = [ZAConfigModel sharedInstanceManager];
    NSString * timeLength = config.quick_waiting_length;
    NSInteger number = [timeLength integerValue];
    if(!timeLength || number==0){
        number = 30;
    }
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:number];
    
    
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    //本地保存，实现与服务器通信超时时的处理
    //如果时间展示发生变化，计算方式需要改变
    local.timeModel = model;
    local.warningId = [model.timeId copy];
    local.totalTime = total;
    local.showPWD = YES;
    local.endDate = nil;
    local.noticeDate = date;
    [local localSave];
    
}



@end
