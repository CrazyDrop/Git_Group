//
//  CBGZhaohuanListRequestModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/7/28.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "RefreshDefaultListRequestModel.h"

@interface CBGZhaohuanListRequestModel : RefreshDefaultListRequestModel

@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) BOOL timerState;


@end
