//
//  ScrollBGController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/20.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"

@protocol  ScrollContainControllerDelegate<NSObject>

-(UIViewController *)scrollContainConrollerForHome;

@end
@interface ScrollBGController : DPWhiteTopController

@property (nonatomic,assign) id<ScrollContainControllerDelegate> controllerDelegate;


@end
