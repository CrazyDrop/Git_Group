//
//  ZWPanicMaxCombinedVC.h
//  WebConnectPrj
//
//  Created by Apple on 2017/6/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
#import "ZWBaseRefreshController.h"

//界面附加功能
//考虑合并历史后，再进行查看
//历史拆分、历史合并、查看历史
@interface ZWPanicMaxCombinedVC : ZWBaseRefreshController


+(void)updateCacheArrayListWithRemove:(NSString *)orderSn;





@end
