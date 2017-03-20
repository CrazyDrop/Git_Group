//
//  ZAHomeTabBarController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/16.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>



//主结构   使用此类，主要完成可能的tab事件监控
//不适用此类界面，用于首界面
@interface ZAHomeTabBarController : UITabBarController

@property (nonatomic,readonly) UIView * bottomView;

//-(void)setBottomTabBarEnable:(BOOL)enable;

//不再使用
-(void)closeTabbarControllerCoverBtn;

//启动检查，此操作本delegate处理  现统一使用此方法检查
-(void)startWebStateAndLocalStateCheck;


@end
