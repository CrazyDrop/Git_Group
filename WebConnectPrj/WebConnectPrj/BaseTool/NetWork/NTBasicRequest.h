//
//  NTBasicRequest.h
//  WebConnectPrj
//
//  Created by Apple on 14-10-9.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NTBasicRequest : NSObject

/**
 *	@brief	请求requestid，不可改变
 */
@property (nonatomic,readonly) NSString * requestid;


/**
 *	@brief	是否为测试网络请求，默认为NO,此参数在正式发布时删除
 */
@property (nonatomic,assign) BOOL sepcialRequestTag;


/**
 *	@brief	是否需要Authorization认证，如果需要，必须包含name pass属性，默认为NO
 */
@property (nonatomic,assign) BOOL needAuthorization;


/**
 *	@brief	请求地址
 */
@property (nonatomic,retain) NSString * requestUrlStr;


-(id)initWithRequestIdStr:(NSString *)str;

+(instancetype)basicNTRequestModelWithRequestIDStr:(NSString *)reqeustid;


- (NSDictionary *)currentDataDic;

- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (void)setValue:(id)value forKey:(NSString *)key;





@end
