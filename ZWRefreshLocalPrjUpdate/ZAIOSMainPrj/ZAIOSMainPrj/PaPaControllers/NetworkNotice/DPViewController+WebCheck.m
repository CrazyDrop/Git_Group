//
//  DPViewController+WebCheck.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/4.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController+WebCheck.h"

@interface DPViewController(Private)

@end

@implementation DPViewController(WebCheck)

-(void)refreshWebListenForSpecialController
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webStateShowChanged:)
                                                 name:NOTIFICATION_WEBCHECK_NOTICE_SHOW_STATE
                                               object:nil];
}
-(void)webStateShowChanged:(NSNotification *)noti
{
    NSNumber * num = noti.object;
    [self effectiveForWebStateCheck:[num boolValue]];
}

//需要使用的类重写此方法
-(void)effectiveForWebStateCheck:(BOOL)connect
{
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
