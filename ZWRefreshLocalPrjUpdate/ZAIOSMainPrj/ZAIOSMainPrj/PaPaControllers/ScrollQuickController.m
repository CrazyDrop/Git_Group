//
//  ScrollQuickController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ScrollQuickController.h"
#import "ZAQuickCircle.h"
#import "ZAPasswordController.h"
#import "CircleAnimationView.h"
#import "ZAQuickCancelController.h"

#define ZA_Quick_Normal_TXT @"一键求助，怕怕帮您"
#define ZA_Quick_Hot_TXT    @"立即松手，怕怕帮您"


@interface ScrollQuickController ()
{
    UILabel * noticeLbl;
    BOOL prepareSuccess;//网络请求，是否准备成功，获取到timeid
    BOOL touchFinished;//点击事件是否结束
    CircleAnimationView * animatedCircle;
}
@property (nonatomic,strong) ZAQuickCircle * circleView;
@property (nonatomic,strong) UIAlertView * diaAlert;
@property (nonatomic,strong) UIAlertView * contactAlert;
@property (nonatomic,strong) UIAlertView * watchAlert;

@end

@implementation ScrollQuickController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    prepareSuccess = NO;
    touchFinished = NO;
    //    CGFloat startY = CGRectGetMaxY(self.titleBar.frame) ;
    //红色区域的半径
    CGFloat circleRadius = FLoatChange(137);
    if(SCREEN_Check_Special){
        circleRadius = FLoatChange(135);
        circleRadius *= 0.9;
    }
    
    CGFloat extend = FLoatChange(18);
    
    //边线圆圈
    UIView * bgView = self.view;
    
    
    
    
    ZAQuickCircle * circle = [[ZAQuickCircle alloc] initWithFrame:CGRectMake(0, 0, circleRadius * 2, circleRadius * 2)];
    [bgView addSubview:circle];
    circle.center = CGPointMake(SCREEN_WIDTH / 2.0, (SCREEN_HEIGHT - ZA_TABBAR_HEIGHT - circleRadius * 2) * 3.0 / 4.0 + circleRadius + FLoatChange(10));
    [circle addTarget:self action:@selector(tapedOnStartTouchDown:) forControlEvents:UIControlEventTouchDown];
    [circle addTarget:self action:@selector(doneTouchDownWtihSender:) forControlEvents:UIControlEventTouchUpInside];
    [circle addTarget:self action:@selector(doneTouchDownWtihSender:) forControlEvents:UIControlEventTouchCancel];
    [circle addTarget:self action:@selector(doneTouchDownWtihSender:) forControlEvents:UIControlEventEditingDidEnd];
    [circle setBackgroundColor:[UIColor clearColor]];
    self.circleView = circle;
    
    //    CGFloat extendY = FLoatChange(10);
    UILabel * txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [bgView addSubview:txtLbl];
    txtLbl.font = [UIFont boldSystemFontOfSize:FLoatChange(16)];
    txtLbl.textAlignment = NSTextAlignmentCenter;
    txtLbl.text = ZA_Quick_Normal_TXT;
    txtLbl.backgroundColor = [UIColor clearColor];
    [txtLbl sizeToFit];
    txtLbl.textColor = [UIColor whiteColor];
    txtLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, (CGRectGetMaxY(self.titleBar.frame) + CGRectGetMinY(circle.frame))/2.0 - extend);
    noticeLbl = txtLbl;
    
    UIImageView * img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_down_arrow"]];
    img.contentMode = UIViewContentModeScaleAspectFit;
//    CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI_2 * 3);
//    img.transform = transform;
    [bgView addSubview:img];
    img.center = CGPointMake(SCREEN_WIDTH / 2.0, (CGRectGetMaxY(txtLbl.frame) + CGRectGetMinY(circle.frame))/2.0);
    img.hidden = YES;
    
    CircleAnimationView * animatedView = [[CircleAnimationView alloc] initWithFrame:circle.bounds];
    animatedView.startLength = (circleRadius - circle.extend)*2;
    animatedView.maxLength = circleRadius*2;
    
    animatedView.shadowColor = RGB(200, 50, 54);
//    [circle addSubview:animatedView];
//    [circle sendSubviewToBack:animatedView];
    animatedCircle = animatedView;
    animatedView.userInteractionEnabled = NO;
    
    [bgView insertSubview:animatedView belowSubview:circle];
    animatedView.center = circle.center;
    
    
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshDragBackEnable:NO];
}
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//}

-(void)checkUpCurrentLocationWithString:(CLLocation *)str
{
    //如果有定位的数据返回，则用户同意，启动定位功能
    if(!str) return;
    
    //启动定时，此处操作不确定
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    manager.scene = @"2";
    manager.priority = @"0";
    [manager endAutoRefreshAndClearTime];
    
}
//按下按钮，启动
-(void)tapedOnStartTouchDown:(id)sender
{
    NSLog(@"%s",__FUNCTION__);
    
    prepareSuccess = NO;
    touchFinished = NO;
    
    NSString * log = nil;
    ZALocation * locationInstance = [ZALocation sharedInstance];
    __weak typeof(self)  weakSelf = self;
    
    //点击登录按钮
    //未设置过，弹出提示页面，确认后弹出系统请求页面
    if([ZALocation locationStatusNeverSetting])
    {
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Quick_Fail andTimeLength:nil];
        
        //也可以考虑替换 BlockAlertView
        //        log = @"我们怕怕需要您的位置信息,以判定您可能的危险";
        //        BlockAlertView * alert = [BlockAlertView alertWithTitle:@"提示" message:log];
        //        [alert setDestructiveButtonWithTitle:@"确定" block:^{
        //        }];
        //        [alert show];
        
        [locationInstance startLocationRequestUserAuthorization];
        [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *str)
         {
             [weakSelf hideLoading];
             [weakSelf checkUpCurrentLocationWithString:str];
         }];
        return;
    }
    
    //没启动定位功能，用户拒绝后再次点击
    if(![ZALocation locationStatusEnableInBackground])
    {
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Quick_Fail andTimeLength:nil];
        
        if(iOS8_constant_or_later)
        {
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
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Quick_Fail andTimeLength:nil];
        
        log = kAppNone_Network_Error;
        [DZUtils noticeCustomerWithShowText:log];
        [weakSelf hideLoading];
        return;
    }
    if(![DZUtils localWarningStateCheckIsNone])
    {
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Quick_Fail andTimeLength:nil];
        [self showDialogForNoWatchStartedError];
        [weakSelf hideLoading];
        return;
    }
    
    [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Quick_Success andTimeLength:nil];
    
    noticeLbl.text = ZA_Quick_Hot_TXT;
    self.leftBtn.hidden = YES;
    [self.circleView refreshCircleWithSelected:YES];
    [animatedCircle startCircleAnimation];
    
    //启动位置上传
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    manager.scene = @"2";
    manager.priority = @"0";
    [manager refreshRefreshTimeWithNormalPriority];
    
    
    
//    //数据上传，取出
//    WarnTimingModel * model = (WarnTimingModel *) _dpModel;
//    if(!model){
//        model = [[WarnTimingModel alloc] init];
//        [model addSignalResponder:self];
//        _dpModel = model;
//    }
//    //紧急模式，启动3小时倒计时
//    NSInteger total = 60 * 24;
//    model.duration = [NSString stringWithFormat:@"%ld",total*60];
//    model.scene = @"2";
//    //增加随机数
//    [model sendRequest];
    
    GetContactsModel * model = (GetContactsModel *) _dpModel;
    if(!model){
        model = [[GetContactsModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    [model sendRequest];
}


#pragma mark GetContactsModel
handleSignal( GetContactsModel, requestError )
{
    //启动再次重试
    //记录预警启动失败事件，暂无法重试(待下期增加随机数后需要)
    //重发未结束前，不能置为YES
    //    prepareSuccess = NO;
    
    //当网络失败时，用户松手不松手，都需要处理
    [self doneTouchDownWtihSender:nil];
    [self hideLoading];
    
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    
    [DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:^(BOOL netEnable) {
        NSString * log = kAppNone_Service_Error;
        if(!netEnable)
        {
            log = @"您的网络好像不太给力，请稍后再试";
        }
        [DZUtils noticeCustomerWithShowText:log];
    }];
    
//    [self localSaveTimingStartedState:NO];
    
}
handleSignal( GetContactsModel, requestLoading )
{
    //    [self showLoading];
}

handleSignal( GetContactsModel, requestLoaded )
{
    [self hideLoading];

    BOOL result =     [DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:^(BOOL netEnable) {
        NSString * log = kAppNone_Service_Error;
        if(!netEnable)
        {
            log = @"您的网络好像不太给力，请稍后再试";
        }
        [DZUtils noticeCustomerWithShowText:log];
    }];;
    
    if(!result) return;
    
    GetContactsModel * getModel = (GetContactsModel *)_dpModel;
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    
    [ContactsModel refreshWebContactsArr:getModel.contacts withLatestLocalArray:local.contacts];
    local.contacts = getModel.contacts;
    [local localSave];
    
    
    if(local.isNeedStartedAddContact)
    {
        [self stopQuickAnimationViewForError];
        [self showDialogForNoContactsError];
        return;
    }
    
    //本地保存，以便实现管理
    //如果当前已经关闭了定位，则不在保存
//    WarnTimingModel * model = (WarnTimingModel *)_dpModel;
//    if(!model.timeId||[model.timeId  length]==0)
//    {
//        
//        [self stopQuickAnimationViewForError];
//        [DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:^(BOOL netEnable) {
//            NSString * log = kAppNone_Service_Error;
//            if(!netEnable)
//            {
//                log = @"您的网络好像不太给力，请稍后再试";
//            }
//            [DZUtils noticeCustomerWithShowText:log];
//        }];
//        
////        [self localSaveTimingStartedState:NO];
//        return;
//    }
    
    
    //当返回正常时，仅在用户松手的情况进行操作
    prepareSuccess = YES;

    if(touchFinished)
    {
        //再次启动
        [self hideLoading];
        [self doneTouchDownWtihSender:nil];
    }
    
    //提前事件按下已经提前结束了
//    [self localSaveTimingStartedState:YES];
    
}
-(void)stopQuickAnimationViewForError
{
    [self doneTouchDownWtihSender:nil];
    [self hideLoading];
    
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
}

#pragma mark -
-(void)localSaveTimingStartedState:(BOOL)success
{
    WarnTimingModel * model = (WarnTimingModel *)_dpModel;
    
    NSInteger total = 24 * 60;

    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    //本地保存，实现与服务器通信超时时的处理
    //如果时间展示发生变化，计算方式需要改变
    local.timeModel = model;
    local.warningId = [model.timeId copy];
    local.totalTime = total;
    local.showPWD = YES;
    local.endDate = nil;
    [local localSave];

}



//松手后
-(void)doneTouchDownWtihSender:(id)sender
{
    NSLog(@"%s",__FUNCTION__);
    WarnTimingModel * model = (WarnTimingModel *)_dpModel;
    touchFinished = YES;
    if(!prepareSuccess)
    {
        //网络请求未返回，用户已经松手，则展示等待框
        noticeLbl.text = ZA_Quick_Normal_TXT;
        self.leftBtn.hidden = NO;
        [self.circleView refreshCircleWithSelected:NO];
        [animatedCircle stopCircleAnimation];
        
        if(model.isInRequesting)
        {//仅针对有网络请求的展示等待框
            [self showLoading];
        }
        return;
    }

    
    //进行数据发送
    self.leftBtn.hidden = NO;
    noticeLbl.text = ZA_Quick_Normal_TXT;
    [self.circleView refreshCircleWithSelected:NO];
    [animatedCircle stopCircleAnimation];
    //启动密码界面
    __weak typeof(self)  weakSelf = self;
//    ZAPasswordController * pwd = [[ZAPasswordController alloc] init];
//    pwd.needTimer = YES;
//    UINavigationController * pwdNa = [[UINavigationController alloc] initWithRootViewController:pwd];
//    pwdNa.navigationBarHidden = YES;
//    pwd.PWDCheckSuccessBlock = ^(PWDCheckFinishType type)
//    {
//        [weakSelf.viewDeckController dismissViewControllerAnimated:YES completion:nil];
//    };
//    [self.viewDeckController presentViewController:pwdNa animated:YES completion:nil];

    //启动5s界面
    ZAQuickCancelController * quick = [[ZAQuickCancelController alloc] init];
    UINavigationController * pwdNa = [[UINavigationController alloc] initWithRootViewController:quick];
    pwdNa.navigationBarHidden = YES;
    quick.TapedCancelWarnBlock = ^(PWDCheckFinishType type)
    {
        [weakSelf.viewDeckController dismissViewControllerAnimated:YES completion:nil];
    };
    [self.viewDeckController presentViewController:pwdNa animated:YES completion:nil];
    
    
    prepareSuccess = NO;
    
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    manager.scene = @"2";
    [manager refreshRefreshTimeWithHeighPriority];
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
