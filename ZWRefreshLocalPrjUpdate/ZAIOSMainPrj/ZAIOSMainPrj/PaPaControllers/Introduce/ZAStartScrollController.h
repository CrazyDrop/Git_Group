//
//  ZAStartScrollControllerViewController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/26.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"
//隐藏顶部导航条  在ZALoginController界面展示
@interface ZAStartScrollController : DPWhiteTopController

//点击启动应用，结束滚动的动画
//需要填充，界面消失、以及本地状态保存
@property (nonatomic,copy) void (^StartScrollEndBlock) ();




@end
