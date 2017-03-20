//
//  ZADoMenuController.h
//  ZAIOSMainPrj
//
//  Created by 赵宪云 on 16/1/4.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZADoMenuController : UIViewController

+(NSArray *)ZATagMenuArray;

@property (nonatomic,strong) NSString * currentStr;

@property (nonatomic,copy) void (^DoneDoMenuBlock) (NSString * str);


@end
