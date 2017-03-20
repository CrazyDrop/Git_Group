//
//  RSAEncryptor.h
//  ZAInsurance
//
//  Created by J on 15/4/30.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSACryptor : NSObject

#pragma mark - Instance Methods

- (void)loadPublicKeyFromFile: (NSString*) derFilePath;
- (void)loadPublicKeyFromData: (NSData*) derData;

- (void)loadPrivateKeyFromFile: (NSString*) p12FilePath password:(NSString*)p12Password;
- (void)loadPrivateKeyFromData: (NSData*) p12Data password:(NSString*)p12Password;




- (NSString *)rsaEncryptString:(NSString*)string;
- (NSData *)rsaEncryptData:(NSData*)data ;

- (NSString *)rsaSHA1SignString:(NSString *)string;
- (NSData *)rsaSHA1SignData:(NSData *)data;


- (NSString *)rsaDecryptString:(NSString*)string;
- (NSData *)rsaDecryptData:(NSData*)data;

- (BOOL)rsaSHA1VerifyString:(NSString *)plainString
              withSignature:(NSString *)signString;
- (BOOL)rsaSHA1VerifyData:(NSData *) plainData
            withSignature:(NSData *) signature;



#pragma mark - Class Methods

+(RSACryptor*) sharedInstance;

@end
