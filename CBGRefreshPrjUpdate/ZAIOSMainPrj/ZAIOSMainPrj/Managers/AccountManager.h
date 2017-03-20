//
//  AccountManager.h
//  ZAIOSMainPrj
//
//  Created by J on 15/5/13.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"
#import "AccountInfo.h"

@interface AccountManager : NSObject

@property (nonatomic, copy, readonly) Account *account;
@property (nonatomic, copy, readonly) AccountInfo *accoutInfo;

- (void)autoLogin;

- (BOOL)hasLogedIn;

- (void)saveAccount:(Account *)account;
- (void)saveAccountInfo:(AccountInfo *)info;
- (void)saveLoginInfo:(LoginInfo *)info;

+ (AccountManager *)sharedInstance;

@end
