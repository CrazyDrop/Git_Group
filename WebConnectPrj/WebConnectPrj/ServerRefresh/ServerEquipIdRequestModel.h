//
//  ServerEquipIdRequestModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/7/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "RefreshDefaultListRequestModel.h"

typedef enum : NSUInteger {
    ServerResultCheckType_None = 0,
    ServerResultCheckType_Error,
    ServerResultCheckType_Redirect,
    ServerResultCheckType_Success,
} ServerResultCheckType;

@interface ServerEquipIdRequestModel : RefreshDefaultListRequestModel

//数据刷新
@property (nonatomic, assign) BOOL timerState;

//仅请求第一条数据，内含  serverid、indexNum
@property (nonatomic, strong) NSArray * serverArr;


@end
