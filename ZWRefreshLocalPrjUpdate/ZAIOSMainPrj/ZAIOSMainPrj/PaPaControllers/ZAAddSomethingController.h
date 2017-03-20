//
//  ZAAddSomethingController.h
//  ZAIOSMainPrj
//
//  Created by 赵宪云 on 15/12/31.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"

@interface ZAAddSomethingController : DPViewController
@property (nonatomic, copy) void (^DoneEditToDoBlock)(NSString *str);
@end
