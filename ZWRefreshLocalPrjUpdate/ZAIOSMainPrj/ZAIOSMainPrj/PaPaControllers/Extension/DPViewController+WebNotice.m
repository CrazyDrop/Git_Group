//
//  DPViewController+WebNotice.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/2/1.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController+WebNotice.h"
#import "AppDelegate.h"
@implementation DPViewController (WebNotice)

//置为常用
-(void)refreshWebNoticeViewForNormal
{
    [self refreshWebNoticeViewForCustomWithStartY:kTop];
}

//置为特殊
-(void)refreshWebNoticeViewForCustomWithStartY:(CGFloat)startY
{
    AppDelegate * dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView * aView = dele.webNotice.view;
    
    CGRect rect = aView.frame;
    rect.origin.y = startY;
    aView.frame = rect;
}


@end
