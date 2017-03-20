//
//  OpenSSLRSACryptor.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenSSLRSACryptor : NSObject

- (BOOL)loadPublicKeyFromFile:(NSString *)path;
- (BOOL)loadPrivateKeyFromFile:(NSString *)path;

- (NSString *)rsaEncryptString:(NSString*)string;
- (NSData *)rsaEncryptData:(NSData*)data;

- (NSString *)rsaDecryptString:(NSString*)string;
- (NSData *)rsaDecryptData:(NSData*)data;

- (NSString *)rsaSHA1SignString:(NSString *)string;

- (BOOL)rsaSHA1VerifyString:(NSString *)plainString
              withSignature:(NSString *)signString;


+ (OpenSSLRSACryptor *)sharedInstance;

@end
