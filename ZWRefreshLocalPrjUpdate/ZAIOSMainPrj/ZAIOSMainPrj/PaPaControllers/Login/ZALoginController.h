//
//  ZALoginController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/9.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAStartController.h"
//登录界面，(实际调用注册接口)
//单独设置顶部

//展示顶部导航条
@interface ZALoginController : ZAStartController

//暂不统计appear事件，默认为NO
@property (nonatomic,assign) BOOL kmNoneAppear;

@property (nonatomic,assign) BOOL needRefreshStateBar;
-(void)refreshLoginControllerStateBarForShow;


@end
