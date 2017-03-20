//
//  FileCacheManager.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "FileCacheManager.h"

@interface FileCacheManager()
{
    dispatch_queue_t _fileCacheQueue;
}
@end

@implementation FileCacheManager

- (void)saveObject:(id)object forKey:(NSString *)key
{
    dispatch_async(_fileCacheQueue, ^{
        [FileCacheManager saveObject:object forKey:key];
    });
}

+ (BOOL)saveObject:(id)object forKey:(NSString *)key
{
    BOOL result = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:key];
    NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:object];
    if(saveData)
    {
        result = [saveData writeToFile:dataPath atomically:YES];
    }else{
        NSFileManager * fm = [NSFileManager defaultManager];
        NSError* error;
        
        result = [fm removeItemAtPath:dataPath error:&error];
    }
    return result;
}

+ (id)objectForKey:(NSString *)key
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:key];
    NSFileManager * fm = [NSFileManager defaultManager];
    
    NSData *savedData = [fm contentsAtPath:dataPath];
    
    if(savedData)
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:savedData];
    }
    
    return nil;
}

static FileCacheManager *sharedInstance = nil;
+ (FileCacheManager *)sharedInstance
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
        _fileCacheQueue = dispatch_queue_create("com.zhongan.fileCacheThread", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

@end
