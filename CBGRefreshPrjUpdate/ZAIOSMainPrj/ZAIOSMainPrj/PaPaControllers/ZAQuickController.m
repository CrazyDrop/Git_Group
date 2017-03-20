//
//  ZAQuickController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAQuickController.h"
#import "ZAQuickCircle.h"
#import "ZAPasswordController.h"

@interface ZAQuickController ()
{
    UILabel * noticeLbl;
    BOOL effective;
    BOOL touchFinished;
}
@property (nonatomic,strong) ZAQuickCircle * circleView;
@end

@implementation ZAQuickController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showSpecialStyleTitle];
    
    effective = NO;
    touchFinished = YES;
//    CGFloat startY = CGRectGetMaxY(self.titleBar.frame) ;
    //红色区域的半径
    CGFloat circleRadius = TBCIRCLESLIDER_COMMON_RADIUS;
    if(SCREEN_HEIGHT == 480) circleRadius *= 0.8;
    
    CGFloat extend = 15;
    circleRadius += extend;
    
    //边线圆圈
    UIView * bgView = self.view;

    ZAQuickCircle * circle = [[ZAQuickCircle alloc] initWithFrame:CGRectMake(0, 0, circleRadius * 2, circleRadius * 2)];
    [bgView addSubview:circle];
    circle.center = CGPointMake(SCREEN_WIDTH / 2.0, (SCREEN_HEIGHT - ZA_TABBAR_HEIGHT ) / 2.0);
    [circle addTarget:self action:@selector(tapedOnStartTouchDown:) forControlEvents:UIControlEventTouchDown];
    [circle addTarget:self action:@selector(doneTouchDownWtihSender:) forControlEvents:UIControlEventTouchCancel];
    [circle addTarget:self action:@selector(doneTouchDownWtihSender:) forControlEvents:UIControlEventEditingDidEnd];

    self.circleView = circle;
    
//    CGFloat extendY = FLoatChange(10);
    UILabel * txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [bgView addSubview:txtLbl];
    txtLbl.font = [UIFont systemFontOfSize:FLoatChange(14)];
    txtLbl.textAlignment = NSTextAlignmentCenter;
    txtLbl.text = @"长按圆环进入紧急防护";
    txtLbl.backgroundColor = [UIColor clearColor];
    [txtLbl sizeToFit];
    txtLbl.textColor = [UIColor grayColor];
    txtLbl.center = CGPointMake(SCREEN_WIDTH / 2.0, extend + txtLbl.bounds.size.height / 2.0 + CGRectGetMaxY(circle.frame));
    noticeLbl = txtLbl;
    

    
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

    effective = NO;
    touchFinished = NO;
    
    NSString * log = nil;
    ZALocation * locationInstance = [ZALocation sharedInstance];
    __weak typeof(self)  weakSelf = self;
    
    //点击登录按钮
    //未设置过，弹出提示页面，确认后弹出系统请求页面
    if([ZALocation locationStatusNeverSetting])
    {
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Quick_Fail];

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
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Quick_Fail];

        if(iOS8_constant_or_later)
        {
            log = @"我们怕怕需要您的位置信息,需要您许可该功能,请在设置中打开";
            BlockAlertView * alert = [BlockAlertView alertWithTitle:@"提示" message:log];
            [alert setDestructiveButtonWithTitle:@"确定" block:^{
                [weakSelf hideLoading];
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
        [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Quick_Fail];

        log = kAppNone_Network_Error;
        [DZUtils noticeCustomerWithShowText:log];
        [weakSelf hideLoading];
        return;
    }
    
    [KMStatis staticWarningStartEvent:StaticPaPaWarningStartType_Quick_Success];
    
    noticeLbl.text = @"安全后请松手";
    [self.circleView refreshCircleWithSelected:YES];
    

    //启动位置上传
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    manager.scene = @"2";
    manager.priority = @"0";
    [manager refreshRefreshTimeWithNormalPriority];
    
    
    
    //数据上传，取出
    WarnTimingModel * model = (WarnTimingModel *) _dpModel;
    if(!model){
        model = [[WarnTimingModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    //紧急模式，启动3小时倒计时
    NSInteger total = 60 * 24;
    model.duration = [NSString stringWithFormat:@"%ld",total*60];
    model.scene = @"2";
    //增加随机数
    [model sendRequest];

}


#pragma mark WarnTimingModel
handleSignal( WarnTimingModel, requestError )
{
    //启动再次重试
    //记录预警启动失败事件，暂无法重试(待下期增加随机数后需要)
    //重发未结束前，不能置为YES
//    effective = NO;
    
    //当网络失败时，用户松手不松手，都需要处理
    [self doneTouchDownWtihSender:nil];
    [self hideLoading];
    
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    NSString * log = kAppNone_Service_Error;
    if([DZUtils deviceWebConnectEnableCheck])
    {
        log = kAppNone_Network_Error;
    }
    [DZUtils noticeCustomerWithShowText:log];
    
    [self localSaveTimingStartedState:NO];

}
handleSignal( WarnTimingModel, requestLoading )
{
//    [self showLoading];
}

handleSignal( WarnTimingModel, requestLoaded )
{
    [self hideLoading];
//    if([DZUtils checkAndNoticeErrorWithSignal:signal])

    
    //本地保存，以便实现管理
    //如果当前已经关闭了定位，则不在保存
    WarnTimingModel * model = (WarnTimingModel *)_dpModel;
    if(!model.timeId||[model.timeId  length]==0)
    {
        _dpModel = nil;
        [self handleSignal____WarnTimingModel____requestError:nil];
        return;
    }
    
    [self localSaveTimingStartedState:YES];

    //当返回正常时，仅在用户松手的情况进行操作
    effective = YES;
    //提前事件按下已经提前结束了
    if(touchFinished)
    {
        //再次启动
        [self hideLoading];
        [self doneTouchDownWtihSender:nil];
    }
    
}
#pragma mark -
-(void)localSaveTimingStartedState:(BOOL)success
{
    WarnTimingModel * model = (WarnTimingModel *)_dpModel;
    
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    //本地保存，实现与服务器通信超时时的处理
    //如果时间展示发生变化，计算方式需要改变
    local.timeModel = model;
    local.warningId = [model.timeId copy];
    local.totalTime = 0;
    local.showPWD = YES;
    local.endDate = nil;
    [local localSave];
}



//松手后
-(void)doneTouchDownWtihSender:(id)sender
{
    touchFinished = YES;
    if(!effective)
    {
        //网络请求未返回，用户已经松手，则展示等待框
        noticeLbl.text = @"长按圆环进入紧急防护";
        [self.circleView refreshCircleWithSelected:NO];
        if(_dpModel)
        {//仅针对有网络请求的展示等待框
            [self showLoading];
        }
        return;
    }

    //进行数据发送
    noticeLbl.text = @"长按圆环进入紧急防护";
    [self.circleView refreshCircleWithSelected:NO];
    //启动密码界面
    __weak ZAQuickController * weakSelf = self;
    ZAPasswordController * pwd = [[ZAPasswordController alloc] init];
    UINavigationController * pwdNa = [[UINavigationController alloc] initWithRootViewController:pwd];
    pwdNa.navigationBarHidden = YES;
    pwd.PWDCheckSuccessBlock = ^(PWDCheckFinishType type)
    {
        [weakSelf.viewDeckController dismissViewControllerAnimated:YES completion:nil];
    };
    [self.viewDeckController presentViewController:pwdNa animated:YES completion:nil];
    
    
    
    
    LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
    [manager refreshRefreshTimeWithHeighPriority];
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
