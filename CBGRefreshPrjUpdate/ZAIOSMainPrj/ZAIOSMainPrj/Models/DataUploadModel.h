//
//  DataUploadModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/10.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"

typedef enum {
    DataUploadModelFileTYPE_ICON = 1,
    DataUploadModelFileTYPE_VOICE
} DataUploadModelFileTYPE;

@interface DataUploadModel : BaseRequestModel

//文件类型
@property (nonatomic,assign) DataUploadModelFileTYPE  fileType;

@property (nonatomic,copy) NSString * mediaLength;

//二选一，若都填充，使用data
@property (nonatomic,copy) NSData * fileData;
@property (nonatomic,copy) NSString * filePath;


@end
