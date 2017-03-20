//
//  ZARecorderManager.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/7.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
//完成录音功能，并提供存储路径
//完成对录音功能的封装，主要封装内容(录音中断时的中断处理，存储路径的默认设定)

@interface ZARecorderManager : NSObject

+(BOOL)recorderNeverStarted;

+(BOOL)recorderIsEnable;

+(void)startRecorderAuthRequestWithBlock:(void(^)(BOOL enable))block;


+(instancetype)sharedInstanceManager;

@property (nonatomic,copy) void (^DoneRecorderAndFinishedExchangeBlock)(BOOL result);

-(void)clearLocalSaveAudio;

//处于录音中
-(BOOL)isInRecordering;

//启动录音
-(void)startRecorder;


//停止录音
-(void)stopRecorder;


//音频播放
-(void)playForLocalRecorder;

//本地音频准备播放
-(NSString *)localMediaMP3TotalLength;

//本地存储路径
-(NSString *)localSaveRecorderPath;




@end
