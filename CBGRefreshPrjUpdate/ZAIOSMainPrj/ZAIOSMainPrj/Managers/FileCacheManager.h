//
//  FileCacheManager.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/29.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCacheManager : NSObject

- (void)saveObject:(id)object forKey:(NSString *)key;

+ (BOOL)saveObject:(id)object forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (FileCacheManager *)sharedInstance;

@end


