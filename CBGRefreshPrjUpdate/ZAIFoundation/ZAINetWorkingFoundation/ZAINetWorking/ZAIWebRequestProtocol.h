//
//  ZAORequest.h
//  ZAFTest
//
//  Created by VincentHu on 15/6/11.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#ifndef ZAIWebRequestProtocol_h
#define ZAIWebRequestProtocol_h

@protocol ZAIWebRequestProtocol <NSObject>

@required

- (void) destroy;
- (bool) isEqualToRequest : (id<ZAIWebRequestProtocol>) request;

@optional

- (NSString *) brief;

@end

#endif
