//
//  ZWSessionGroupBaseReqModel.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/9.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "BaseRequestModel.h"

@interface ZWSessionGroupBaseReqModel : BaseRequestModel
{
    NSOperationQueue * defaultQueue;
}

@property (nonatomic, assign) NSInteger timeOutCount;
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, strong) NSArray * reqModels;  //数组内嵌套数组
@prop_strong( NSArray *,		listArray	OUT )   //数组内嵌套数组




@end
