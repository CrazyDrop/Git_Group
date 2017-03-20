//
//  ZAHomeTabBarController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHomeTabBarController.h"
#import "ZATimingController.h"
#import "ZAQuickController.h"
#import "ZAPasswordController.h"
#import "PWDTimeManager.h"
#import "ZATimerStartedController.h"
#import "LocalTimingRefreshManager.h"
#import "ZALoginController.h"
#import "ZAStartUserController.h"
#import "KKNavigationController.h"
#import "TimeRefreshManager.h"
#import "StartZAUserController.h"
#import "StartZAContactController.h"
#import "ZABottomScrollTabbar.h"
#import "ZAScrollTimingController.h"
#import "ZATabbarItemView.h"
#import "ZAStartScrollController.h"
#import "ZAAddressController.h"
#import "ZAWarnCancelTopVC.h"
#import "AppDelegate.h"
#import "CityLocationManager.h"
#import "ZATipsShowController.h"
#import "ZAAddContactController.h"
#import "ZAContactListController.h"
#import "DPViewController+Message.h"
#import "ZAShareLocationController.h"
#import "ZAAddSomethingController.h"
#import "ZAAuthorityController.h"
#import "LewPopupViewAnimationFade.h"
#define ZA_TABBAR_BUTTON_ADDTAG 100
@interface ZAHomeTabBarController ()<ZABottomScrollTabbaDelegate,ZABottomScrollTabbarDataSource>
{
    UIView * darkLine;
    WarningCheckModel * _bgCheckModel;
    WarningModel * _dpModel;
    
    BOOL needLocalCheck;
    BOOL locationNotice;
    NSTimer * checkTimer;
}
@property (nonatomic,strong) UIViewController * startVC;
@property (nonatomic,strong) NSArray * dataArr;
@property (nonatomic,strong) UIView * bottomView;
@property (nonatomic,strong) UIAlertView * diaAlert;
@property (nonatomic,strong) CityLocationManager * cityManager;
@property (nonatomic,strong) ZATipsShowController * showTipVC;//控制tips展示
@property (nonatomic,strong) ZAAuthorityController * showAuthorityVC;//控制tips展示

-(void)refreshLocalTimingViewWithCurrentTimingLength:(NSString *)str withAnimated:(BOOL)animated;
@end

@implementation ZAHomeTabBarController

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [checkTimer invalidate];
    checkTimer = nil;
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}
-(id)init
{
    self = [super init];
    if(self)
    {
        self.tabBar.hidden = YES;
//        ZATimingController * time = [[ZATimingController alloc] init];
//        ZAQuickController * quick = [[ZAQuickController alloc] init];
//        self.viewControllers = [NSArray arrayWithObjects:time,quick, nil];

        ZAScrollTimingController * scroll = [[ZAScrollTimingController alloc] init];
        self.viewControllers = [NSArray arrayWithObjects:scroll, nil];
        
        //修改后不再使用
        //监听密码页面返回，响应取消的网络请求发送
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(startWebStateCancelRequest)
//                                                     name:NOTIFICATION_CANCEL_WARNING
//                                                   object:nil];
        
        
        //监听token失效事件
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startLoginUserTokenExpireState)
                                                     name:NOTIFICATION_TOKEN_EXPIRE_STATE
                                                   object:nil];

        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startWebStateAndLocalStateCheck)
                                                     name:NOTIFICATION_START_CHECK_STATE
                                                   object:nil];
        
        //监听结束后的分享页面
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(startShowSharingViewWithNotification:)
//                                                     name:NOTIFICATION_TIMING_SUCCESS_SHARING_STATE
//                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startSettingAddContact)
                                                     name:NOTIFICATION_SETTING_ADD_CONTACT_STATE
                                                   object:nil];
        
    }
    return self;
}
-(CityLocationManager *)cityManager
{
    if(!_cityManager)
    {
        CityLocationManager * manager = [CityLocationManager sharedInstanceManager];
        self.cityManager = manager;
    }
    return _cityManager;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self localTimingModelStateCheck];
    [self checkUserLocationAuthState];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(IOS7_OR_LATER)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    //进行登录状态检查
    [self localLoginStateCheck];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
-(void)refreshLocalTimingViewWithCurrentTimingLength:(NSString *)str withAnimated:(BOOL)animated
{
    NSArray * array = self.dataArr;
    if(!array || [array count]==0) return;
    if(!str || [str length]==0) return;
    
    NSInteger index = NSNotFound;
    index = [array indexOfObject:str];
    
    if(index == NSNotFound) return;
    
    //界面切换，底部状态条切换
    ZABottomScrollTabbar * scrollBar = (ZABottomScrollTabbar *)self.bottomView;
    
    if(index != scrollBar.selectedIndex)
    {
        if(animated)
        {
            scrollBar.delegate = nil;
        }
        [scrollBar tabbarSelectIndex:index withScrollAnimated:animated];
        ZAScrollTimingController * scroll = (ZAScrollTimingController *) self.selectedViewController;
        if(scroll && [scroll respondsToSelector:@selector(scrollContainViewWithTimingString:)])
        {
            [scroll scrollContainViewWithTimingString:str];
        }
        if(animated)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                scrollBar.delegate = self;
            });
        }
    }

}

-(void)startShowSharingViewWithNotification:(NSNotification *)not
{
    NSDate * startDate = (NSDate *)not.object;
    NSTimeInterval totalNum = [startDate timeIntervalSinceNow] * -1;
    [self showSharingViewWithTimeSecondLength:totalNum];
    
}
-(void)showSharingViewWithTimeSecondLength:(NSInteger)length
{
    //默认，秒数
    if(length <0 ) return;
    if(length==0) length = 1;
    NSString * number = [NSString stringWithFormat:@"%ld",(long)length];
    NSString * second = @"秒";

    if(length>60)
    {
        number = [NSString stringWithFormat:@"%ld",(long)length/60];
        second = @"分钟";
    }
    
    if(length>120*60)
    {
        number = [NSString stringWithFormat:@"%ld",(long)length/(60*60)];
        second = @"小时";
    }
    
    
//    ZASharingController * sharing = [[ZASharingController alloc] init];
//    sharing.timeLength = number;
//    sharing.secondLength = second;
//
//    [self.viewDeckController presentViewController:sharing
//                                          animated:YES
//                                        completion:nil];
}

//添加紧急联系人
-(void)startSettingAddContact
{
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
//    if(model.isNeedAddContact)
    {
        //展示登录页面
//        StartZAContactController * pwd = [[StartZAContactController alloc] init];
//        UINavigationController * pwdNa = [[KKNavigationController alloc] initWithRootViewController:pwd];
//        pwdNa.navigationBarHidden = YES;
//        pwdNa.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [self.viewDeckController presentViewController:pwdNa animated:NO completion:nil];
//        return ;
        
        
        
        DPViewController  * vc = (DPViewController *)self.selectedViewController;
        if(!vc)
        {
            return;
        }
    
    
        UINavigationController * mainNa = [vc rootNavigationController];
        if([mainNa isKindOfClass:[UINavigationController class]])
        {
            
            if([model.contacts count] >= [ZA_Contacts_List_Max_Num intValue])
            {
                ZAContactListController * list = [[ZAContactListController alloc] init];
                [mainNa pushViewController:list animated:YES];

//                [DZUtils noticeCustomerWithShowText:@"您的联系人已满，请删除一个后再添加"];
                return;
            }
            
            ZAAddContactController * addContact = [[ZAAddContactController alloc] init];
            [mainNa pushViewController:addContact animated:YES];
        }
        return ;
        
    }
    
}

//状态改变，进行全部检查
-(void)startWebStateAndLocalStateCheck
{
    //登录状态
    [self localLoginStateCheck];
    [self refreshTimingViewCircleAndShowLbl];
    [self localTimingModelStateCheck];
//    [self backgroundWebStateCheck];

    [self startCityLocationCheck];
    [self checkUserLocationAuthState];
}
//进行tips展示检查
-(void)startLocalTipsCheck
{
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(!model.main_Tips_Showed)
    {

        __weak typeof(self) weakSelf = self;
        ZATipsShowController * tip = [[ZATipsShowController alloc] init];
        tip.TapedOnCoverBtnBlock = ^(NSInteger index){
          
            if(index==1)
            {
                model.main_Tips_Showed = YES;
                [model localSave];
                [weakSelf.showTipVC.view removeFromSuperview];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.showTipVC = nil;
                });
                
                [weakSelf startShowAuthorityCheckView];
            }else if(index==0)
            {
                //需要进行跳转
                [weakSelf refreshLocalTimingViewWithCurrentTimingLength:@"30" withAnimated:YES];
            }
            
        };
        
        [self.view addSubview:tip.view];
        self.showTipVC = tip;
    }
}

//城市位置信息检查校验
-(void)startCityLocationCheck
{
    BOOL canSendSMS = [DPViewController canPostMessage];
    if(!canSendSMS) return;
    
    if([CityLocationManager cityLocationNeedRefresh])
    {
        [self.cityManager startCityLocationUpdate];
    }
}

-(void)refreshTimingViewCircleAndShowLbl
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMING_VIEWREFRESH_FORLOCK_STATE
                                                        object:nil];
}
//-(void)restartLocalWarningCircleAnimation
//{
//    //理论上，倒计时启动页面，密码页面，或取消预警页面
//    UINavigationController * pwdNa = (UINavigationController *)self.viewDeckController.presentedViewController;
//
//    //密码，或取消预警页面
//    if([pwdNa isKindOfClass:[UINavigationController class]])
//    {
//        ZAWarnCancelTopVC * warn = (ZAWarnCancelTopVC *)[[pwdNa viewControllers] lastObject];
//        if([warn isKindOfClass:[ZAWarnCancelTopVC class]])
//        {
//            [warn startCircleAnimation];
//        }
//    }
//}

-(void)checkUserLocationAuthState
{
    //切换回来时，进行定位信息的状态检查
    if([ZALocation locationStatusNeverSetting])
    {
        return;
    }
    BOOL locationState = NO;
    if([ZALocation locationStatusEnableInBackground])
    {
        locationState = YES;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_NOTICE_SHOW_STATE
                                                        object:[NSNumber numberWithBool:locationState]];
}

-(void)startLoginUserTokenExpireState
{
    //回收当前已经展示界面
    [self clearCurrentShowControllerView];
    
    //关闭倒计时，关闭本地通知
    [DZUtils localTimeNotificationCancel];
    [TimeRefreshManager stopCurrentAllRefreshManager];
    
    //清空用户数据，重新登录
    [ZALocalStateTotalModel clearLocalStateForLogout];
    
    [self localLoginStateCheck];
}
-(void)clearCurrentShowControllerView
{
    [self hideStartedShowedTipsAndAuthorityView];
    
    
        
    DPViewController  * vc = (DPViewController *)self.selectedViewController;
    UINavigationController * naVC = [vc rootNavigationController];
    UIViewController * controller = nil;
    NSArray * array = [naVC viewControllers];
    if(array && [array count]>0)
    {
        controller  = (UIViewController *) [array lastObject];
    }
//    if([controller isKindOfClass:[ZATimingStartedController class]])
    {
        [controller.navigationController popToRootViewControllerAnimated:NO];
    }
    
    //密码页
    [self.viewDeckController dismissViewControllerAnimated:NO completion:nil];
    
    //设置页
    [self.viewDeckController closeLeftViewAnimated:NO];


}
-(void)hideStartedShowedTipsAndAuthorityView
{//处理既需要展示tips又需要展示预警界面的情况

    ZATipsShowController * tip = self.showTipVC;
    if(tip && tip.TapedOnCoverBtnBlock)
    {
        tip.TapedOnCoverBtnBlock(1);
        
        [self localCheckWarningDataForShowSelectedTimingView];
    }
    
    ZAAuthorityController * auth = self.showAuthorityVC;
    if(auth && auth.TapedOnCloseAuthorityBtnBlock)
    {
        auth.TapedOnCloseAuthorityBtnBlock();
    }
    
    
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    model.main_Tips_Showed = YES;       //有预警，不再展示tips
    model.timer_Tips_Showed = YES;
    model.start_Authority_Showed = YES; //有预警不再权限页，联系人权限页扔展示
    [model localSave];
}
#pragma mark - WebLockStateCheck
-(void)backgroundWebStateCheck
{
    //进行网络状态检查，检查是否黑名单，是否已经解除预警
    //当前仅处理预警状态
    
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    if(!local.isUserLogin) return;
    if(local.loginHideCheck)
    {
        local.loginHideCheck = NO;
        return;
    }
    //目前认为预警状态的解除、APP要比服务器准确，两者差异，以APP为准
    WarningCheckModel * model = (WarningCheckModel *) _bgCheckModel;
    if(!model){
        model = [[WarningCheckModel alloc] init];
        [model addSignalResponder:self];
        _bgCheckModel = model;
    }
    
    //可以考虑此处
    [model sendRequest];
}
#pragma mark - LoginCheck
-(void)localLoginStateCheck
{
    return;
    //本地状态检查，针对无登录的用户弹出登录界面处理
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(!model.start_Introduce_Showed) return;
//    {
//        __weak typeof(self) weakSelf = self;
//        ZAStartScrollController * pwd = [[ZAStartScrollController alloc] init];
//        pwd.StartScrollEndBlock = ^()
//        {
//            ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
//            model.start_Introduce_Showed = YES;
//            [model localSave];
//            
//            [weakSelf.viewDeckController dismissViewControllerAnimated:YES completion:nil];
//        };
//        KKNavigationController * pwdNa = [[KKNavigationController alloc] initWithRootViewController:pwd];
//        pwdNa.canDragBack = NO;
//        pwdNa.navigationBarHidden = YES;
//        pwdNa.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [self.viewDeckController presentViewController:pwdNa animated:NO completion:nil];
//        //        [self.viewDeckController presentViewController:pwd animated:NO completion:nil];
//        //隐藏此处的界面屏蔽，一次弹出两个页面
//        return;
//    }
    
    UIViewController * containVC = self.viewDeckController;
//    if(!containVC)
//    {
//        AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        containVC = appDel.homeCon.viewDeckController;
//    }
    
    if(!model.isUserLogin)
    {
        //展示登录页面
        ZALoginController * pwd = [[ZALoginController alloc] init];
        KKNavigationController * pwdNa = [[KKNavigationController alloc] initWithRootViewController:pwd];
        pwdNa.canDragBack = NO;
        pwdNa.navigationBarHidden = YES;
        pwdNa.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [containVC  presentViewController:pwdNa animated:NO completion:nil];
        
        //进行层叠展示,无登录情况在启动时 此处的弹出，仅为重新登录，超时等情况
//        if(!model.start_Introduce_Showed)
//        {
//            __weak typeof(self) weakSelf = self;
//            ZAStartScrollController * start = [[ZAStartScrollController alloc] init];
//            start.StartScrollEndBlock = ^()
//            {
//                ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
//                model.start_Introduce_Showed = YES;
//                [model localSave];
//                
//                [pwd refreshLoginControllerStateBarForShow];
//                [weakSelf.startVC.view removeFromSuperview];
//                weakSelf.startVC = nil;
//
//            };
//            
//            self.startVC = start;
//            [pwdNa.view addSubview:start.view];
//            //        [self.viewDeckController presentViewController:pwd animated:NO completion:nil];
//            //隐藏此处的界面屏蔽，一次弹出两个页面
//            return;
//        }
        pwd.needRefreshStateBar = YES;

        return ;
    }
    
    if(model.isNeedUpdate)
    {//之前信息未补全
        //展示登录页面
        StartZAUserController * pwd = [[StartZAUserController alloc] init];
        UINavigationController * pwdNa = [[KKNavigationController alloc] initWithRootViewController:pwd];
        pwdNa.navigationBarHidden = YES;
        pwdNa.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [containVC presentViewController:pwdNa animated:NO completion:nil];
        return ;
    }
//    if(model.isNeedAddContact)
//    {
//        //展示登录页面
//        StartZAContactController * pwd = [[StartZAContactController alloc] init];
//        UINavigationController * pwdNa = [[KKNavigationController alloc] initWithRootViewController:pwd];
//        pwdNa.navigationBarHidden = YES;
//        pwdNa.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [self.viewDeckController presentViewController:pwdNa animated:NO completion:nil];
//        return ;
//    }
}

#pragma mark - TimingCheck
-(void)localTimingModelStateCheck
{
    //本地倒计时状态检查
    //无登录，状态无效(退出登录时，清空倒计时状态)
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(!total.isUserLogin) return;
    
    //先进行4天超时的判定，如果已经超过4天，则弹框，不进行本地数据发送
    //刚刚登陆，而状态又是失联4天以上的，则不进行状态检查，
    if([total isNeedDialog] && total.loginHideCheck)
    {
        [self showDialogForUserStateOut];
        return;
    }
    
    if(!locationNotice)
    {
        [self startLocalLocationStateCheck];
    }

    
    //无倒计时编号，本地不需要检查
    if(!total.warningId||[total.warningId length]==0) return;
    
    
    UINavigationController * pwdNa = (UINavigationController *)self.viewDeckController.presentedViewController;
    if(pwdNa) return;
    
    if(total.runErr)
    {
        [self showPasswordViewWithTimerForLocal];
        return;
    }
    
    [self localCheckWarningDataForShowSelectedTimingView];
    
    //弹出界面，真实有效的界面，以本地数据为准
    //启动位置上传
    BOOL showPWD = total.showPWD;
    BOOL endWithPWD = [DZUtils endTimeNeedFinishedPWD];
    if(showPWD||endWithPWD)
    {
//        [self showControllerForPasswordWithTimer:YES];
        [self hideStartedShowedTipsAndAuthorityView];
        [self showWarnCancelViewWithPush];
        return;
    }
    
    //时间计算
    NSTimeInterval lastCount = [DZUtils endTimeSecondNeedContinue];
    if(lastCount>0)
    {
        //内部排重复
        [self hideStartedShowedTipsAndAuthorityView];
        [self showControllerForTimingStartedWithCount:lastCount];
        return;
    }
    
    //关闭可能的本地通知
    [DZUtils localTimeNotificationCancel];
    
}
-(void)localCheckWarningDataForShowSelectedTimingView
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger totalLength = total.totalTime;
    DPViewController  * vc = (DPViewController *)self.selectedViewController;
    if(!vc)
    {
        return;
    }
    
    UINavigationController * mainNa = [vc rootNavigationController];
    ZATimerStartedController * started = nil;
    if([mainNa isKindOfClass:[UINavigationController class]])
    {
        started = [[mainNa viewControllers] lastObject];
    }
    
    if(totalLength>0)
    {
        NSString * resultStr = [NSString stringWithFormat:@"%ld",(long)totalLength];
        if(totalLength == 24*60)
        {
            resultStr = @"none";
        }
        
        [self refreshLocalTimingViewWithCurrentTimingLength:resultStr withAnimated:NO];
        
    }
}


#pragma mark - LocationCheck
-(void)startLocalLocationStateCheck
{
    return;
    locationNotice = YES;
    //定位功能首次启动的提示检查
    ZALocation * locationInstance = [ZALocation sharedInstance];
    __weak typeof(self)  weakSelf = self;
    if([ZALocation locationStatusNeverSetting])
    {
        [locationInstance startLocationRequestUserAuthorization];
        [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *str)
         {
             [weakSelf checkUpCurrentLocationWithString:[str description]];
         }];
        
    }
}
-(void)startAddressListAddContact
{
    NSLog(@"%s",__FUNCTION__);
    if([ZAAddressController addressBookAuthNeverStarted])
    {
         [ZAAddressController addContactToUserAddressList];
    }
}


-(void)checkUpCurrentLocationWithString:(NSString *)str
{
    [self startCityLocationCheck];
//    [self startAddressListAddContact];
    
    ZALocation * locationInstance = [ZALocation sharedInstance];
    [locationInstance stopUpdateLocation];
}

#pragma mark - PrivateMethods
//仅登陆时提示一次，或状态检查
-(void)showDialogForUserStateOut
{
    if(!self.diaAlert)
    {
        NSString * log = @"您回来真好~上次触发的预警已处理完毕，请您重新开启防护。";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:log
                                                        delegate:self
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil, nil];
        self.diaAlert = alert;
    }
    [self.diaAlert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //进行首次的定位功能启动提示
    if(!locationNotice)
    {
        [self startLocalLocationStateCheck];
    }
}

-(void)startShowAuthorityCheckView
{
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(!model.main_Tips_Showed)
    {//未展示tips之前，不展示权限页
        return;
    }
    
    if(!model.start_Authority_Showed)
    {
        model.start_Authority_Showed = YES;
        [model localSave];
        
        __weak typeof(self) weakSelf = self;
        ZAAuthorityController * tip = [[ZAAuthorityController alloc] init];
        tip.type = ZAAuthorityCheckType_Main;
        tip.TapedOnCloseAuthorityBtnBlock = ^()
        {
            [weakSelf lew_dismissPopupView];
            [weakSelf.showAuthorityVC.view removeFromSuperview];
            weakSelf.showAuthorityVC = nil;
        };
        [self.view addSubview:tip.view];
        self.showAuthorityVC = tip;
        [tip refreshCurrentAuthority];
        
        UIView * view = tip.view;
        [self lew_presentPopupView:view animation:[LewPopupViewAnimationFade new] dismissed:nil];
    }
}

-(void)showControllerForTimingStartedWithCount:(NSTimeInterval)count
{
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger totalLength = total.totalTime;
    ZATimerStartedController * start = [[ZATimerStartedController alloc] init];
    start.totalTimingNum = totalLength * 60 ;
    start.timingNum = count;
    start.doStr = total.timeModel.whattodo;
    
    [self setSelectedIndex:0];
    DPViewController  * vc = (DPViewController *)self.selectedViewController;
    if(!vc)
    {
        return;
    }
    
    UINavigationController * mainNa = [vc rootNavigationController];
    ZATimerStartedController * started = nil;
    if([mainNa isKindOfClass:[UINavigationController class]])
    {
        started = [[mainNa viewControllers] lastObject];
    }
    
    
    if(![started isKindOfClass:[ZATimerStartedController class]] && ![started isKindOfClass:[ZAShareLocationController class]] && ![started isKindOfClass:[ZAAddSomethingController class]])
    {
        [mainNa pushViewController:start animated:NO];
    }
    
//    WarnTimingModel * local = total.timeModel;
    {
        //倒计时未完成
        LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
        manager.scene = @"1";
        manager.priority = @"0";
        [manager refreshRefreshTimeWithNormalPriority];
    }
}
-(void)showControllerForPasswordWithTimer:(BOOL)show
{
//    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//    WarnTimingModel * local = total.timeModel;
    {
        LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
//        manager.scene = local.scene;
        manager.priority = @"3";
        [manager refreshRefreshTimeWithHeighPriority];
    }
    
    
    //展示
    __weak typeof(self) weakSelf = self;
    
    ZAPasswordController * pwd = [[ZAPasswordController alloc] init];
    UINavigationController * pwdNa = [[UINavigationController alloc] initWithRootViewController:pwd];
    pwdNa.navigationBarHidden = YES;
    pwd.PWDCheckSuccessBlock = ^(PWDCheckFinishType type)
    {
        [weakSelf.viewDeckController dismissViewControllerAnimated:YES completion:nil];
    };
    
    
    //        ZAWarnCancelTopVC * warn = [[ZAWarnCancelTopVC alloc] init];
    //        [pwdNa pushViewController:warn animated:NO];
    //        warn.TapedCancelWarnBlock = ^()
    //        {
    //            [pwd.navigationController popViewControllerAnimated:YES];
    //            [pwd restartPWDTimerRefresh];
    //        };
    BOOL endWithPWD = [DZUtils endTimeNeedFinishedPWD];
    if(endWithPWD)
    {
        pwd.timeEndState = YES;
    }
    pwd.needTimer = show;
    [self.viewDeckController presentViewController:pwdNa animated:YES completion:nil];
}
-(void)showPasswordViewWithTimerForLocal
{
    __weak typeof(self)  weakSelf = self;
    ZAPasswordController * pwd = [[ZAPasswordController alloc] init];
    pwd.needTimer = YES;
    UINavigationController * pwdNa = [[UINavigationController alloc] initWithRootViewController:pwd];
    pwdNa.navigationBarHidden = YES;
    pwd.PWDCheckSuccessBlock = ^(PWDCheckFinishType type)
    {
        [weakSelf.viewDeckController dismissViewControllerAnimated:YES completion:nil];
    };
    [self.viewDeckController presentViewController:pwdNa animated:YES completion:nil];
}


-(void)showWarnCancelViewWithPush
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];

    __weak typeof(self) weakSelf = self;
    
    ZAPasswordController * pwd = [[ZAPasswordController alloc] init];
    pwd.PWDCheckSuccessBlock = ^(PWDCheckFinishType type)
    {
        
        UIViewController * controller = weakSelf.viewDeckController;
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    pwd.showBack = YES;
    
    BOOL redTop = NO;
    
    NSDate * date = total.noticeDate;
    if(date && [date timeIntervalSinceNow]>1)
    {
        redTop = YES;
    }
    
    ZAWarnCancelTopVC * warn = [[ZAWarnCancelTopVC alloc] init];
    if(redTop)
    {
        warn.showRedTop = YES;
        warn.changeDate = date;
    }
    UINavigationController * pwdNa = [[UINavigationController alloc] initWithRootViewController:warn];
    pwdNa.navigationBarHidden = YES;
    warn.TapedCancelWarnBlock = ^()
    {
        [pwdNa pushViewController:pwd animated:YES];
        //        [pwd restartPWDTimerRefresh];
        [pwd stopPWDTimerAndHiddenLbl];
    };
    
    [self.viewDeckController presentViewController:pwdNa animated:YES completion:nil];
    
    WarnTimingModel * local = total.timeModel;
    {
        //倒计时未完成
        LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
        if(local.scene && [local.scene length]>0)
        {
             manager.scene = local.scene;
        }
        manager.priority = @"0";
        [manager refreshRefreshTimeWithNormalPriority];
    }
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

#pragma mark --
#pragma mark WarningCheckModel
handleSignal( WarningCheckModel, requestError )
{
    //    [self hideLoading];
    //    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( WarningCheckModel, requestLoading )
{
    //    [self showLoading];
}

handleSignal( WarningCheckModel, requestLoaded )
{
    //使用内含的登陆超时功能
    BOOL result = [DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:nil];
    if(!result) return;
    
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    PaPaUserInfoModel * model = (PaPaUserInfoModel *)[_bgCheckModel warnModel] ;
    
    NSString * lockStr = model.lock;
    BOOL state = [model userTimingOutOfControlForState];
    
    if (!lockStr||[lockStr intValue]==0 || state)
    {
        
        //当本地有预警时清空
        if(local.warningId && [local.warningId length]>0)
        {
            [self clearCurrentShowControllerView];
            [DZUtils localTimeNotificationCancel];
            [TimeRefreshManager stopCurrentAllRefreshManager];
        }

//        UINavigationController * pwdNa = (UINavigationController *)self.viewDeckController.presentedViewController;
//        
//        //能够解除
//        if([pwdNa isKindOfClass:[UINavigationController class]])
//        {
//            ZAPasswordController * pwd = (ZAPasswordController *)[pwdNa.viewControllers firstObject];
//            if(pwd&&[pwd isKindOfClass:[ZAPasswordController class]])
//            {
//                //关闭可能的本地通知
//                [DZUtils localTimeNotificationCancel];
//                
//                //预警解除，关闭数据上传
//                [[LocationTimeRefreshManager sharedInstance] endAutoRefreshAndClearTime];
//                
//                //倒计时结束，关闭
//                [[PWDTimeManager sharedInstance] endAutoRefreshAndClearTime];
//                
//                
//                pwd.PWDCheckSuccessBlock(PWDCheckFinishType_PWD);
//            }
//        }
//        
//        
//        //关闭可能的倒计时页面
//        UINavigationController * naCon = self.navigationController;
//        DPViewController * dp =  (DPViewController *)naCon.visibleViewController;
//        if(dp&&[dp isKindOfClass:[ZATimerStartedController class]])
//        {
//            //关闭倒计时
//            [DZUtils localTimeNotificationCancel];
//            [[LocationTimeRefreshManager sharedInstance] endAutoRefreshAndClearTime];
//            [[LocalTimingRefreshManager sharedInstance] endAutoRefreshAndClearTime];
//            
//            [naCon popToRootViewControllerAnimated:YES];
//        }
        
        //清空本地数据
        local.endDate = nil;
        local.totalTime = 0;
        local.showPWD = NO;
        local.timeModel = nil;
        [local localSave];
        
        if (state)
        {
            [self showDialogForUserStateOut];
        }
        
    }else if([lockStr integerValue]==1)
    {
        //检查预警，服务器有预警，本地无预警，针对本地有预警数据的情况，交给localTimingModelStateCheck处理
        
        //无预警，仅指无warningid
        //本地预警启动失败，服务器返回预警为1，标识状态为启动超时(客户端失败、服务器成功)
        if(!local.warningId||[local.warningId length]==0)
        {
            //紧急模式超时
            BOOL showPWD = local.showPWD;//有限展示取消预警页面
            BOOL endWithPWD = [DZUtils endTimeNeedFinishedPWD];
            if(showPWD||endWithPWD)
            {
                //倒计时模式不展示，应急模式展示
                //                [self showControllerForPasswordWithTimer:YES];
                [self showWarnCancelViewWithPush];
                return;
            }
            
            //倒计时超时
            NSTimeInterval lastCount = [DZUtils endTimeSecondNeedContinue];
            if(lastCount>0 )
            {
                [DZUtils localTimeNotificationAppendedWithTimeLength:lastCount];
                [self showControllerForTimingStartedWithCount:lastCount];
                return;
            }
            
            
            //此时，可能的情况是  服务器锁定
//            [self showControllerForPasswordWithTimer:YES];
            [self showWarnCancelViewWithPush];
            
        }
        
        
    }
    _bgCheckModel = nil;
}
#pragma mark -


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataArr = [NSArray arrayWithObjects:@"none",@"10",@"30",@"60",@"90",@"120",nil];

    
    for (UIView *transitionView in self.view.subviews) {
        if ([transitionView isKindOfClass:NSClassFromString(@"UITransitionView")])
        {
            NSLog(@"%s reset transitionView frame",__FUNCTION__);
            transitionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - ZA_TABBAR_HEIGHT);
        }
    }
    
    CGRect rect = self.bottomView.frame;
    
    UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
    img.image = [UIImage imageNamed:@"white_scroll_bg"];
    [self.view addSubview:img];
    
    [self.view addSubview:self.bottomView];
//    [self setBottomTabBarEnable:YES];
    


    //将统一检查的本地倒计时model检查，移动到viewDidAppear
//    [self localLoginStateCheck];
//    [self backgroundWebStateCheck];
    [self startCityLocationCheck];
    [self startLocalTipsCheck];    //展示tips
    [self startShowAuthorityCheckView];
}

-(UIView *)bottomView
{
    if(!_bottomView)
    {
        ZABottomScrollTabbar * tabbar = [[ZABottomScrollTabbar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - ZA_TABBAR_HEIGHT, SCREEN_WIDTH, ZA_TABBAR_HEIGHT)];
        ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
        tabbar.startedIndex = model.main_Tips_Showed? 2:0;
        tabbar.dataSource = self;
        tabbar.delegate = self;
        _bottomView = tabbar;
        [tabbar refreshTabbar];
    }
    return _bottomView;
}
-(UIView *)tabbarCoverView
{
    CGFloat length = FLoatChange(50);
    CGRect rect = CGRectMake(0, 0, length, ZA_TABBAR_HEIGHT);
    ZATabbarItemView * item = [[ZATabbarItemView alloc] initWithFrame:rect];
    return item;
}
#pragma mark - ZABottomScrollTabbarDelagete
-(void)zaBottomScrollTabbar:(ZABottomScrollTabbar *)tabbar didSelectedIndex:(NSInteger)index
{
//    NSLog(@"%s %ld",__FUNCTION__,(long)index);
    NSString * str = nil;
    if([self.dataArr count]>index)
    {
         str = [self.dataArr objectAtIndex:index];
    }
    ZAScrollTimingController * scroll = (ZAScrollTimingController *) self.selectedViewController;
    if([scroll respondsToSelector:@selector(scrollContainViewWithTimingString:)])
    {
        [scroll scrollContainViewWithTimingString:str];
    }

    
}
-(void)zaBottomScrollTabbar:(ZABottomScrollTabbar *)tabbar scrollviewWillChangeFrom:(NSInteger)startIndex ToIndex:(NSInteger)endIndex andScrollPersent:(CGFloat)persent
{
//    NSLog(@"%s %f %ld %ld",__FUNCTION__,persent,(long)startIndex,(long)endIndex);

}
#pragma mark -
#pragma mark - ZABottomScrollTabbarDataSource
-(NSInteger)numberOfTabbarViewForZABottomScrollTabbar:(ZABottomScrollTabbar *)tabbar{
    return [self.dataArr count];
}

-(UIView *)zaBottomScrollTabbar:(ZABottomScrollTabbar *)tabbar customViewForTabbarIndex:(NSInteger)index
{
    ZATabbarItemView * cover = (ZATabbarItemView *)[self tabbarCoverView];
    cover.imgView.hidden = YES;
    cover.bottomLbl.text = @"分钟";

    if(index==0)
    {
        cover.imgView.image = [UIImage imageNamed:@"quick_state_icon"];
        cover.imgView.hidden = NO;
        cover.topLbl.hidden = YES;
        cover.bottomLbl.text = @"应急";
    }
    NSString * str = nil;
    if([self.dataArr count]>index)
    {
        str = [self.dataArr objectAtIndex:index];
    }
    cover.topLbl.text = str;
    [cover refreshTransformForPersent:0];
    return cover;
}
-(UIView *)zaBottomScrollTabbar:(ZABottomScrollTabbar *)tabbar selectedViewForTabbarIndex:(NSInteger)index
{
    ZATabbarItemView * cover = (ZATabbarItemView *)[self tabbarCoverView];
    cover.imgView.hidden = YES;
    cover.bottomLbl.text = @"分钟";
    if(index==0)
    {
        cover.imgView.image = [UIImage imageNamed:@"quick_state_icon"];
        cover.imgView.hidden = NO;
        cover.topLbl.hidden = YES;
        cover.bottomLbl.text = @"应急";
    }
    NSString * str = nil;
    if([self.dataArr count]>index)
    {
        str = [self.dataArr objectAtIndex:index];
    }
    cover.topLbl.text = str;
    [cover refreshTransformForPersent:1];
    
    return cover;
}


#pragma mark -

-(void)moveDarkLineToIndex:(NSInteger)index
{
    CGRect rect = darkLine.frame;;
    rect.origin.x = index * rect.size.width;
    darkLine.frame = rect;
}

-(void)refreshSelectedButtonIndex:(NSInteger)tag
{
    //按钮刷新
    NSInteger preIndex = self.selectedIndex;
    UIButton * preBtn = (UIButton *)[self.view viewWithTag:preIndex + ZA_TABBAR_BUTTON_ADDTAG];
    preBtn.selected = NO;
    preBtn.userInteractionEnabled = YES;
    
    UIButton * currentBtn = (UIButton *)[self.view viewWithTag:tag + ZA_TABBAR_BUTTON_ADDTAG];
    currentBtn.selected = YES;
    currentBtn.userInteractionEnabled = NO;
    
    //控制选中线位置
    [self moveDarkLineToIndex:tag];
    
}

-(void)tapedOnBottomBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger tag = btn.tag - ZA_TABBAR_BUTTON_ADDTAG;
//    if(self.selectedIndex==tag) return;
    [self refreshSelectedButtonIndex:tag];
    self.selectedIndex = tag;
}

-(void)closeTabbarControllerCoverBtn
{
    for (UIViewController * eve in self.viewControllers)
    {
        DPViewController * dp = (DPViewController *)eve;
        UIButton * btn = [dp coverBtn];
        btn.hidden = YES;
    }
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
