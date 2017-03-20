//
//  ZAIPostNotificationOnMainThread.m
//  ZAFTest
//
//  Created by VincentHu on 15/6/16.
//  Copyright (c) 2015年 VincentHu. All rights reserved.
//

#import "ZAIPostNotificationOnMainThread.h"

@implementation ZAIPostNotificationOnMainThread

+ (void)postOnMainThread:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] postNotification:aNotification];
}

+ (void)postNotification:(NSNotification *)aNotification
{
    if ([[NSThread currentThread] isMainThread])
    {
        [self postOnMainThread:aNotification];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(postOnMainThread:) withObject:aNotification waitUntilDone:NO];
    }
}

+ (void)postAsynchronouslyOnMainThread:(NSNotification *)aNotification
{
    [[NSNotificationQueue defaultQueue] enqueueNotification:aNotification postingStyle:NSPostASAP];
}

+ (void)postNotificationAsynchronously:(NSNotification *)aNotification
{
    if ([[NSThread currentThread] isMainThread])
    {
        [self postAsynchronouslyOnMainThread:aNotification];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(postAsynchronouslyOnMainThread:) withObject:aNotification waitUntilDone:NO];
    }
}


@end
