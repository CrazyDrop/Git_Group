//
//  AESCryptor.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/13.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "AESCryptor.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"

@implementation AESCryptor

+ (NSString *)encrypt:(NSString *)message password:(NSString *)password {
    NSData *encryptedData = [[message dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    NSString *base64EncodedString = [encryptedData base64EncodedString];
    return base64EncodedString;
}

+ (NSString *)decrypt:(NSString *)base64EncodedString password:(NSString *)password {
    NSData *encryptedData = [NSData dataWithBase64EncodedString:base64EncodedString];
    NSData *decryptedData = [encryptedData decryptedAES256DataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

@end
