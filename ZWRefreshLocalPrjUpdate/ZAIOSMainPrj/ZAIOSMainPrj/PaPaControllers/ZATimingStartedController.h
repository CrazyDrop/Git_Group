//
//  ZATimingStartedController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/6/17.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPWhiteTopController.h"

@interface ZATimingStartedController : DPWhiteTopController
{
    UILabel * hourLbl;
    UILabel * secondLbl;
}
@property (nonatomic,strong) NSString * doStr;

//倒计时数字
@property (nonatomic,assign) NSInteger timingNum;

//倒计时总时间数
@property (nonatomic,assign) NSInteger totalTimingNum;


-(void)showTextWithCurrentTimingNum:(id)sender;

-(void)tapedOnHelpBtn:(id)sender;
-(void)tapedOnSafeBtn:(id)sender;


@end
