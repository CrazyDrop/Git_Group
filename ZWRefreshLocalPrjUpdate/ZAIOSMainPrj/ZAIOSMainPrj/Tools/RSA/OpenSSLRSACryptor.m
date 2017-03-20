//
//  OpenSSLRSACryptor.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/8.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "OpenSSLRSACryptor.h"
#import <openssl/rsa.h>
#import <openssl/pem.h>
#import "NSString+Base64.h"


@interface OpenSSLRSACryptor()
{
    RSA *_publicRSA;
    RSA *_privateRSA;
}

@end

@implementation OpenSSLRSACryptor

#pragma mark - Methods

- (RSA *)getPublicRSA
{
    return _publicRSA;
}

- (RSA *)getPrivateRSA
{
    return _privateRSA;
}

- (BOOL)loadPublicKeyFromFile:(NSString *)path
{
    //    NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //
    //    unsigned char * key = (unsigned char *)[content cStringUsingEncoding:NSASCIIStringEncoding];
    //    RSA *rsa = NULL;
    //    BIO *keybio;
    //    keybio = BIO_new_mem_buf(key, -1);
    //    rsa = PEM_read_bio_RSA_PUBKEY(keybio, &rsa, NULL, NULL);
    //    _publicRSA = rsa;
    
    FILE *filePub = fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "r");
    if(filePub == NULL)
        return NO;
    _publicRSA = PEM_read_RSA_PUBKEY(filePub, NULL, NULL, NULL);
    
    return (_publicRSA != NULL);
}

- (BOOL)loadPrivateKeyFromFile:(NSString *)path
{
    FILE *filePri = fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "r");
    if(filePri == NULL)
        return NO;
    _privateRSA = PEM_read_RSAPrivateKey(filePri, NULL, NULL, NULL);
    return (_privateRSA != NULL);
}

#pragma mark - Encrypt

- (NSString *)rsaEncryptString:(NSString*)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptData = [self rsaEncryptData:data];
    if(encryptData)
        return [[NSString alloc] initWithString:[encryptData base64EncodedString]];
    return nil;
}

- (int)encryptRSAFrom:(const unsigned char *)from flen:(int)flen to:(unsigned char *)to{
    if (from != NULL && to != NULL) {
        int status;
        //        status = RSA_check_key(_publicRSA);
        //        if (!status) {
        //            NSLog(@"status code %i",status);
        //            return -1;
        //        }
        
        status =  RSA_public_encrypt(flen,from,to, _publicRSA,  RSA_PKCS1_PADDING);
        
        return status;
    }return -1;
}

- (NSData *)rsaEncryptData:(NSData*)data
{
    if(data && [data length])
    {
        int flen = (int)[data length];
        unsigned char from[flen];
        bzero(from, sizeof(from));
        memcpy(from, [data bytes], [data length]);
        
        unsigned char to[128];
        bzero(to, sizeof(to));
        
        [self encryptRSAFrom:from flen:flen to:to];
        
        return [NSData dataWithBytes:to length:sizeof(to)];
    }
    return nil;
}

#pragma mark - Decrypt

- (NSString *)rsaDecryptString:(NSString*)string
{
    NSData *data = [NSData dataWithBase64EncodedString:string];
    NSData *decryptData = [self rsaDecryptData:data];
    if(decryptData)
        return [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
    return nil;
}

- (int)decryptRSAKeyFrom:(const unsigned char *)from flen:(int)flen to:(unsigned char *)to{
    if (from != NULL && to != NULL) {
        int status = RSA_check_key(_privateRSA);
        if (!status) {
            NSLog(@"status code %i",status);
            return -1;
        }
        status =  RSA_private_decrypt(flen, from,to, _privateRSA,  RSA_PKCS1_PADDING);
        
        return status;
    }return -1;
}

- (NSData *)rsaDecryptData:(NSData*)data
{
    if (data && [data length]) {
        
        int flen = (int)[data length];
        unsigned char from[flen];
        bzero(from, sizeof(from));
        memcpy(from, [data bytes], [data length]);
        
        unsigned char to[128];
        bzero(to, sizeof(to));
        
        [self decryptRSAKeyFrom:from flen:flen to:to];
        
        return [NSData dataWithBytes:to length:sizeof(to)];
    }
    return nil;
}

#pragma mark - Sign

- (NSString *)rsaSHA1SignString:(NSString *)string
{
    if([self getPrivateRSA])
    {
        const char *msg = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int len = (int)strlen(msg);
        unsigned char *sig = (unsigned char *)malloc(256);
        unsigned int sig_len = 0;
        
        unsigned char sha1[20];
        SHA1((unsigned char *)msg, len, sha1);
        int success = 0;
        if (1 == RSA_check_key(_privateRSA))
        {
            int rsa_sign_valid = RSA_sign(NID_sha1
                                          , sha1, 20
                                          , sig, &sig_len
                                          , _privateRSA);
            if (1 == rsa_sign_valid)
            {
                success = 1;
            }
        }
        
        if(success == 1)
        {
            NSString *signStr = [[[NSData alloc] initWithBytes:sig length:sig_len] base64EncodedString];
            return signStr;
        }
    }
    return nil;
}

#pragma mark - Verify Sign

- (BOOL)rsaSHA1VerifyString:(NSString *)plainString
              withSignature:(NSString *)signString
{
    if([self getPublicRSA])
    {
        const char *msg = [plainString cStringUsingEncoding:NSUTF8StringEncoding];
        int len = (int)[plainString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        NSData *signatureData = [NSData dataWithBase64EncodedString:signString];
        unsigned char *sig = (unsigned char *)[signatureData bytes];
        unsigned int sig_len = (unsigned int)[signatureData length];
        
        unsigned char sha1[20];
        SHA1((unsigned char *)msg, len, sha1);
        
        int rsa_verify_valid = RSA_verify(NID_sha1
                                          , sha1, 20
                                          , sig, sig_len
                                          , _publicRSA);
        
        return (rsa_verify_valid == 1);
    }
    return NO;
}

#pragma mark - Lifecycle

- (void)dealloc
{
    if(_privateRSA != NULL)
        RSA_free(_privateRSA);
    if(_publicRSA != NULL)
        RSA_free(_publicRSA);
}


#pragma mark - Class Methods

static OpenSSLRSACryptor* sharedInstance = nil;

+ (OpenSSLRSACryptor*)sharedInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}
@end
