//
//  OLTopicListRequest.h
//  WebConnectPrj
//
//  Created by Apple on 14-11-4.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "OLBasicRequest.h"

@interface OLTopicListRequest : OLBasicRequest

@property (nonatomic,assign) NSInteger page;

-(id)responseCheckForWebData:(id)data;

@end
