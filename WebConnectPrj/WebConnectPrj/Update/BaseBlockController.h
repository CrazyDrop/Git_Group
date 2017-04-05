//
//  BaseBlockController.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/5.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "BaseActivity.h"
#import <MessageUI/MessageUI.h>
//作为公用类的基础类使用
@interface BaseBlockController : UIViewController


//短信回收时的回调功能
@property (nonatomic,copy) void (^CloseMessageViewFinishBlock)(MessageComposeResult result);





@end
