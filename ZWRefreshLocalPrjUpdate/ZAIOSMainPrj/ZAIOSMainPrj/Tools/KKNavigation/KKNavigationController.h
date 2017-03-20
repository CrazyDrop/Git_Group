//
//  KKNavigationController.h
//  TS
//
//  Created by Coneboy_K on 13-12-2.
//  Copyright (c) 2013年 Coneboy_K. All rights reserved. MIT
//  WELCOME TO MY BLOG  http://www.coneboy.com
//

#import <UIKit/UIKit.h>

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define kkBackViewHeight [UIScreen mainScreen].bounds.size.height
#define kkBackViewWidth [UIScreen mainScreen].bounds.size.width

#define iOS7  ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )

// 背景视图起始frame.x
//#define startX -200;
#define startX kkBackViewWidth/3.0*-1.0

@interface KKNavigationController : UINavigationController
{
    CGFloat startBackViewX;
    UIView * _topErrorView;
}

@property (nonatomic,strong) UIView * topErrorView;

// 默认为特效开启
@property (nonatomic, assign) BOOL canDragBack;
@property (nonatomic, retain) UIPanGestureRecognizer * panGes;


@end
