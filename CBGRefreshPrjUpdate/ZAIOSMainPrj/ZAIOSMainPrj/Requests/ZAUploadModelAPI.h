//
//  ZAUploadModelAPI.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/9.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAHTTPApi.h"
//完成文件上传的相关封装

@interface ZAUploadModelRequest : ZAHTTPRequest
@property (nonatomic,copy) NSString * fileName;

@property (nonatomic,strong) NSData * fileData;
@property (nonatomic,copy) NSString * filePath;

@end

@interface ZAUploadModelResponse : ZAHTTPResponse
@end



@interface ZAUploadModelAPI : ZAHTTPApi

- (instancetype)initWithDuration:(NSString *)duration;
@property (nonatomic, strong) ZAUploadModelRequest *req;
@property (nonatomic, strong) ZAUploadModelResponse *resp;

@end