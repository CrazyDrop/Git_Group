//
//  DPViewController+WebNotice.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/2/1.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"

@interface DPViewController (WebNotice)

//置为常用
-(void)refreshWebNoticeViewForNormal;

//置为特殊
-(void)refreshWebNoticeViewForCustomWithStartY:(CGFloat)startY;



@end
