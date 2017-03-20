//
//  RSAEncryptor.m
//  ZAInsurance
//
//  Created by J on 15/4/30.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "RSACryptor.h"

#import <Security/Security.h>
#import "RSACryptor.h"
#import "NSString+Base64.h"
#import <CommonCrypto/CommonCrypto.h>


@implementation RSACryptor
{
    SecKeyRef publicKey;
    
    SecKeyRef privateKey;
}


- (void)dealloc
{
    if (nil != publicKey) {
        CFRelease(publicKey);
    }
    if (nil != privateKey) {
        CFRelease(privateKey);
    }
}



- (SecKeyRef)getPublicKey {
    return publicKey;
}

- (SecKeyRef)getPrivateKey {
    return privateKey;
}



- (void)loadPublicKeyFromFile:(NSString *)derFilePath
{
    NSData *derData = [[NSData alloc] initWithContentsOfFile:derFilePath];
    [self loadPublicKeyFromData:derData];
}
- (void)loadPublicKeyFromData:(NSData *)derData
{
    publicKey = [self getPublicKeyRefrenceFromeData:derData];
}

- (void)loadPrivateKeyFromFile:(NSString *)p12FilePath password:(NSString*)p12Password
{
    NSData *p12Data = [NSData dataWithContentsOfFile:p12FilePath];
    [self loadPrivateKeyFromData: p12Data password:p12Password];
}

- (void)loadPrivateKeyFromData:(NSData *)p12Data password:(NSString*)p12Password
{
    privateKey = [self getPrivateKeyRefrenceFromData: p12Data password: p12Password];
}




#pragma mark - Private Methods

- (SecKeyRef)getPublicKeyRefrenceFromeData:(NSData *)derData
{
    SecCertificateRef myCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)derData);
    if(myCertificate == nil)
        return nil;
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    SecKeyRef securityKey = SecTrustCopyPublicKey(myTrust);
    CFRelease(myCertificate);
    CFRelease(myPolicy);
    CFRelease(myTrust);
    
    return securityKey;
}


- (SecKeyRef)getPrivateKeyRefrenceFromData: (NSData*)p12Data password:(NSString*)password
{
    SecKeyRef privateKeyRef = NULL;
    NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
    [options setObject: password forKey:(__bridge id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef) p12Data, (__bridge CFDictionaryRef)options, &items);
    if (securityError == noErr && CFArrayGetCount(items) > 0) {
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
        securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
        if (securityError != noErr) {
            privateKeyRef = NULL;
        }
    }
    CFRelease(items);
    
    return privateKeyRef;
}



#pragma mark - Encrypt

- (NSString *)rsaEncryptString:(NSString*)string {
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData* encryptedData = [self rsaEncryptData: data];
    NSString* base64EncryptedString = [encryptedData base64EncodedString];
    return base64EncryptedString;
}

// 加密的大小受限于SecKeyEncrypt函数，SecKeyEncrypt要求明文和密钥的长度一致，如果要加密更长的内容，需要把内容按密钥长度分成多份，然后多次调用SecKeyEncrypt来实现
- (NSData *)rsaEncryptData:(NSData*)data {
    SecKeyRef key = [self getPublicKey];
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    size_t blockSize = cipherBufferSize - 11;       // 分段加密
    size_t blockCount = (size_t)ceil([data length] / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init] ;
    for (long i=0; i<blockCount; i++) {
        long bufferSize = MIN(blockSize,[data length] - i * blockSize);
        NSData *buffer = [data subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(key, kSecPaddingPKCS1, (const uint8_t *)[buffer bytes], [buffer length], cipherBuffer, &cipherBufferSize);
        if (status == noErr){
            NSData *encryptedBytes = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }else{
            if (cipherBuffer) {
                free(cipherBuffer);
            }
            return nil;
        }
    }
    if (cipherBuffer){
        free(cipherBuffer);
    }
    return encryptedData;
}

#pragma mark - Sign

- (NSString *)rsaSHA1SignString:(NSString *)string
{
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signData = [self rsaSHA1SignData:data];
    NSString *result = [signData base64EncodedString];
    return result;
}

- (NSData *)getHashBytes:(NSData *)plainText {
    CC_SHA1_CTX ctx;
    uint8_t * hashBytes = NULL;
    NSData * hash = nil;
    
    // Malloc a buffer to hold hash.
    hashBytes = malloc( CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t) );
    memset((void *)hashBytes, 0x0, CC_SHA1_DIGEST_LENGTH);
    // Initialize the context.
    CC_SHA1_Init(&ctx);
    // Perform the hash.
    CC_SHA1_Update(&ctx, (void *)[plainText bytes], (CC_LONG)[plainText length]);
    // Finalize the output.
    CC_SHA1_Final(hashBytes, &ctx);
    
    // Build up the SHA1 blob.
    hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)CC_SHA1_DIGEST_LENGTH];
    if (hashBytes) free(hashBytes);
    
    return hash;
}

- (NSData *)rsaSHA1SignData:(NSData *)data
{
    SecKeyRef key = [self getPrivateKey];
    
    OSStatus sanityCheck = noErr;
    NSData *signedHash = nil;
    
    uint8_t *signedHashBytes = NULL;
    size_t signedHashBytesSize = 0;
    
    signedHashBytesSize = SecKeyGetBlockSize(key);
    
    // Malloc a buffer to hold signature.
    signedHashBytes = malloc(signedHashBytesSize * sizeof(uint8_t));
    memset((void *) signedHashBytes, 0x0, signedHashBytesSize);
    
    // Sign the SHA1 hash.
    sanityCheck = SecKeyRawSign(key,
                                kSecPaddingPKCS1SHA1,
                                (const uint8_t *) [[self getHashBytes:data] bytes],
                                CC_SHA1_DIGEST_LENGTH,
                                signedHashBytes,
                                &signedHashBytesSize
                                );
    
    // Build up signed SHA1 blob.
    signedHash = [NSData dataWithBytes:(const void *) signedHashBytes length:(NSUInteger) signedHashBytesSize];
    
    if (signedHashBytes) {
        free(signedHashBytes);
    }
    
    return signedHash;
}


#pragma mark - Decrypt

-(NSString*) rsaDecryptString:(NSString*)string {
    
    NSData* data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData* decryptData = [self rsaDecryptData: data];
    NSString* result = [[NSString alloc] initWithData: decryptData encoding:NSUTF8StringEncoding];
    return result;
}

-(NSData*) rsaDecryptData:(NSData*)data {
    SecKeyRef key = [self getPrivateKey];
    size_t cipherLen = [data length];
    void *cipher = malloc(cipherLen);
    [data getBytes:cipher length:cipherLen];
    size_t plainLen = SecKeyGetBlockSize(key) - 12;
    void *plain = malloc(plainLen);
    OSStatus status = SecKeyDecrypt(key, kSecPaddingPKCS1, cipher, cipherLen, plain, &plainLen);
    
    if (status != noErr) {
        return nil;
    }
    
    NSData *decryptedData = [[NSData alloc] initWithBytes:(const void *)plain length:plainLen];
    
    return decryptedData;
}

#pragma marke - verify file SHA1

- (BOOL)rsaSHA1VerifyString:(NSString *)plainString
              withSignature:(NSString *)signString
{
    NSData *plainData = [plainString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signData = [[NSData alloc] initWithBase64EncodedString:signString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [self rsaSHA1VerifyData:plainData withSignature:signData];
}

-(BOOL) rsaSHA1VerifyData:(NSData *) plainData
            withSignature:(NSData *) signature {
    
    size_t signedHashBytesSize = SecKeyGetBlockSize([self getPublicKey]);
    const void* signedHashBytes = [signature bytes];
    
    size_t hashBytesSize = CC_SHA1_DIGEST_LENGTH;
    uint8_t* hashBytes = malloc(hashBytesSize);
    if (!CC_SHA1([plainData bytes], (CC_LONG)[plainData length], hashBytes)) {
        return NO;
    }
    
    OSStatus status = SecKeyRawVerify(publicKey,
                                      kSecPaddingPKCS1SHA1,
                                      hashBytes,
                                      hashBytesSize,
                                      signedHashBytes,
                                      signedHashBytesSize);
    
    return status == errSecSuccess;
}

#pragma mark - Class Methods

static RSACryptor* sharedInstance = nil;

+(RSACryptor*) sharedInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}
@end