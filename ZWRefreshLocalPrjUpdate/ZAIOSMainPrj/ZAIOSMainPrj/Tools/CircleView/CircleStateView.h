//
//  CircleStateView.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/11.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CircleStateViewStateType_NORMAL = 1,//录音中
//    CircleStateViewStateType_COMBINE_ING,   //合并中
    CircleStateViewStateType_RECORDER_FAIL, //录音失败
    CircleStateViewStateType_RECORDER_START_FAIL, //录音权限未打开
    CircleStateViewStateType_UPLOAD_ING,    //上传中
    CircleStateViewStateType_UPLOAD_SUCESS,//上传成功
    CircleStateViewStateType_UPLOAD_FAILED,//上传失败
} CircleStateViewStateType;


@interface CircleStateView : UIView

@property (nonatomic,copy) void (^RetryUploadForUploadErrorBlock)(void);

@property (nonatomic,assign) CircleStateViewStateType state;

@property (nonatomic,readonly) UILabel * timeNumLbl;

-(void)refreshForLoadingAnimation;



@end
