//
//  ZASwipePartCell.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/8/13.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "JZSwipeCell.h"

@interface ZASwipePartCell : JZSwipeCell


@property (nonatomic,readonly) UIView * noUseRedCircle;
@property (nonatomic,readonly) UIView * noticeRedCircle;
@property (nonatomic,readonly) UIButton * noticeBtn;

//事件点击回调
@property (nonatomic,copy) void(^TapedOnNotificationForUser)(UITableViewCell * cell);


@end
