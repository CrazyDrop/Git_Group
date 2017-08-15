//
//  ZWProxyRefreshManager.h
//  WebConnectPrj
//
//  Created by Apple on 2017/8/10.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
//应用内当前代理字典数组
//session使用策略、创建30个session的数组，赋值给分片model，进行随机使用

@interface ZWProxyRefreshManager : NSObject

@property (nonatomic, strong) NSArray * proxyArrCache;
@property (nonatomic, strong, readonly) NSArray * proxySubCache;

@property (nonatomic, strong) NSArray * sessionArrCache;
@property (nonatomic, strong, readonly) NSArray * sessionSubCache;

//@property (nonatomic, strong) 
-(void)clearProxySubCache;

@end
