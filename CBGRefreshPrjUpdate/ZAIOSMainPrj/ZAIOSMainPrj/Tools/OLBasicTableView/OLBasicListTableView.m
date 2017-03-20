
//
//  OLBasicListTableView.m
//  WebConnectPrj
//
//  Created by Apple on 14-10-16.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "OLBasicListTableView.h"
#import "OLEGOLatestHeaderView.h"
#import "OLEGOHeaderNormalControl.h"
@implementation  OLBasicListTableView
-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        //测试
        //创建新形式的headerview
        CGRect rect = self.bounds;
        OLEGOLatestHeaderView * head = [[OLEGOLatestHeaderView alloc] initWithFrame:rect];
        OLEGOHeaderNormalControl * control = [[OLEGOHeaderNormalControl alloc] init];
        head.viewControl = control;
        self.egoHeader = head;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}



@end