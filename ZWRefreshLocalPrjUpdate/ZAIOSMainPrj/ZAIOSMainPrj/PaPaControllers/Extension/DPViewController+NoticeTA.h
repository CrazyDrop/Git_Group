//
//  DPViewController+NoticeTA.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/5.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"

//通知他功能的扩展

//完成判定底部分享部分界面弹出，针对选择的跳转，以及无功能时的提示
@interface DPViewController (NoticeTA)


@property (nonatomic,strong) NSArray * taArr;

//启动通知他
-(void)startActionForNoticeTA:(NSArray *)arr;





@end
