//
//  AppDelegate.m
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "AppDelegate.h"
#import "SFHFKeychainUtils.h"
#import "ViewController.h"
#import "ZALocationLocalModel.h"

@interface AppDelegate ()

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
//    [self writeLogToFile];
#if TARGET_IPHONE_SIMULATOR
//    [self writeLogToFile];
#endif
//    [NSDictionary dictionaryWithObjectsAndKeys:@"大唐官府",@"1",@"化生寺",@"2",@"女儿村",@"3",@"方寸山",@"4",@"天宫",@"5",@"普陀山",@"6",@"龙宫",@"7",@"五庄观",@"8",@"狮驼岭",@"9",@"魔王寨",@"10",@"阴曹地府"@"11",@"盘丝洞",@"12",@"神木林",@"13",@"凌波城",@"14",@"无底洞",@"15", nil]
    
    
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
    
    return YES;
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
}

@end
