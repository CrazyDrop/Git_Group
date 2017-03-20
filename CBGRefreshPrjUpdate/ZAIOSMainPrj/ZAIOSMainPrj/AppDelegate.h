//
//  AppDelegate.h
//  ZAIOSMainPrj
//
//  Created by zhangchaoqun on 15/4/29.
//  Copyright (c) 2015年 zhangchaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZAHomeTabBarController.h"
//#import "ZAWebNoticeController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) ZAHomeTabBarController * homeCon;
@property float autoSizeScaleX;
@property float autoSizeScaleY;

@property (nonatomic,strong) UIViewController * webNotice;


-(void)refreshWindowRootViewController;


@end

