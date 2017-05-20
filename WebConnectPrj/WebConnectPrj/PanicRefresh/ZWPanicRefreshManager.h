//
//  ZWPanicRefreshManager.h
//  WebConnectPrj
//
//  Created by Apple on 2017/5/20.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
//缓存临时加载的数据
@interface ZWPanicRefreshManager : NSObject


@property (nonatomic, strong) NSArray * showArr;
@property (nonatomic, strong) NSString * cacheShowStr;
@property (nonatomic, strong) NSString * cacheReqeustStr;


@end
