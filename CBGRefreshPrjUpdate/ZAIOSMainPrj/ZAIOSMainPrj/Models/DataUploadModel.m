//
//  DataUploadModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/10.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "DataUploadModel.h"
#import "ZAUploadModelAPI.h"
#import "ZAIconUploadModelAPI.h"
@interface DataUploadModel()
@property (nonatomic,strong) STIHTTPApi * api;
//文件名  @"voice"  或者 @"icon"
@property (nonatomic,copy) NSString * fileName;
@end

@implementation DataUploadModel

-(id)init
{
    self = [super init];
    if(self){
        self.fileType = DataUploadModelFileTYPE_VOICE;
    }
    return self;
}
-(void)setFileType:(DataUploadModelFileTYPE)fileType
{
    _fileType = fileType;
    NSString * name = @"voice";
    if(fileType == DataUploadModelFileTYPE_ICON)
    {
        name = @"icon";
    }
    self.fileName = name;
}

-(void)sendRequest
{
    
    [self.api cancel];
    self.api = nil;

    
    ZAUploadModelAPI * api = [[ZAIconUploadModelAPI alloc] init];
    if(self.fileType == DataUploadModelFileTYPE_VOICE)
    {
        api = [[ZAUploadModelAPI alloc] initWithDuration:self.mediaLength];
    }
    
    @weakify(self)

    api.req.fileName = self.fileName;
    
    api.req.filePath = self.filePath;
    api.req.fileData = self.fileData;
    
    api.whenUpdate = ^(ZAUploadModelResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
            [self sendSignal:self.requestLoaded withObject:resp];
        }else{
            [self sendSignal:self.requestError];
        }
    };
    
    self.api = api;
    [api send];
    
    [self sendSignal:self.requestLoading];
}


@end
