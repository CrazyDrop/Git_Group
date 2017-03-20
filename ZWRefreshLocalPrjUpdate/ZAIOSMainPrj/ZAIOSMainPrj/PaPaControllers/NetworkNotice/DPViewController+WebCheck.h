//
//  DPViewController+WebCheck.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/11/4.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DPViewController.h"

@interface DPViewController(WebCheck)

-(void)refreshWebListenForSpecialController;

//需要使用的类重写此方法
-(void)effectiveForWebStateCheck:(BOOL)connect;


@end
