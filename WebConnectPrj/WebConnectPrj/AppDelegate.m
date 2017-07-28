//
//  AppDelegate.m
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "SFHFKeychainUtils.h"
#import "ViewController.h"
#import "ZALocationLocalModel.h"
#import "ZAAutoBuyHomeVC.h"
#import "CBGCopyUrlDetailCehckVC.h"
#import "CBGListModel.h"
#import "JSONKit.h"
@interface AppDelegate ()<UNUserNotificationCenterDelegate>

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
    NSLog(@"logFilePath %@",logFilePath);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"commonStaticAppDeviceId %@",[SFHFKeychainUtils commonStaticAppDeviceId]);
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(!total.localURL1)
    {
        total.localURL1 = WebRefresh_ListRequest_Default_URLString;
        [total localSave];
    }
    if(total.localURL2)
    {
        total.localURL2 = nil;
        [total localSave];
    }
    if(total.minServerId == 0){
        total.minServerId = 723;//当前最接近三年外的服务器，群星璀璨
        [total localSave];
    }
    if(total.limitPrice == 0 && total.limitRate == 0){
        total.limitRate = 20;
        total.limitPrice = 0;
        [total localSave];
    }
    
//    NSArray * arr = @[@"1115_1494573357_1118602948",@"487_1496568986_487973101"];
//    total.orderSnCache = [arr componentsJoinedByString:@"|"];
//    [total localSave];
    
//    [self writeLogToFile];
#if TARGET_IPHONE_SIMULATOR
//    [self writeLogToFile];
#endif
//    [NSDictionary dictionaryWithObjectsAndKeys:@"大唐官府",@"1",@"化生寺",@"2",@"女儿村",@"3",@"方寸山",@"4",@"天宫",@"5",@"普陀山",@"6",@"龙宫",@"7",@"五庄观",@"8",@"狮驼岭",@"9",@"魔王寨",@"10",@"阴曹地府"@"11",@"盘丝洞",@"12",@"神木林",@"13",@"凌波城",@"14",@"无底洞",@"15", nil]
    if(iOS10_constant_or_later)
    {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }

//    NSString * localUrl = @"refreshPayApp://params?weburl=http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=overall_search_show_detail&serverid=9&ordersn=22_1495613221_25411429&equip_refer=1|rate=0|price=33800";
//    NSDictionary * arr = [self paramDicFromLatestUrlString:localUrl];
    
    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:@"481_1495550722_483072426" forKey:@"4_2"];
    
    NSString * jsonStr = [dataDic JSONString];
    
    
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    
    ViewController * vc = [[ViewController alloc] init];
    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:vc];
    navc.navigationBar.hidden = YES;
    navc.navigationBarHidden = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController =navc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self refreshNotificationSetting];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       [self startWebRequest];
    });
    
    return YES;
}
-(void)startWebRequest
{
    NSString * urlString = @"http://log.umtrack.com/ping?devicename=111&mac=1111&idfa=1111&idfv=1111";
    //    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:self];
    urlString = @"http://www.baidu.com";
    AFHTTPSessionManager * manager = [[AFHTTPSessionManager alloc] init];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager  GET:urlString
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
              NSLog(@"AFHTTPResponseSerializer %ld",[resultStr length]);
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              NSLog(@"AFHTTPResponseSerializer %@",error);
          }];

}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    NSLog(@"%@ %@",url,options);
//    NSString * webUrl = [NSString stringWithFormat:@"refreshPayApp://params?weburl=%@&param2=222",urlString];

    NSString * urlString = [url absoluteString];
    if([urlString containsString:@"refreshPayApp:"])
    {
        NSDictionary * paramDic = [self paramDicFromLatestUrlString:urlString];
        NSString * weburl = [paramDic objectForKey:@"weburl"];
        NSString * rate = [paramDic objectForKey:@"rate"];
        NSString * price = [paramDic objectForKey:@"price"];

        weburl = [weburl base64DecodedString];
        if(weburl)
        {
            ZAAutoBuyHomeVC * home = [[ZAAutoBuyHomeVC alloc] init];
            home.webUrl = weburl;
            home.rate = [rate integerValue];
            home.price = [price integerValue];
            
            UINavigationController * naVC = (UINavigationController *)[DZUtils currentRootViewController];
            [naVC pushViewController:home animated:YES];
            
            ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
            NSMutableArray * refreshArr = [NSMutableArray arrayWithArray:total.panicOrderHistory];
            [refreshArr insertObject:weburl atIndex:0];
            total.panicOrderHistory = refreshArr;
            [total localSave];
        }
    }
    
    
    return  YES;
}
-(NSDictionary *)paramDicFromLatestUrlString:(NSString *)totalStr
{
    NSString * paramStr = [totalStr stringByReplacingOccurrencesOfString:@"refreshPayApp://params?" withString:@""];
    NSArray * subArr = [paramStr componentsSeparatedByString:@"&"];
    NSMutableDictionary * resultDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0;index < [subArr count];index ++ ) {
        NSString * eveStr = [subArr objectAtIndex:index];
        NSArray * eveArr = [eveStr componentsSeparatedByString:@"="];
        if([eveArr count] >= 2)
        {
            NSString * keyStr = [eveArr objectAtIndex:0];
            NSString * valueStr = [eveStr substringFromIndex:[keyStr length] + 1];
            [resultDic setObject:valueStr forKey:keyStr];
        }
    }

    
    return resultDic;
}


//自动进行库表合并，将当前part库SOLD表内销售数据  合并入update库Total表

-(void)refreshNotificationSetting
{
    if(iOS8_constant_or_later)
    {
        
        if ([UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        
    }else
    {
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             UIRemoteNotificationTypeAlert
             | UIRemoteNotificationTypeBadge
             | UIRemoteNotificationTypeSound];
        }
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    
    NSDictionary * info = response.notification.request.content.userInfo;
    NSLog(@"%s  didReceiveNotificationResponse-->>,%@",__FUNCTION__,info);
    
    NSString * web = [info objectForKey:@"weburl"];
    if([web length] > 0){
        [self receiveLocalNotificationWithInfo:info andDoneBlock:nil];
    }
    
}

-(void)receiveLocalNotificationWithInfo:(NSDictionary *)userInfo andDoneBlock:(void (^)(void))completionHandler
{
    //取出通知中的本地url地址，打开支付APP
    NSString * webUrl = [userInfo objectForKey:@"weburl"];

    CBGListModel * cbgList = [CBGCopyUrlDetailCehckVC listModelBaseDataFromLatestEquipUrlStr:webUrl];
    NSURL * appPayUrl = [NSURL URLWithString:cbgList.mobileAppDetailShowUrl];
    
    if([[UIApplication sharedApplication] canOpenURL:appPayUrl])
    {
        [[UIApplication sharedApplication] openURL:appPayUrl];
    }else
    {
        [DZUtils noticeCustomerWithShowText:@"未安装手机端APP"];
    }
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary * info = notification.userInfo;
    [self receiveLocalNotificationWithInfo:info andDoneBlock:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
//    [DZUtils localSoundTimeNotificationWithAfterSecond];

}

@end
