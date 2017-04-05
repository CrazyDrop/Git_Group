//
//  BlockConstant.h
//  AFNetworking iOS Example
//
//  Created by Apple on 14-8-8.
//  Copyright (c) 2014年 Gowalla. All rights reserved.
//

//Block宏定义
typedef NSArray *(^CheckResponseDataBlock)(id responseData);

typedef void    (^DownloadProgressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);