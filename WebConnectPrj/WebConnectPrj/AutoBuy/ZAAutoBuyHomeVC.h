//
//  ZAAutoBuyHomeVC.h
//  WebConnectPrj
//
//  Created by Apple on 2017/5/24.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
//自动购买的基础类
@interface ZAAutoBuyHomeVC : DPWhiteTopController

@property (nonatomic, strong) NSString * webUrl;
@property (nonatomic, assign) NSInteger price;
@property (nonatomic, assign) NSInteger rate;


@end
