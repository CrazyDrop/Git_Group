//
//  CBGMixedListCheckVC.h
//  WebConnectPrj
//
//  Created by Apple on 17/3/29.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "DPWhiteTopController.h"
//实现混合的列表查询逻辑
//同时开启两种数据刷新，混合时，web使用高频并发、mobile使用3页并发
@interface CBGMixedListCheckVC : DPWhiteTopController

//混合刷新，混合刷新时，WEB刷新提示，mobile刷新无提示



@end
