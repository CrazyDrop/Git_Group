//
//  JSOperation.h
//  WebConnectPrj
//
//  Created by Apple on 14-11-20.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

//#import "OLBasicRequest.h"
#import <UIKit/UIKit.h>
@interface JSOperation : NSOperation

-(id)initWithHTMLString:(NSString *)str andWeb:(UIWebView *)aWeb;

@property (nonatomic,strong) void(^endJSOperationBlcok)(NSArray *arr);

@end
