//
//  ZAICountDownButton.h
//  ZAIOSMainPrj
//
//  Created by Joe on 15/6/30.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZAICountDownButton : UIButton

- (void)setDuration:(NSInteger)interval;

- (void)startCountDown;

- (void)stopCountDown;

@end
