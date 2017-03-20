//
//  AppDelegate.m
//  ZAIOSMainPrj
//
//  Created by zhangchaoqun on 15/4/29.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//
//for mac
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

//for idfa
#import <AdSupport/AdSupport.h>

#import "AppDelegate.h"
#import "MainTestActivity.h"
#import "MainAppActivity.h"
#import "WebActivity.h"
#import "MobClick.h"
#import "MSAlertController.h"
#import "BlockAlertView.h"
#import "BPush.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeixinShare.h"
#import "QQSpaceShare.h"
#import "ZACrashReporter.h"
#import "SFHFKeychainUtils.h"
#import "KKNavigationController.h"
#import "ZASettingController.h"
#import "IIViewDeckController.h"
#import "ZAHomeTabBarController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "pinyin.h"
#import "PinYinForObjc.h"
#import "ZAContactListController.h"
#import "ZAPWDEditController.h"
#import "ZAUserEditController.h"
#import "ZAStartUserController.h"
#import "ZATimerStartedController.h"
#import "ZALocation.h"
#import "ZAWKConnectDelegate.h"
#import "WWSideslipViewController.h"
#import "ZAWebNoticeController.h"
#import "ZAStartScrollController.h"
#import "ZALoginController.h"
#import "UMFeedback.h"
#import "UMCheckUpdate.h"
#import "UMOnlineConfig.h"
#import "ZARecorderManager.h"
#import "Constant.h"
#import "ZAAuthorityController.h"
#import "ZWBGRefreshManager.h"
#import <EventKit/EventKit.h>
#import "ZALocalNotificationManager.h"
#import "ZWDataDetailModel.h"
#import "JSONKit.h"
#define ZAUpdateNoticeRefreshTimeInterval  (24*60*60)//消息的刷新提醒时间
//最近一次的token刷新
#define USERDEFAULT_UPLDATE_TIME_UPDATE_NOTICE_REFRESH  @"USERDEFAULT_UPLDATE_TIME_UPDATE_NOTICE_REFRESH"

@interface AppDelegate () <UISplitViewControllerDelegate,IIViewDeckControllerDelegate>{
    BOOL showLeft;
    ZAWKConnectDelegate * connect;
    BaseRequestModel * _startModel;
}
@property (retain, nonatomic) NSDictionary *pushInfoDictionary;//推送的信息

@property (nonatomic,strong) KKNavigationController * rootNa;
@property (nonatomic,strong) ZAStartScrollController * startVC;
@property (nonatomic,strong) UIAlertView * diaAlert;
@property (nonatomic,strong) NSDictionary * updateDic;
@end

@implementation AppDelegate

- (void)writeLogToFile
{
    NSString *fileName =[NSString stringWithFormat:@"%@.log",[[NSDate date] description]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderDirectory = [documentsDirectory stringByAppendingPathComponent:@"ZALogs"];
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError* error;
    if (![fm fileExistsAtPath:folderDirectory]){//不存在则重新创建
        if([fm createDirectoryAtPath:folderDirectory withIntermediateDirectories:NO attributes:nil error:&error])
        {
            
        }
        else
        {
            NSLog(@"Failed to create directory %@,error:%@",folderDirectory,error);
        }
    }
    NSString *logFilePath = [folderDirectory stringByAppendingPathComponent:fileName];
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

-(void)refreshWindowRootViewController
{
    self.window.rootViewController = self.rootNa;
    [self.window makeKeyAndVisible];
    
    //增加顶部状态栏界面的判定
    [self refreshTopNoticeErrView];
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"%s %@",__FUNCTION__,notification);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
//    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
//    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
//    splitViewController.delegate = self;个
    
    NSLog(@"%s,%@",__FUNCTION__,launchOptions);
    
//    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    showLeft = NO;
#if DEBUG
#else

#if kAPP_Local_LOG_Identifier_TAG
    [self writeLogToFile];
#endif
    
#endif
        
//    [DZUtils localSoundTimeNotificationWithAfterSecond];
//    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
//    local.warningId = @"ddd";
//    [local localSave];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.cityDate = nil;
//    total.contactRed_Need_Show = YES;
    [total localSave];
    

    
    [self setAdapter];
    connect = [[ZAWKConnectDelegate alloc] init];
    
    
    [[ZACrashReporter sharedInstance] checkCrashLog];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
//    [ZWDataDetailModel startRateTest];
//    [ZWDataDetailModel startDetailManagerTest];

    NSLog(@"%s %@",__FUNCTION__,[[NSBundle mainBundle] bundleIdentifier]);
    UIViewController * main = nil;
//    main = [[MainTestActivity alloc] init];
//    main = [[MainAppActivity alloc] init];
    main = [[ZAHomeTabBarController alloc] init];
    self.homeCon = (ZAHomeTabBarController *)main;
//    main = [[UIViewController alloc] init];
    
//    naCon.interactivePopGestureRecognizer.enabled = YES;
//    naCon.navigationBarHidden = YES;
    
    ZASettingController * setting = [[ZASettingController alloc] init];
    
    IIViewDeckController * controller = [[IIViewDeckController alloc] initWithCenterViewController:main leftViewController:setting];
    controller.panningCancelsTouchesInView = NO;
    controller.shadowEnabled = NO;
    controller.panningMode = IIViewDeckPanningViewPanning;
    controller.leftSize = 0.4 * SCREEN_WIDTH;
    controller.delegate = self;
    controller.navigationControllerBehavior = IIViewDeckNavigationControllerContained;
    
//    WWSideslipViewController * controller = [[WWSideslipViewController alloc] initWithLeftView:setting
//                                                                                   andMainView:main
//                                                                                  andRightView:nil
//                                                                            andBackgroundImage:[UIImage imageNamed:@"LaunchImage"]];

    KKNavigationController * naCon = [[KKNavigationController alloc] initWithRootViewController:controller];
    naCon.delegate = self;
    
    self.rootNa = naCon;

    
    //直接展示引导页面
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    //进行层叠展示
    if(!model.isUserLogin && NO)
    {
        //展示登录页面
        ZALoginController * pwd = [[ZALoginController alloc] init];
        KKNavigationController * pwdNa = [[KKNavigationController alloc] initWithRootViewController:pwd];
        pwdNa.canDragBack = NO;
        pwdNa.navigationBarHidden = YES;
        pwdNa.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        pwd.needRefreshStateBar = YES;
        //进行层叠展示
        if(!model.start_Introduce_Showed)
        {
            pwd.needRefreshStateBar = NO;
            pwd.kmNoneAppear = YES;
            __weak typeof(self) weakSelf = self;
            ZAStartScrollController * start = [[ZAStartScrollController alloc] init];
            start.StartScrollEndBlock = ^()
            {
                ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
                model.start_Introduce_Showed = YES;
                
                pwd.kmNoneAppear = NO;
                model.kmVCNameString = [pwd classNameForKMRecord];
                
                [model localSave];
                
                [pwd refreshLoginControllerStateBarForShow];
                [weakSelf.startVC.view removeFromSuperview];
                weakSelf.startVC = nil;
                
            };
            
            self.startVC = start;
            [pwdNa.view addSubview:start.view];
            //        [self.viewDeckController presentViewController:pwd animated:NO completion:nil];
            //隐藏此处的界面屏蔽，一次弹出两个页面
            
        }
        
        self.window.rootViewController = pwdNa;
        [self.window makeKeyAndVisible];
    }else
    {
        self.window.rootViewController = naCon;
        [self.window makeKeyAndVisible];
    }
    
//    [self createNewEventAndNewReminder];
    [self refreshTopNoticeErrView];
    
//    [self startedConnectLogRequest];
//    [self initUMeng];
    [KMStatis staticApplicationEvent:StaticApplicationEventType_Start];
    
//    [self initBPush:launchOptions];

    
    [self performSelector:@selector(startNetCheck) withObject:nil afterDelay:0.3];
    
//    Class cls = NSClassFromString(@"UMANUtil");
//    SEL deviceIDSelector = @selector(openUDIDString);
//    NSString *deviceID = nil;
//    if(cls && [cls respondsToSelector:deviceIDSelector]){
//        deviceID = [cls performSelector:deviceIDSelector];
//    }
//    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"oid" : deviceID}
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:nil];
//    
//    
//    NSLog(@"UMANUtil %@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    NSString * storeId = [SFHFKeychainUtils commonStaticAppDeviceId];
    NSString * toolId = [DZUtils currentDeviceIdentifer];
    NSLog(@"commonStaticAppDeviceId %@ %@ %@",storeId,toolId,[DZUtils platformString]);
    NSLog(@"commonStaticAppDeviceId %@ V%@",ZAViewLocalizedStringForKey(@"ZAViewLocal_Login_Title"),[DZUtils currentAppBundleVersion]);
    [[NSUserDefaults standardUserDefaults] setValue:storeId forKey:NSUSERDEFAULT_CHECK_DEVICEID_IDENTIFIER];
    
    //取出内含的，添加到NSUserDefaults
    storeId = [SFHFKeychainUtils getKeyStringFromUtilsWithKeyString:NSUSERDEFAULT_ADDRESS_RECORD_IDENTIFIER];
    [[NSUserDefaults standardUserDefaults] setValue:storeId forKey:NSUSERDEFAULT_ADDRESS_RECORD_IDENTIFIER];

//    [[ZALocalNotificationManager sharedInstance] startBackgroundTimerWakeUp];
    [[ZALocalNotificationManager sharedInstance] cancelLocalNotificationWithType:ZALocalNotificationType_RemindNotice];
    
    [WXApi registerApp:kWXAPP_URL_KEY withDescription:@"ZAIOSMainPrj 1.0.0"];

     application.applicationIconBadgeNumber = 0;
    
    return YES;
}
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UIBackgroundRefreshStatus state = [[UIApplication sharedApplication] backgroundRefreshStatus];
    if(state != UIBackgroundRefreshStatusAvailable){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:@"您还没有开启后台刷新"
                                                        delegate:nil
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles: nil];
        [alert show];
        return;
    }
    //刷新操作
    [[ZWBGRefreshManager sharedInstance] startZWBGRefreshWithFinishBlock:completionHandler];
}

-(void)refreshTopNoticeErrView
{
    ZAWebNoticeController * web = [[ZAWebNoticeController alloc] init];
    self.webNotice = web;
    UIView * aView = web.view;
    CGRect rect = aView.frame;
    rect.origin.y = kTop;
    aView.frame = rect;
    [self.window addSubview:aView];
}

-(void)startNetCheck
{

    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //发送消息通知
        BOOL webState = YES;
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                webState = NO;
                break;
            default:
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WEBCHECK_NOTICE_SHOW_STATE
                                                            object:[NSNumber numberWithBool:webState]];
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
- (void)viewDeckController:(IIViewDeckController*)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated
{
    if(viewDeckSide == IIViewDeckLeftSide)
    {
        //当打开左侧时,覆盖右侧部分的coverbtn
        DPViewController * dp = (DPViewController *)[self.homeCon selectedViewController];
        dp.coverBtn.hidden = NO;
    }
}
- (void)viewDeckController:(IIViewDeckController*)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated{
    
    //设置隐藏
    UINavigationController * naCon = (UINavigationController *)viewDeckController.navigationController;
    DPViewController * viewCon =(DPViewController *) naCon.visibleViewController;
    if([viewCon isKindOfClass:[IIViewDeckController class]])
    {
        DPViewController * dp = (DPViewController *)[(IIViewDeckController *)viewCon centerController];
        viewCon = dp;
    }
    
    if([viewCon isKindOfClass:[ZAHomeTabBarController class]])
    {
        
//        [(ZAHomeTabBarController *)viewCon closeTabbarControllerCoverBtn];
        
        DPViewController * dp = (DPViewController *)[(ZAHomeTabBarController *)viewCon selectedViewController];
        [dp refreshDragBackEnable:NO];
        dp.coverBtn.hidden = YES;

    }else  if([viewCon isKindOfClass:[DPViewController class]])
    {
        [viewCon refreshDragBackEnable:YES];
        viewCon.coverBtn.hidden = YES;
    }

    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.kmVCNameString = @"ZAScrollTimingController_close";
    
}

                    

#pragma mark - BPush相关
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"----->>>>>>>openUrl=%@",[url absoluteString]);
    NSString *urlString=[url absoluteString];
    if ([urlString hasPrefix:@"onlyladyguimiappwx"]) {//如果是微信分享内容的点击，跳过来
        NSString *decodeUrlString=[urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"-->>%@",decodeUrlString);
        NSRange startRange=[decodeUrlString rangeOfString:@"td="];
        if (startRange.length!=0) {
            NSString *uid=[decodeUrlString substringFromIndex:startRange.location+startRange.length];
            NSMutableDictionary *mutableDictionary=[[NSMutableDictionary alloc]initWithCapacity:2];
            [mutableDictionary setObject:uid forKey:@"id"];
            [mutableDictionary setObject:@"1" forKey:@"type"];
            self.pushInfoDictionary=mutableDictionary;
            NSLog(@"--->>the uid=%@",uid);
        }else{
            startRange=[decodeUrlString rangeOfString:@"pd="];
            if (startRange.length!=0) {
                NSString *uid=[decodeUrlString substringFromIndex:startRange.location+startRange.length];
                NSMutableDictionary *mutableDictionary=[[NSMutableDictionary alloc]initWithCapacity:2];
                [mutableDictionary setObject:uid forKey:@"id"];
                [mutableDictionary setObject:@"0" forKey:@"type"];
                self.pushInfoDictionary=mutableDictionary;
                NSLog(@"--->>the uid=%@",uid);
            }
        }
        return true;
    }
    else if([urlString hasPrefix:kWXAPP_URL_KEY]){
        [KMStatis staticApplicationEvent:StaticApplicationEventType_URLOpen_WX];
        return [WXApi handleOpenURL:url delegate:[WeixinShare shareWeixin]];}
    //    else if([urlString hasPrefix:@"sinaweibosso.2444705848"]){
    //        return [[SinaWeiboShare shareWeibo].sinaweibo handleOpenURL:url];}
    else if([urlString hasPrefix:kQQAPP_URL_KEY]){
    //方法调用
        [KMStatis staticApplicationEvent:StaticApplicationEventType_URLOpen_QQ];
        BOOL result = [TencentOAuth HandleOpenURL:url];
        NSInteger num = [DZUtils checkErrorCodeWithBackUrlString:urlString];
        [[QQSpaceShare shareQQSpace] currentBackToAppFromQQWithErrorCode:num];
        return result;
    }
    
    return NO;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"----->>>>>>>openUrl=%@",[url absoluteString]);
    NSString *urlString=[url absoluteString];
    if ([urlString hasPrefix:@"onlyladyguimiappwx"]) {//如果是微信分享内容的点击，跳过来
        NSString *decodeUrlString=[urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"-->>%@",decodeUrlString);
        NSRange startRange=[decodeUrlString rangeOfString:@"td="];
        if (startRange.length!=0) {
            NSString *uid=[decodeUrlString substringFromIndex:startRange.location+startRange.length];
            NSMutableDictionary *mutableDictionary=[[NSMutableDictionary alloc]initWithCapacity:2];
            [mutableDictionary setObject:uid forKey:@"id"];
            [mutableDictionary setObject:@"1" forKey:@"type"];
            self.pushInfoDictionary=mutableDictionary;
            NSLog(@"--->>the uid=%@",uid);
        }else{
            startRange=[decodeUrlString rangeOfString:@"pd="];
            if (startRange.length!=0) {
                NSString *uid=[decodeUrlString substringFromIndex:startRange.location+startRange.length];
                NSMutableDictionary *mutableDictionary=[[NSMutableDictionary alloc]initWithCapacity:2];
                [mutableDictionary setObject:uid forKey:@"id"];
                [mutableDictionary setObject:@"0" forKey:@"type"];
                self.pushInfoDictionary=mutableDictionary;
                NSLog(@"--->>the uid=%@",uid);
            }
        }
        return true;
    }
    else if([urlString hasPrefix:kWXAPP_URL_KEY]){
        [KMStatis staticApplicationEvent:StaticApplicationEventType_URLOpen_WX];
        return [WXApi handleOpenURL:url delegate:[WeixinShare shareWeixin]];}
//    else if([urlString hasPrefix:@"sinaweibosso.2444705848"]){
//        return [[SinaWeiboShare shareWeibo].sinaweibo handleOpenURL:url];}
    else if([urlString hasPrefix:kQQAPP_URL_KEY]){
        [KMStatis staticApplicationEvent:StaticApplicationEventType_URLOpen_QQ];
        BOOL result = [TencentOAuth HandleOpenURL:url];
        NSInteger num = [DZUtils checkErrorCodeWithBackUrlString:urlString];
        [[QQSpaceShare shareQQSpace] currentBackToAppFromQQWithErrorCode:num];
        
        return result;
    }

    return NO;
}
-(void)initBPush:(NSDictionary *)startDic
{
    //百度推动appKey：lj51z6LkFi8yIKMLGpUpxeKo
    NSString *bconfigPath=[[NSBundle mainBundle]pathForResource:@"BPushConfig" ofType:@"plist"];
    NSDictionary *dictionary=[[NSDictionary alloc]initWithContentsOfFile:bconfigPath];
    
    //推送通知
    if (startDic)
    {//检查是否是打开推送进来的
        NSDictionary* pushNotificationKey = [startDic objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushNotificationKey)
        {
            self.pushInfoDictionary=[pushNotificationKey objectForKey:@"aps"];
        }
    }
    
    //dictionary里面取出apikey
    BPushMode pushMode = BPushModeProduction;
#if DEBUG
    pushMode = BPushModeDevelopment;
#endif

    
#ifdef kAPP_BPush_Company_Identifier
    //企业版证书
    [BPush registerChannel:startDic apiKey:dictionary[@"API_KEY"] pushMode:pushMode withFirstAction:nil withSecondAction:nil withCategory:nil isDebug:NO];
#else
    //个人版证书
    [BPush registerChannel:startDic apiKey:@"sanMBYMHBUVsWKaOcx3m4IFU" pushMode:pushMode withFirstAction:nil withSecondAction:nil withCategory:nil isDebug:NO];
#endif

//    //个人账号发布证书
    
    //百度推送
    //    [BPush setupChannel:startDic]; // 必须
//    [BPush setDelegate:self];
    // 必须。参数对象必须实现onMethod: response:方法，本示例中为self
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //此通知，对于删除后重新安装的用户可能不准
    [[NSNotificationCenter defaultCenter] postNotificationName:NSRemote_NOTIFICATION_IDENTIFIER_REGISTER
                                                        object:[NSNumber numberWithBool:YES]];

    NSString *tokenString=[NSString stringWithFormat:@"%@",deviceToken];
    tokenString=[tokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    tokenString=[tokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
    tokenString=[tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    self.pushToken=tokenString;
    @autoreleasepool {
        [BPush registerDeviceToken:deviceToken]; // 必须
        // [BPush setAccessToken:self.pushToken];
        [BPush bindChannelWithCompleteHandler:nil]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
        [BPush setTag:[DZUtils currentDeviceIdentifer] withCompleteHandler:nil];
        
        NSLog(@"get push token:%@",tokenString);

    }
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSRemote_NOTIFICATION_IDENTIFIER_REGISTER
                                                        object:[NSNumber numberWithBool:NO]];
    NSLog(@"register push error:%@",error);
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
     application.applicationIconBadgeNumber = 0;
    
    [BPush handleNotification:userInfo]; // 可选
    self.pushInfoDictionary=[userInfo objectForKey:@"aps"];
    NSLog(@"userInfo-->>%@", userInfo);
}

// 必须，如果正确调用了setDelegate，在bindChannel之后，结果在这个回调中返回。
// 若绑定失败，请进行重新绑定，确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data
{
    
//    if ([BPushRequestMethod_Bind isEqualToString:method])
    {
        NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
        
        //        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSLog(@"%@",userid);
        //        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        //        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        //        NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        
        NSLog(@"--->>>b push response data=%@,method=%@",data,method);
        
//        self.baiduUserID=userid;
//        [self bindToken];
    }
}

#pragma mark - UMeng相关
-(void)showUpdateAlertView
{
    if(!self.diaAlert)
    {
        NSDictionary * info = self.updateDic;
        
        NSString * path = [info valueForKey:@"path"];
        NSString * log = [info valueForKey:@"update_log"];
        
        BOOL force = [[info valueForKey:@"forceUpdate"] boolValue];
        
        NSString * rightTxt = @"暂不升级";
        if(force) rightTxt = @"退出";
        
        NSString * leftTxt = @"升级";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:log
                                                        delegate:self
                                               cancelButtonTitle:leftTxt
                                               otherButtonTitles:rightTxt, nil];
        self.diaAlert = alert;
    }
    [self.diaAlert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary * info = self.updateDic;
    NSString * path = [info valueForKey:@"path"];
    BOOL force = [[info valueForKey:@"forceUpdate"] boolValue];
    
    //点击时，若
    if(buttonIndex==0)
    {
        NSString * urlString = [NSString stringWithFormat:kShareAPP_URL_DOWNLOAD_PATH];
        if(path) urlString = path;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
    }else if (buttonIndex == 1)
    {
        if(force)
        {
            exit(0);
        }
    }
    
}

-(void)initUMeng
{
    
//    账号/密码：leancloud@163.com/Public123 即可查看用户反馈
    NSString *appId = @"grXIMeMdvbtrL7UGRQ5Qmdwh-gzGzoHsz";
    NSString *appKey = @"sFzRHJ1ngRWdT7aYebB2jAd1";
    [AVOSCloud setApplicationId:appId clientKey:appKey];
    [AVOSCloud setAllLogsEnabled:NO];
//
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getBackOnlineConfigNot:)
                                                 name:UMOnlineConfigDidFinishedNotification
                                               object:nil];
    
    
    appKey = UMengAPPKEY;
    NSString * deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * mac = [self macString];
    NSString * idfa = [self idfaString];
    NSString * idfv = [self idfvString];
    NSString * urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@", appKey, deviceName, mac, idfa, idfv];
//    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:self];
//    urlString = @"http://www.baidu.com";
    
//    urlString = @"https://www.91zhiwang.com/api/liquidate/product?channel=creditease&device_guid=c0bf79b0eda5fc741de3e8d6e397ace2&device_model=YQ601&page_no=0&page_size=10&session_id=d35c016ceff84370c87eed9cf1448c2d3d8a145233225fd987acf9103d3f89cb7cad5ababf64c7886810a3a4b463cccae74b8e3fce724e05&timestamp=1457335665829&user_id=10476676&sn=a4ea4870e7892eaf5f91b9c05d7f612d";
    AFHTTPSessionManager * manager = [[AFHTTPSessionManager alloc] init];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString
      parameters:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSString * resultStr = nil;
             if(responseObject && [responseObject length]>0)
             {
                 resultStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 
                 if(!resultStr)
                 {
                     resultStr = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
                 }
             }
             NSLog(@"AFHTTPResponseSerializer %@",resultStr);
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"AFHTTPResponseSerializer %@",error);
         }];
    
    
    
    //友盟相关
    //更新在线参数
    [MobClick setAppVersion:[DZUtils currentAppBundleShortVersion]];
    [UMFeedback setAppkey:UMengAPPKEY];
    NSLog(@"%s %@_%@_%@",__FUNCTION__,[UMFeedback uuid],[self idfaString],[self idfvString]);
    NSString * channel = nil;
#ifdef kAPP_PAPA_Channel_Identifier
    channel = kAPP_PAPA_Channel_Identifier;
#endif
    [MobClick startWithAppkey:UMengAPPKEY reportPolicy:BATCH channelId:channel];
    [MobClick setLogEnabled:NO];
    
    [MobClick updateOnlineConfig];
}
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
//    NSLog(@"%s",__FUNCTION__);
//}
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//    NSLog(@"%s",__FUNCTION__);
//
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%s %@",__FUNCTION__,str);
//
//}


-(void)getBackOnlineConfigNot:(id)sender
{
    //获取参数更新，以确保后面使用的为最新参数
    //启动检查更新
    
    NSDictionary * dic = [MobClick getConfigParams];
    [[ZAConfigModel sharedInstanceManager] refreshConfigDataWithList:dic];
    
    
    NSString * channel = nil;
#ifdef kAPP_PAPA_Channel_Identifier
    channel = kAPP_PAPA_Channel_Identifier;
#endif
    [UMCheckUpdate checkUpdateWithDelegate:self selector:@selector(appUpdate:) appkey:UMengAPPKEY channel:channel];
    
}

+(BOOL)localTimeNeedRefreshCheck
{
    NSUserDefaults * stand = [[NSUserDefaults alloc] initWithSuiteName:WKDZUITIL_KEY_SETTING_TIME];
    NSTimeInterval lastTime=[stand doubleForKey:USERDEFAULT_UPLDATE_TIME_UPDATE_NOTICE_REFRESH];
    if (lastTime==NSNotFound||lastTime<1)
        return YES;
        //时间计算
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:lastTime+ZAUpdateNoticeRefreshTimeInterval];
    NSDate * now = [NSDate date];
    NSTimeInterval count = [date timeIntervalSinceDate:now];
    if(count>0) return NO;
    return YES;
}
- (void)appUpdate:(NSDictionary *)info
{
    NSString * path = [info valueForKey:@"path"];
    NSString * log = [info valueForKey:@"update_log"];
    
    BOOL update = [[info valueForKey:@"update"] boolValue];
    BOOL needForceUpdate = NO;
    
    //如果不需要，直接返回
    if(!update) return;
    
    //弹出提示框
//        NSDictionary * dic = [MobClick getConfigParams];
    NSString * str = [MobClick getConfigParams:@"forceUpdate"];
    NSArray * arr = [str componentsSeparatedByString:@","];
    //获取本地版本号
    NSString * current = [DZUtils currentAppBundleShortVersion];
    needForceUpdate = [arr containsObject:current];
    //是否需要强制更新

    //进行时间判定，仅针对可选更新有24小时提示判定
    //强制更新的，不判定时间
    if(!needForceUpdate&&![AppDelegate localTimeNeedRefreshCheck]) return;
    
    NSMutableDictionary  * dic = [NSMutableDictionary dictionaryWithDictionary:info];
    [dic setValue:[NSNumber numberWithBool:needForceUpdate] forKey:@"forceUpdate"];
    self.updateDic = dic;
    [self showUpdateAlertView];
    
    //保存当前时间
    NSDate * date = [NSDate date];
    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults];
    NSTimeInterval lastUpdateTime=[date timeIntervalSince1970];
    [stand setObject:[NSNumber numberWithDouble:lastUpdateTime]
              forKey:USERDEFAULT_UPLDATE_TIME_UPDATE_NOTICE_REFRESH];
    [stand synchronize];
    
    return;
    
//    //创建alertView
//    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleAlert];
//    
//    MSAlertAction *action = [MSAlertAction actionWithTitle:@"升级" style:MSAlertActionStyleDestructive handler:^(MSAlertAction *action)
//    {
//        NSString * urlString = [NSString stringWithFormat:kShareAPP_URL_DOWNLOAD_PATH];
//        if(path) urlString = path;
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
//    }];
//    [alertController addAction:action];
//    
//
//    
//    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
//        if(needForceUpdate)
//        {
//            exit(0);
//        }
//        
//    }];
//    [alertController addAction:action2];
//    
//    [self.window.rootViewController presentViewController:alertController
//                                                 animated:YES
//                                               completion:nil];
}

#pragma mark -
//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//
//}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    UIViewController * con =  viewController;
    UIViewController * current = viewController;
    BOOL noneDrag = [current isKindOfClass:[IIViewDeckController class]]||
    [current isKindOfClass:[ZATimerStartedController class]];
    
    if([self.homeCon isKindOfClass:[UITabBarController class]])
    {
        DPViewController * vc = (DPViewController *)self.homeCon.selectedViewController;
        if([vc isKindOfClass:[DPViewController class]]){
            [vc refreshDragBackEnable:!noneDrag];
        }
    }

    
    
    //之前中间为navigation时的自动处理
    /***
    BOOL openLeft = [current isKindOfClass:[ZAContactListController class]]
    || [current isKindOfClass:[ZAPWDEditController class]]
    ||[current isKindOfClass:[ZAUserEditController class]];
    if(openLeft)
    {
        //数据保存
        showLeft = YES;
    }
    if([con isKindOfClass:[ZAHomeTabBarController class]])
    {
        [(ZAHomeTabBarController *)con closeTabbarControllerCoverBtn];
        if(showLeft)
        {
            DPViewController * dp = (DPViewController *)[(ZAHomeTabBarController *)con selectedViewController];
            [dp showLeftViewWithLeftSliderAnimated:NO];
            showLeft = NO;
        }
    }else if([con isKindOfClass:[DPViewController class]])
    {
        [[(DPViewController *)con coverBtn] setHidden:YES];
    }
    ***/
    
    
    BOOL showNaBar =
    [viewController isKindOfClass:[MainTestActivity class]]
    ||[viewController isKindOfClass:[MainAppActivity class]]
    ||[viewController isKindOfClass:[WebActivity class]]
    ||[viewController isKindOfClass:[ABPersonViewController class]];
    
    if(showNaBar){
        navigationController.navigationBarHidden = NO;
    }else
        navigationController.navigationBarHidden = YES;
}


-(void)setAdapter
{
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(SCREEN_HEIGHT > 480){
        myDelegate.autoSizeScaleX = SCREEN_WIDTH/320;
        myDelegate.autoSizeScaleY = SCREEN_HEIGHT/568;
    }else{
        myDelegate.autoSizeScaleX = 1.0;
        myDelegate.autoSizeScaleY = 1.0;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [KMStatis staticApplicationEvent:StaticApplicationEventType_ResignActive];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    [KMStatis staticApplicationWillResignActiveForVCClassDes:total.kmVCNameString];
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [[TokenRefreshManager sharedInstance] stopAutoRefresh];
    [KMStatis staticApplicationEvent:StaticApplicationEventType_EnterForground];
    
    if(![[ZALocation sharedInstance] isInUpdating]) return;
    [[[ZALocation sharedInstance] locManager] startMonitoringSignificantLocationChanges];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //发送消息
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_START_CHECK_STATE object:nil];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [[TokenRefreshManager sharedInstance] startAutoRefresh];
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    [KMStatis staticApplicationDidBecomeActiveVCClassDes:total.kmVCNameString];
    
     application.applicationIconBadgeNumber = 0;
    if(![[ZALocation sharedInstance] isInUpdating]) return;
    [[[ZALocation sharedInstance] locManager] stopMonitoringSignificantLocationChanges];
    [[[ZALocation sharedInstance] locManager] startUpdatingLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    
    
    ZALocalNotificationManager * manager =[ZALocalNotificationManager sharedInstance];
    NSTimeInterval number = [manager firstNoticeForWakeupForCurrent];
    [manager startLocalNotificationWithType:ZALocalNotificationType_RemindNotice delaySecond:number];

    
}
#pragma mark - WatchKit Data
-(void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    NSLog(@"userInfo:%@",userInfo);
    
    NSString *type = userInfo[@"type"];
    NSDictionary *replyInfo = nil;

    ZALocalStateTotalModel * localModel = [ZALocalStateTotalModel currentLocalStateModel];
    NSString *localKey = userInfo[@"key"];
    //交互，校验密码，新版本之后，此问题不需要考虑
    if([type isEqualToString:WKDZUITIL_KEY_LOCAL_SAVE_TYPE])
    {
        NSString * pwd = [DZUtils localSaveObjectFromLocalSaveKeyStr:localKey];
        if(!pwd) pwd = @"";
        replyInfo = @{localKey:pwd};
    }else if([type isEqualToString:WKDZUITIL_KEY_WATCH_APPLICATIONSTART_TYPE])
    {
        [KMStatis staticWKApplicationStartEvent:StaticPaPaWKApplicationStartEventType_Start];

    }else if([type isEqualToString:WKDZUITIL_KEY_TIME_STATE_TYPE_STARTED]){
        //状态同步，启动
        //数据保存、位置上传、启动本地通知
        NSDate * endDate = userInfo[@"end"];
        NSString * total = userInfo[@"total"];
        
//        数据发送
        if(!total||[total intValue]==0)
        {
            //倒计时时间长度为空，暂无此情景，紧急模式使用WKDZUITIL_KEY_QUICK_STATE_TYPE_WARNING
//            [[LocationTimeRefreshManager sharedInstance] refreshRefreshTimeWithHeighPriority];
//            [DZUtils saveCurrentPWDState:YES];
//            [DZUtils localTimeNotificationCancel];
            return;
            
        }else
        {
            //展示页面
            //关闭可能的倒计时
            [connect startWebRequestWithRequestDic:userInfo andReplyBlockForAppleWatch:reply andLocalSuccessBlock:
             ^{
                 
                 [KMStatis staticWKWarningStaticEvent:StaticPaPaWKWarningEventType_StartTimer];
                 
                 localModel.totalTime = [total intValue];
                 localModel.endDate = endDate;
                 localModel.showPWD = NO;
                 [localModel localSave];
                 
                [DZUtils localTimeNotificationCancel];
                 NSTimeInterval second = ([total intValue] - 1) * 60;
                [DZUtils localTimeNotificationAppendedWithTimeLength:second];
                [[LocationTimeRefreshManager sharedInstance] refreshRefreshTimeWithNormalPriority];
            }];
            return;
        }
        
//        total = [DZUtils localSaveObjectFromLocalSaveKeyStr:USERDEFAULT_NAME_START_TIMEEND_TIME];
//        replyInfo = @{total:endDate};
        
    }else if([type isEqualToString:WKDZUITIL_KEY_QUICK_STATE_TYPE_WARNING]){
        //紧急模式的立即预警启动成功
        [connect startWebRequestWithRequestDic:userInfo andReplyBlockForAppleWatch:reply andLocalSuccessBlock:
         ^{
             [KMStatis staticWKWarningStaticEvent:StaticPaPaWKWarningEventType_QuickWarning];
             
             NSInteger total = 24 * 60;
             localModel.totalTime = total;
             localModel.endDate = nil;
             localModel.showPWD = YES;
             [localModel localSave];
             
             LocationTimeRefreshManager * manager = [LocationTimeRefreshManager sharedInstance];
             manager.scene = @"2";
             [manager refreshRefreshTimeWithNormalPriority];
         }];
        
        //        NSString * str = @"110";
        //        NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",str];
        //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
        
        return;
        
    }else  if([type isEqualToString:WKDZUITIL_KEY_TIME_STATE_TYPE_WARNING]){
         //用户使用倒计时的立即预警功能
        [connect startWebRequestWithRequestDic:userInfo andReplyBlockForAppleWatch:reply andLocalSuccessBlock:
         ^{
             [KMStatis staticWKWarningStaticEvent:StaticPaPaWKWarningEventType_WarningTimer];
             //移除参数
             localModel.showPWD = YES;
             [localModel localSave];
             
            [[LocationTimeRefreshManager sharedInstance] refreshRefreshTimeWithHeighPriority];
        }];
        return;
        
    }else if([type isEqualToString:WKDZUITIL_KEY_TIME_STATE_TYPE_CANCELED]){
        //状态同步，取消
        [connect startWebRequestWithRequestDic:userInfo andReplyBlockForAppleWatch:reply andLocalSuccessBlock:
         ^{
             
             [KMStatis staticWKWarningStaticEvent:StaticPaPaWKWarningEventType_Cancel];

             //数据保存、关闭位置上传、取消本地通知
             //关闭可能的倒计时
             localModel.totalTime = 0;
             localModel.endDate = nil;
             localModel.timeModel = nil;

             //预警解除，关闭数据上传
             [[LocationTimeRefreshManager sharedInstance] endAutoRefreshAndClearTime];
             
             //关闭可能的本地通知
             [DZUtils localTimeNotificationCancel];
             
             //移除参数
             localModel.showPWD = NO;
             [localModel localSave];
         }];
        return;
        
    }else  if([type isEqualToString:WKDZUITIL_KEY_LOCAL_CURRENT_TYPE])
    {
        //检查定位
        //检查网络
        //检查是否登录
        NSString * location = @"error";
        if([ZALocation locationStatusNeverSetting])
        {
            location = @"none";
        }else if([ZALocation locationStatusEnableInBackground]){
            location = nil;
        }
        
        
        //之前，网络检查部分关闭，可能存在问题
        NSString * network = @"error";
        if([DZUtils deviceWebConnectEnableCheck])
        {
            network = nil;
        }
        
        NSString * telNum = @"error";
        if(localModel.isUserLogin)
        {
            telNum = nil;
        }
        
        NSMutableDictionary * infoDic = [NSMutableDictionary dictionary];
        [infoDic setValue:network forKey:@"network"];
        [infoDic setValue:location forKey:@"location"];
        [infoDic setValue:telNum forKey:@"telNum"];
        
        replyInfo = infoDic;
    }


    reply(replyInfo);
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
//    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil))
    {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
//    } else{
        return NO;
    }
}
-(void)startedConnectLogRequest
{
    StartedLogModel * model = (StartedLogModel *) _startModel;
    if(!model){
        model = [[StartedLogModel alloc] init];
        [model addSignalResponder:self];
        _startModel = model;
    }
    [model sendRequest];
}
#pragma mark StartedLogModel
handleSignal( StartedLogModel, requestError )
{

}
handleSignal( StartedLogModel, requestLoading )
{
}
handleSignal( StartedLogModel, requestLoaded )
{

}
#pragma mark -



- (NSString * )macString{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return macString;
}

- (NSString *)idfaString {
    
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    }
    else{
        
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        
        if(asIdentifierMClass == nil){
            return @"";
        }
        else{
            
            //for no arc
            //ASIdentifierManager *asIM = [[[asIdentifierMClass alloc] init] autorelease];
            //for arc
            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            
            if (asIM == nil) {
                return @"";
            }
            else{
                
                if(asIM.advertisingTrackingEnabled){
                    return [asIM.advertisingIdentifier UUIDString];
                }
                else{
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
        }
    }
}

- (NSString *)idfvString
{
    if([[UIDevice currentDevice] respondsToSelector:@selector( identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    return @"";
}


@end
