//
//  NSString+DESEncrypt.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/2/24.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>


//- (NSData *) DESEncryptedDataUsingKey: (id) key error: (NSError **) error;
//- (NSData *) decryptedDESDataUsingKey: (id) key error: (NSError **) error;
@interface NSString (DESEncrypt)

//错误返回nil
-(NSString *)DESEncryptedWithKeyString:(NSString *)key;

//错误返回nil
-(NSString *)DESDecryptedDESDataUsingKey:(NSString *)key;

@end
