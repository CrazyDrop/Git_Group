//
//  AccountManager.m
//  ZAIOSMainPrj
//
//  Created by J on 15/5/13.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "AccountManager.h"
#import "AESCryptor.h"
#import "FileCacheManager.h"

#define AccountSaveKey @"Account"
#define AccountInfoSaveKey @"AccountInfo"
#define LoginInfoSaveKey @"LoginInfo"
#define TokenSavePassword @"ZEl5Nryh"
#define LoginInfoSavePassword @"blW8KGPr"

@interface AccountManager()
@property (nonatomic, strong) RefreshTokenModel *refreshTokenModel;
@property (nonatomic, strong) LoginInfo *loginInfo;
@property (nonatomic, strong) LoginModel *loginModel;
@end

@implementation AccountManager

@synthesize account = _account;
@synthesize accoutInfo = _accoutInfo;

#pragma mark - Notification

- (void)tokenExpiredNotification:(NSNotification *)notif
{
    [self saveAccount:nil];
    [self autoLogin];
}

#pragma mark - Mothods

- (void)autoLogin
{
    LoginInfo *info = [self getLoginInfo];
    if(info)
    {
        if(info.otherToken != nil && ![info.otherToken isEqualToString:@""])
        {
            self.loginModel.otherToken = info.otherToken;
            self.loginModel.otherTokenType = [info.otherTokenType integerValue];
            self.loginModel.isOtherLogin = YES;
        }else{
            self.loginModel.phoneNo = info.phoneNo;
            self.loginModel.password = info.password;
            self.loginModel.isOtherLogin = NO;
        }
        [self.loginModel sendRequest];
    }
}

- (BOOL)hasLogedIn
{
    return ([self account] != nil);
}

- (Account *)account
{
    if(_account == nil)
    {
        Account *savedAccount = [FileCacheManager objectForKey:AccountSaveKey];
        NSString *decryptToken = [AESCryptor decrypt:savedAccount.token password:TokenSavePassword];
        savedAccount.token = decryptToken;
        _account = savedAccount;
    }
    return _account;
}

- (void)saveAccount:(Account *)account;
{
    if(_account)
        _account = nil;
    _account = account;
    if(account == nil)
    {
//            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:AccountSaveKey];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        FileCacheManager *fm = [FileCacheManager sharedInstance];
        [fm saveObject:nil forKey:AccountSaveKey];
    }else{
        Account *ac = [account copy];
        NSString *encryptToken = [AESCryptor encrypt:ac.token password:TokenSavePassword];
        ac.token = encryptToken;
//            NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:ac];
//            [[NSUserDefaults standardUserDefaults] setObject:saveData forKey:AccountSaveKey];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        
        FileCacheManager *fm = [FileCacheManager sharedInstance];
        [fm saveObject:ac forKey:AccountSaveKey];
    }
}

- (AccountInfo *)accoutInfo
{
    if(_accoutInfo == nil)
    {
        Account *savedAccount = [FileCacheManager objectForKey:AccountInfoSaveKey];
        _account = savedAccount;
    }
    return _accoutInfo;
}

- (void)saveAccountInfo:(AccountInfo *)info;
{
    if(_accoutInfo)
        _accoutInfo = nil;
    _accoutInfo = info;
    if(info == nil)
    {
        FileCacheManager *fm = [FileCacheManager sharedInstance];
        [fm saveObject:nil forKey:AccountInfoSaveKey];
    }else{
        AccountInfo *ai = [info copy];
        
        FileCacheManager *fm = [FileCacheManager sharedInstance];
        [fm saveObject:ai forKey:AccountInfoSaveKey];
    }
}

- (void)saveLoginInfo:(LoginInfo *)info
{
    self.loginInfo = info;
    LoginInfo *savedInfo = [info copy];
    NSString *encryptPhoneNo = [AESCryptor encrypt:savedInfo.phoneNo password:LoginInfoSavePassword];
    savedInfo.phoneNo = encryptPhoneNo;
    NSString *encryptPassword = [AESCryptor encrypt:savedInfo.password password:LoginInfoSavePassword];
    savedInfo.password = encryptPassword;
    NSString *encryptToken = [AESCryptor encrypt:savedInfo.otherToken password:LoginInfoSavePassword];
    savedInfo.otherToken = encryptToken;
    
    FileCacheManager *fm = [FileCacheManager sharedInstance];
    [fm saveObject:savedInfo forKey:LoginInfoSaveKey];
}

- (LoginInfo *)getLoginInfo
{
    if(self.loginInfo == nil)
    {
        LoginInfo *savedInfo = [FileCacheManager objectForKey:LoginInfoSaveKey];
        
        NSString *decryptPhoneNo = [AESCryptor decrypt:savedInfo.phoneNo password:LoginInfoSavePassword];
        savedInfo.phoneNo = decryptPhoneNo;
        NSString *decryptPassword = [AESCryptor decrypt:savedInfo.password password:LoginInfoSavePassword];
        savedInfo.password = decryptPassword;
        NSString *decrptToken = [AESCryptor decrypt:savedInfo.otherToken password:LoginInfoSavePassword];
        savedInfo.otherToken = decrptToken;
        
        self.loginInfo = savedInfo;
        
    }
    return self.loginInfo;
}


static AccountManager *sharedInstance = nil;
+ (AccountManager *)sharedInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenExpiredNotification:)
                                                     name:TokenExpiredNotification
                                                   object:nil];
        self.loginModel = [[LoginModel alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
