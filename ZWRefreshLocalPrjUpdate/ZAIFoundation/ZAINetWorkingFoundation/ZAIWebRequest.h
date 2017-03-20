//
//  ZAOnlineRequest.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZAIWebRequestAPI.h"
#import "ZAIUrlForRequest.h"
#import "ZAIWebRequestTask.h"
#import "ZAIWebRequestKernel.h"

typedef void (^ReturnSucessBlock) (id returnValue);
typedef void (^ReturnFailedBlock) (id returnValue);

@interface ZAIWebRequest : NSObject

@property (strong, nonatomic) ReturnFailedBlock failedBlock;
@property (strong, nonatomic) ReturnSucessBlock sucessBlock;
@property (nonatomic,assign)  NSInteger requestId;


- (void)setBlockWithReturnBlock:(ReturnSucessBlock)sucessBlock
                withFailedBlock:(ReturnFailedBlock)failedBlock;

- (void) cancelFetch;

- (NSString *)sign;

-(ZAIWebRequestTask *)buildWebRequestAPIWithDics:(NSDictionary *)dic;

@end
