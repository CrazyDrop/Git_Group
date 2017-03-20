//
//  ZWBGRefreshManager.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/14.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWBGRefreshManager : NSObject

+(instancetype)sharedInstance;

-(void)startZWBGRefreshWithFinishBlock:(void (^)(UIBackgroundFetchResult result))block;


@end
