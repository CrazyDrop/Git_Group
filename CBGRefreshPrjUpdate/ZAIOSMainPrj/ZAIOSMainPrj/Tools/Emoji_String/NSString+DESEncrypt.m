//
//  NSString+DESEncrypt.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/2/24.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "NSString+DESEncrypt.h"
#import "NSData+CommonCrypto.h"
@implementation NSString (DESEncrypt)

//错误返回nil
-(NSString *)DESEncryptedWithKeyString:(NSString *)key
{
    NSData * source = [self dataUsingEncoding:NSUTF8StringEncoding];
    

    CCCryptorStatus status = kCCSuccess;
    NSData * result = [source dataEncryptedUsingAlgorithm:kCCAlgorithmDES
                                                      key:key
                                     initializationVector:key
                                                  options:kCCOptionPKCS7Padding
                                                    error:&status];
    if(status!=kCCSuccess)
    {
        return nil;
    }
    

    return [result base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return nil;
}

//错误返回nil
-(NSString *)DESDecryptedDESDataUsingKey:(NSString *)key
{
    NSData * source = [self dataUsingEncoding:NSUTF8StringEncoding];
//    char * iv = [[key dataUsingEncoding:NSUTF8StringEncoding] bytes];

    CCCryptorStatus status = kCCSuccess;
    NSData * result = [source decryptedDataUsingAlgorithm:kCCAlgorithmDES
                                                      key:key
                                     initializationVector:key
                                                  options:kCCOptionPKCS7Padding
                                                    error:&status];
    if(status!=kCCSuccess)
    {
        return nil;
    }
    
    
    return [result base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
