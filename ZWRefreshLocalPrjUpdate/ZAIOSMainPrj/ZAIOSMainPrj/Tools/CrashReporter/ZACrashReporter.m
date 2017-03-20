//
//  ZACrashReporter.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZACrashReporter.h"
#import <CrashReporter/CrashReporter.h>

@interface ZACrashReporter()
@property (nonatomic, strong) PLCrashReporter *crashReporter;
@end

@implementation ZACrashReporter

- (void)saveCrashDataToFile:(NSData *)crashData withCrashTime:(NSDate *)date
{
    if(crashData == nil)
        return;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderDirectory = [documentsDirectory stringByAppendingPathComponent:@"ZACrashs"];
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError* error;
    if (![fm fileExistsAtPath:folderDirectory]){//不存在则重新创建
        if([fm createDirectoryAtPath:folderDirectory withIntermediateDirectories:NO attributes:nil error:&error])
        {
            
        }
        else
        {
            NSLog(@"Failed to create directory %@,error:%@",folderDirectory,error);
        }
    }
    NSDateFormatter *formatter = [DZUtils sharedDateFormatter];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timeString = [formatter stringFromDate:date];
    NSString *version = [NSString stringWithFormat:@"%@build%@",[DZUtils currentAppBundleShortVersion],[DZUtils currentAppBundleVersion]];
    
    NSString *fileName =[NSString stringWithFormat:@"%@_%@.crash",version,timeString];
    NSString *crashFilePath = [folderDirectory stringByAppendingPathComponent:fileName];
    [crashData writeToFile:crashFilePath atomically:YES];
}

- (void)handleCrashReport
{
    NSData *crashData;
    NSError *error;
    crashData = [self.crashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (crashData == nil) {
        NSLog(@"Could not load crash report: %@", error);
        [self.crashReporter purgePendingCrashReport];
        return;
    }
    
    PLCrashReport *crashLog = [[PLCrashReport alloc] initWithData:crashData error: &error];
    if (crashLog == nil) {
        NSLog(@"Could not parse crash report");
        [self.crashReporter purgePendingCrashReport];
        return;
    }
    
    if(crashData)
        [self saveCrashDataToFile:crashData withCrashTime:crashLog.systemInfo.timestamp];
}

- (void)checkCrashLog
{
    // Check if we previously crashed
    if ([self.crashReporter hasPendingCrashReport])
    {
        [self handleCrashReport];
    }
    
    
    NSError *error;
    // Enable the Crash Reporter
    if (![self.crashReporter enableCrashReporterAndReturnError: &error])
        NSLog(@"Warning: Could not enable crash reporter: %@", error);
}

static ZACrashReporter *sharedInstance = nil;
+ (ZACrashReporter *)sharedInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.crashReporter = [[PLCrashReporter alloc] init];
    }
    return self;
}

@end
