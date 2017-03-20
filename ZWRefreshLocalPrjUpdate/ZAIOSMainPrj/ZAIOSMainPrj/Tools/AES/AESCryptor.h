//
//  AESCryptor.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/13.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AESCryptor : NSObject

+ (NSString *)encrypt:(NSString *)message password:(NSString *)password;
+ (NSString *)decrypt:(NSString *)base64EncodedString password:(NSString *)password;

@end
