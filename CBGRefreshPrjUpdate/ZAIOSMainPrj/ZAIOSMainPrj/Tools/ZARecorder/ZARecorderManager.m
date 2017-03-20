//
//  ZARecorderManager.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/7.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZARecorderManager.h"
#import "lame.h"

#define kRecordAudioDirectory       @"localSaveCAF"
#define kRecordMP3AudioDirectory    @"ExchangeMP3"

@interface ZARecorderManager()<AVAudioRecorderDelegate>
{
    NSMutableArray * localPathArray;    //存储录音地址，仅名称发生改变，顺序存储
    NSMutableArray * mp3PathArray;      //存储mp3录音地址，仅名称发生改变，顺序存储

}
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）
@property (nonatomic,assign) BOOL hasStoped;
-(void)pauseAudioRecorder;
@end

@implementation ZARecorderManager

+(BOOL)recorderNeverStarted
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if([audioSession respondsToSelector:@selector(recordPermission)])
    {
        return AVAudioSessionRecordPermissionUndetermined == audioSession.recordPermission;
    }
    
    return NO;
}

+(BOOL)recorderIsEnable
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if([audioSession respondsToSelector:@selector(recordPermission)])
    {
        return AVAudioSessionRecordPermissionGranted == audioSession.recordPermission;
    }
    
    __block BOOL bCanRecord = NO;
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)])
        {
            [audioSession requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    return bCanRecord;
    
    return NO;

}
+(void)startRecorderAuthRequestWithBlock:(void(^)(BOOL enable))block
{
    //7.0以上准确，7.0以下暂不考虑
    __block BOOL bCanRecord = YES;
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)])
        {
            [audioSession requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
                if(block)
                {
                    block(granted);
                }
            }];
        }
    }
}



+(instancetype)sharedInstanceManager
{
    static ZARecorderManager *shareZARecorderManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZARecorderManagerInstance = [[[self class] alloc] init];
    });
    return shareZARecorderManagerInstance;
}

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        localPathArray = [[NSMutableArray alloc] init];
        mp3PathArray = [[NSMutableArray alloc] init];
        [self startPrepareAudioSession];
    }
    return self;
}

-(NSString *)localSaveRecorderName
{
    NSString * dateStr = [[NSDate date] description];
    return dateStr;
}


-(BOOL)audio_ExchangeCAFtoMP3WithCafPath:(NSString *)cafFilePath andMP3Path:(NSString *)mp3FilePath
{
    NSData * data = [NSData dataWithContentsOfFile:cafFilePath];
    if(!data || [data length]==0)
    {
        return NO;
    }
    
    
    BOOL result = NO;

    @try {
#if !TARGET_IPHONE_SIMULATOR
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame =lame_init();
        
        lame_set_in_samplerate(lame, 44100.0);
        
        lame_set_VBR(lame, vbr_default);
        
        lame_init_params(lame);
        
        do {
            
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            
            if (read == 0)
                
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            
            else
                
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        lame_close(lame);     
        fclose(mp3);    
        fclose(pcm);
#endif

        result = YES;
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        return result;
    }

    
}

- (NSString *)filePathWithDirectoryName:(NSString *)direct AndFileName:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    documentsDirectory =[documentsDirectory stringByAppendingPathComponent:direct];
    return [documentsDirectory stringByAppendingPathComponent:filename];
}


-(void)startPrepareAudioSession
{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleInterruption:)
                                                 name:        AVAudioSessionInterruptionNotification
                                               object: nil];
}


//-(NSURL *)getSavePath
//{
//    NSString * urlStr = [self cafLocalSavePath];
//    NSLog(@"recorder file path:%@",urlStr);
//    NSURL *url=[NSURL fileURLWithPath:urlStr];
//    return url;
//}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    
    NSDictionary * setDic = [NSDictionary
     dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt:AVAudioQualityMin],
     AVEncoderAudioQualityKey,
     [NSNumber numberWithInt:16],
     AVEncoderBitRateKey,
     [NSNumber numberWithInt:2],
     AVNumberOfChannelsKey,
     [NSNumber numberWithFloat:44100.0],
     AVSampleRateKey,
     nil];
    return setDic;
    
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(11025.0) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
//    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    
     [dicM setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];
    
    //....其他设置等
    return dicM;
}
/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        NSString * path = [self localSaveRecorderPath];
#if TARGET_IPHONE_SIMULATOR
        path = [[NSBundle mainBundle] pathForResource:@"2015-12-09_17-41-23.mp3" ofType:nil];
        return nil;
#endif
        NSURL *url=[NSURL fileURLWithPath:path];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        if (error)
        {
            return nil;
        }
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
    }
    return _audioPlayer;
}
/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        
        NSString * name = [self localSaveRecorderName];
        
        
        NSString * path = [self filePathWithDirectoryName:kRecordAudioDirectory
                                              AndFileName:[NSString stringWithFormat:@"%@.caf",name]];
        
        [localPathArray addObject:path];
        
        NSString * mp3Path = [self filePathWithDirectoryName:kRecordMP3AudioDirectory
                                              AndFileName:[NSString stringWithFormat:@"%@.mp3",name]];
        [mp3PathArray addObject:mp3Path];
        
        
        
        
        NSURL *url=[NSURL fileURLWithPath:path];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        
        AVAudioRecorder * aRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        aRecorder.delegate=self;
        aRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        
        self.audioRecorder = aRecorder;

        if (error)
        {
            [localPathArray removeAllObjects];
            NSAssert(YES,@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

//播放音乐文件打断处理，主要为电话打断
- (void)handleInterruption:(NSNotification*)notification {
    NSLog(@"handleInterruption");
    
    NSDictionary *interruptionDictionary = [notification userInfo];
    AVAudioSessionInterruptionType type =
    [interruptionDictionary [AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"Interruption started");
        [self.audioRecorder stop];
        
    } else if (type == AVAudioSessionInterruptionTypeEnded){
        NSLog(@"Interruption ended");
        
        //尚未结束
        if(!self.hasStoped)
        {
            self.audioRecorder = nil;
            [self startRecorder];
        }


        UIBackgroundTaskIdentifier bgTask = 0;
        if([UIApplication sharedApplication].applicationState== UIApplicationStateBackground) {
            //            [[HJPlayer sharedPlayer] playSounds];
            UIApplication*app = [UIApplication sharedApplication];
            
            UIBackgroundTaskIdentifier newTask = [app beginBackgroundTaskWithExpirationHandler:nil];
            
            if(bgTask!= UIBackgroundTaskInvalid) {
                
                [app endBackgroundTask:bgTask];
            }
            bgTask = newTask;
        }else {
            //        NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx前台播放");
            //            [[HJPlayer sharedPlayer] playSounds];
        }
        
    } else {
        NSLog(@"Something else happened");
    }
}


//-(NSTimer *)timer{
//    if (!_timer) {
//        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
//    }
//    return _timer;
//}

-(void)clearLocalSaveAudio
{
    //清空文件夹
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString * localPath = [self filePathWithDirectoryName:kRecordAudioDirectory
                                               AndFileName:nil];
    
    NSString * mp3Path = [self filePathWithDirectoryName:kRecordMP3AudioDirectory
                                             AndFileName:nil];
    
    
    if([fileManager fileExistsAtPath:localPath] && [fileManager removeItemAtPath:localPath error:nil] && [fileManager fileExistsAtPath:mp3Path] && [fileManager removeItemAtPath:mp3Path error:nil])
    {
        NSLog(@"删除");
    }
    
    NSError * error = nil;
    if(([fileManager createDirectoryAtPath:localPath withIntermediateDirectories:NO attributes:nil error:&error]) && [fileManager createDirectoryAtPath:mp3Path withIntermediateDirectories:NO attributes:nil error:&error])
    {
        NSLog(@"创建");
    }
    
    
    [localPathArray removeAllObjects];
    [mp3PathArray removeAllObjects];
    
    self.audioRecorder = nil;
    [self.audioRecorder isRecording];
    
}

//处于录音中
-(BOOL)isInRecordering
{
    return [self.audioRecorder isRecording];
}

//启动录音
-(void)startRecorder
{
    self.hasStoped = NO;
    if (![self.audioRecorder isRecording])
    {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
    }

}


//暂停录音、内部使用，继续录音使用startRecorder即可
-(void)pauseAudioRecorder
{
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
    }
}



//停止录音
-(void)stopRecorder
{
    self.hasStoped = YES;
    if([self.audioRecorder isRecording])
    {
        [self.audioRecorder stop];
    }else{
        [self refreshRecorderResultExchange];
    }

}
//音频播放
-(void)playForLocalRecorder
{
    if(![self.audioPlayer isPlaying])
    {
         [self.audioPlayer play];
    }
    
}
-(void)refreshRecorderResultExchange
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [self exchangeTotalMP3AndCombineSubs];
        [self refreshFinishBlockWithResult:result];
    });
}


//本地音频准备播放
-(NSString *)localMediaMP3TotalLength
{
    NSString * total = nil;
    
    NSTimeInterval count = self.audioPlayer.duration;
    if(count!=NSNotFound && count>0)
    {
        total = [NSString stringWithFormat:@"%d",(int)count];
    }
    return total;
}

-(BOOL)exchangeTotalMP3AndCombineSubs
{
    
    //执行方法调用，关闭全部
    NSArray * fromArr = localPathArray;
    NSArray * finishArr = mp3PathArray;
    
    //针对仅一个的特殊处理，免去再次复制的操作
    NSString * mp3Path = [self localSaveRecorderPath];
    if(fromArr && [fromArr count]==1)
    {
        NSString * from = [fromArr objectAtIndex:0];
        BOOL result = [self audio_ExchangeCAFtoMP3WithCafPath:from andMP3Path:mp3Path];
        if(!result)
        {
            NSLog(@"%s %d",__FUNCTION__,result);
        }
        return result;
    }
    
    
    for (NSInteger index =0;index < [fromArr count];index++)
    {
        NSString * from = [fromArr objectAtIndex:index];
        NSString * finish = [finishArr objectAtIndex:index];
        
        BOOL result = [self audio_ExchangeCAFtoMP3WithCafPath:from andMP3Path:finish];
        if(!result)
        {
            NSLog(@"%s %d",__FUNCTION__,result);
        }
    }
    
    NSMutableData *totalData = [[NSMutableData alloc] init];
    for (NSInteger index =0;index < [fromArr count];index++)
    {
        NSString * finish = [finishArr objectAtIndex:index];
        NSData  * eveData = [NSData dataWithContentsOfFile:finish];
        if(!eveData||[eveData length]==0) continue;
        [totalData appendData:eveData];
    }
    
    if([totalData length]==0)
    {
        return NO;
    }
    
    [totalData writeToFile:mp3Path atomically:YES];
    return YES;
}
-(void)refreshFinishBlockWithResult:(BOOL)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.DoneRecorderAndFinishedExchangeBlock)
        {
            self.DoneRecorderAndFinishedExchangeBlock(result);
        }
    });

}



//本地存储路径
-(NSString *)localSaveRecorderPath
{
    NSString * name = @"Total";
    NSString * path = [self filePathWithDirectoryName:kRecordMP3AudioDirectory
                                          AndFileName:[NSString stringWithFormat:@"%@.mp3",name]];
    
#if TARGET_IPHONE_SIMULATOR
    path = [[NSBundle mainBundle] pathForResource:@"2015-12-09_17-41-23.mp3" ofType:nil];
#endif
    return path;
    return nil;
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"%s %d",__FUNCTION__,flag);
    
    if(!self.hasStoped)
    {
        return;
    }
    [self refreshRecorderResultExchange];
}
/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    NSLog(@"%s",__FUNCTION__);
    [self refreshFinishBlockWithResult:NO];
}
#pragma mark ---


@end
