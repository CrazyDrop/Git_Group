//
//  DZUtils.m
//  DiscuzAppFramework
//
//  Created by doopcl-mac on 12-10-18.
//  Copyright (c) 2012年 Lone Choy. All rights reserved.
//

#import "DZUtils.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
//#import "WXApi.h"
//#import "WXApiObject.h"
//#import "UserInfo.h"
//#import <CommonCrypto/CommonDigest.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import <sys/utsname.h>
#import "SFHFKeychainUtils.h"
//#import <AlipaySDK/AlipaySDK.h>
//#import "ZAMMMaterialDesignSpinner.h"
//#import "NSString+DESEncrypt.h"
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation DZUtils
+(void)startNoticeWithLocalUrl:(NSString *)localUrl
{
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(!model.isAlarm) return;
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state == UIApplicationStateBackground)
    {
        [DZUtils localSoundTimeNotificationWithLocalUrl:localUrl];
        return;
    }
    
    [DZUtils vibrate];
}

+ (void)vibrate
{
    AudioServicesPlaySystemSound(1320);
    //    1327
}

+(BOOL)equipServerIdCheckResultWithSubServerId:(NSInteger)serverId
{
    BOOL enable = YES;
    if(serverId == 45)
    {
        enable = NO;
    }else{
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        NSInteger minId = total.minServerId;
        if(serverId >= minId){
            enable = NO;
        }
    }
    return enable;
}

+(UIViewController *)currentRootViewController
{
    AppDelegate * dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return dele.window.rootViewController;
}
+(NSString *)detailNumberStringSubFromBottomCombineStr:(NSString *)detailCopy
{
//循环遍历出数字部分
    NSMutableString * checkStr = [NSMutableString string];//数字字符
    //由后向前，取到非数字字符截止
    NSString * shortString = detailCopy;
    NSString * replace = detailCopy;
    NSString * sepTag = @"_";
    
    for (NSInteger index = 0; index < [shortString length]; index ++ )
    {
        NSInteger number = [shortString length] - index - 1;
        NSString * eve = [replace substringWithRange:NSMakeRange(number, 1)];
        BOOL realNumber = [DZUtils checkSubCharacterIsNumberString:eve];
        if(realNumber || [eve isEqualToString:sepTag])
        {
            [checkStr insertString:eve atIndex:0];
        }else{
            break;
        }
    }
    return checkStr;
}
+(NSString *)detailNumberStringSubFromHeaderCombineStr:(NSString *)detailCopy
{
    //循环遍历出数字部分
    NSMutableString * checkStr = [NSMutableString string];//数字字符
    //由后向前，取到非数字字符截止
    NSString * shortString = detailCopy;
    NSString * replace = detailCopy;
    NSString * sepTag = @"_";
    
    for (NSInteger index = 0; index < [shortString length]; index ++ )
    {
        NSInteger number = index;
        NSString * eve = [replace substringWithRange:NSMakeRange(number, 1)];
        BOOL realNumber = [DZUtils checkSubCharacterIsNumberString:eve];
        if(realNumber || [eve isEqualToString:sepTag])
        {
            [checkStr appendString:eve];
        }else{
            break;
        }
    }
    return checkStr;
}


+(BOOL)checkSubCharacterIsNumberString:(NSString *)last
{
    NSScanner* scan = [NSScanner scannerWithString:last];
    int val;
    BOOL numCheck = [scan scanInt:&val] && [scan isAtEnd];
    if(!numCheck){
        
    }
    return numCheck;
}
+ (UIColor *)colorWithHex:(NSString *)colorStr
{
    NSString *cString = [[colorStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor clearColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    // instruments会提示这里由内存溢出，不用管
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (BOOL)isValidateArray:(id)obj
{
    if ([DZUtils isNull:obj]) {
        return NO;
    }
    
    if (![obj isKindOfClass:[NSArray class]]) {
        return NO;
    }
    
    if ([obj count] <= 0) {
        return NO;
    }
    
    return YES;
}
+ (BOOL)isNull:(id)obj
{
    return !obj || (NSNull *)obj == [NSNull null];
}

+ (BOOL)isValidateString:(id)obj
{
    if ([DZUtils isNull:obj]) {
        return NO;
    }
    
    if (![obj isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    if ([obj isEqualToString:@""]) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isValidateDictionary:(id)obj
{
    if ([DZUtils isNull:obj]) {
        return NO;
    }
    
    if (![obj isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    if ([obj count] <= 0) {
        return NO;
    }
    
    return YES;
}

+(BOOL)deviceWebConnectEnableCheck
{
    BOOL connect = [[AFNetworkReachabilityManager sharedManager] isReachable];
    return connect;
}
+(void)noticeCustomerWithShowText:(NSString *)text
{
    AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView * showView = delegate.window;
    
    MBProgressHUD * hud = (MBProgressHUD *)[showView viewWithTag:9999];
    if(hud)
    {
        //隐藏当前展示
        hud.minShowTime = 0;
        [hud hide:YES];
        
    }
    
    //进行提示
    if(!hud)
    {
        hud = [MBProgressHUD showHUDAddedTo:showView animated:true];
        hud.tag = 9999;
    }
    
    if([text length]>15){
        hud.detailsLabelText= text;
        hud.detailsLabelFont = hud.labelFont;
    }else{
        hud.labelText= text;
    }
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    [hud show:YES];
    [hud hide:YES afterDelay:1];
}
+(void)localSoundTimeNotificationWithLocalUrl:(NSString *)url
{
    UILocalNotification * noti = [[self class] createLocalNotificationForFindIphoneWithTimeDelay:0 andUrl:url];
    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
}

+(void)localSoundTimeNotificationWithAfterSecond
{
    UILocalNotification * noti = [[self class] createLocalNotificationForFindIphoneWithTimeDelay:0 andUrl:nil];
    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
}
+(UILocalNotification *)createLocalNotificationForFindIphoneWithTimeDelay:(NSTimeInterval)delay andUrl:(NSString *)url
{
    NSTimeInterval second = delay;
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //设置本地通知的触发时间（如果要立即触发，无需设置），这里设置为20妙后
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:second];
    //设置本地通知的时区
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //设置通知的内容
    localNotification.alertBody = @"设备已触发找手机功能";
    //设置通知动作按钮的标题
    localNotification.alertAction = @"打开查看";
    //设置提醒的声音，可以自己添加声音文件，这里设置为默认提示声
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setValue:NSLOCAL_NOTIFICATION_IDENTIFIER forKey:@"id"];
    [infoDic setValue:[NSString stringWithFormat:@"%f",second] forKey:@"time"];
    [infoDic setValue:url forKey:@"weburl"];
    localNotification.userInfo = infoDic;
    localNotification.soundName = @"2015-12-09_17-41-23_1.m4r";
    return localNotification;
}
+(UIView *)ToolCustomLineView
{
    UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    aView.backgroundColor = Custom_Gray_Line_Color;
    return aView;
}

/**
+(NSString *)DESEncryptAndURLEncodeWithWarningID:(NSString *)warnid
{
    if(!warnid || [warnid length]==0) return nil;
    
    NSString * key = @"Za16PApa";
    NSString * des = [warnid DESEncryptedWithKeyString:key];
    NSString * urlStr = [des URLEncoding];
    
    return urlStr;
}

+ (BOOL)localWarningStateCheckIsNone
{
    //本地预警不存在
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    id info = total.timeModel;
    if(!info)
    {
        return YES;
    }
    return NO;
}

+ (NSString *)lastestAddressRecordId
{
    NSString * preStr = [SFHFKeychainUtils getKeyStringFromUtilsWithKeyString:NSUSERDEFAULT_ADDRESS_RECORD_IDENTIFIER];
    NSString * defautStr = [[NSUserDefaults standardUserDefaults] valueForKey:NSUSERDEFAULT_ADDRESS_RECORD_IDENTIFIER];
    
    if(!defautStr)
    {
        return preStr;
    }
    
    if([defautStr isEqualToString:preStr])
    {
        return preStr;
    }
    
    return defautStr;
}

+(NSString *)currentLoginToken
{
    return [[ZALocalStateTotalModel currentLocalStateModel] token];
}

+(NSAttributedString *)attributedStringFromPlaceHoldText:(NSString *)txt
{
    if (!txt||[txt length]==0)
    {
        return nil;
    }
    
    NSAttributedString * attStr = [[NSAttributedString alloc] initWithString:txt attributes:@{NSForegroundColorAttributeName:[DZUtils colorWithHex:@"CCCCD0"]}];
    return attStr;
}
+(void)localSoundTimeNotificationWithAfterSecond
{
    NSTimeInterval second = 5;
    UILocalNotification * localNotification = [[self class] localNotificationForTimeEndWithTimeLength:second];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}
+(void)localTimeNotificationAppendedWithTimeLength:(NSTimeInterval)second
{
    UILocalNotification * localNotification = [[self class] localNotificationForTimeEndWithTimeLength:second];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    if(second>60*3)
    {
        UILocalNotification * localNotification = [[self class] localNotificationNoticeBeforeWithTimeLength:second];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }

}
+(UILocalNotification *)localNotificationNoticeBeforeWithTimeLength:(NSTimeInterval )total
{
    NSTimeInterval second = total - 60 * 3;
    if(second<=0) return nil;
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:second];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = @"本次定时防护还有3分钟将启动预警，如已安全请结束防护。";
    localNotification.alertAction = @"打开查看";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setValue:NSLOCAL_NOTIFICATION_IDENTIFIER_BEFORE forKey:@"id"];
    [infoDic setValue:[NSString stringWithFormat:@"%f",second] forKey:@"time"];
    localNotification.userInfo = infoDic;
    localNotification.soundName = @"2015-12-09_17-41-23_1.m4r";
    return localNotification;
}
+(UILocalNotification *)localNotificationForTimeEndWithTimeLength:(NSTimeInterval )second
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //设置本地通知的触发时间（如果要立即触发，无需设置），这里设置为20妙后
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:second];
    //设置本地通知的时区
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //设置通知的内容
    localNotification.alertBody = @"您启动的预警倒计时已经触发,如已安全请尽快关闭";
    //设置通知动作按钮的标题
    localNotification.alertAction = @"打开查看";
    //设置提醒的声音，可以自己添加声音文件，这里设置为默认提示声
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setValue:NSLOCAL_NOTIFICATION_IDENTIFIER forKey:@"id"];
    [infoDic setValue:[NSString stringWithFormat:@"%f",second] forKey:@"time"];
    localNotification.userInfo = infoDic;
    localNotification.soundName = @"2015-12-09_17-41-23_1.m4r";
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    1320

    //在规定的日期触发通知
    return localNotification;
}

+(void)localTimeNotificationCancel
{
    NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *localNotification  in array)
    {
        NSDictionary * dic = [localNotification userInfo];
        NSString * localId = [dic valueForKey:@"id"];
        if([localId isEqualToString:NSLOCAL_NOTIFICATION_IDENTIFIER]||[localId isEqualToString:NSLOCAL_NOTIFICATION_IDENTIFIER_BEFORE])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
}



+(void)localSaveObject:(id)obj withKeyStr:(NSString *)str
{
    if(!str||[str length]==0) return;
    //新增版本，使用新数据判定
//    [SFHFKeychainUtils keyUtilsSaveString:obj withKeyString:str];

    NSUserDefaults * stand = [[NSUserDefaults alloc] initWithSuiteName:USERDEFAULT_SUIT_NAME_PAPA];
    if(obj){
        [stand setObject:obj forKey:str];
    }else{
        [stand removeObjectForKey:str];
    }
    [stand synchronize];
}
+(id)localSaveObjectFromLocalSaveKeyStr:(NSString *)str{
    id object = nil;
    if(!str||[str length]==0) return object;
    NSUserDefaults * stand = [[NSUserDefaults alloc] initWithSuiteName:USERDEFAULT_SUIT_NAME_PAPA];
    object = [stand objectForKey:str];
//
//    object = [SFHFKeychainUtils getKeyStringFromUtilsWithKeyString:str];
    return object;
}

+(void)saveCurrentTimingWithEndTime:(NSDate *)endTime andTotalSecond:(NSInteger)second
{
    ZALocalStateModel * model = [ZALocalStateModel currentLocalStateModel];
    model.endDate = endTime;
    model.totalTime = second;
    [model localSave];
}
+(NSTimeInterval)endTimeSecondNeedContinue
{
    //截止时间，当前时间
    ZALocalStateModel * model = [ZALocalStateModel currentLocalStateModel];
    if(!model.endDate) return 0;
    
    NSDate * date = model.endDate;
    NSTimeInterval count = [date timeIntervalSinceNow];
    return count;
}
+(BOOL)endTimeNeedFinishedPWD
{
    ZALocalStateModel * model = [ZALocalStateModel currentLocalStateModel];
    if(!model.endDate) return NO;
    
    NSDate * date = model.endDate;
    NSDate * now = [NSDate date];
    NSComparisonResult result = [now compare:date];

    return result == NSOrderedDescending;
    return YES;
}

//应用重新安装或更新后，倒计时数据和密码页状态清空
+(void)saveCurrentPWDState:(BOOL)show
{
    ZALocalStateModel * model = [ZALocalStateModel currentLocalStateModel];
    model.showPWD = show;
    [model localSave];
}
+(BOOL)currentPWDShowState
{
    ZALocalStateModel * model = [ZALocalStateModel currentLocalStateModel];
    return model.showPWD;
}

//检查，并提示，针对网络异常统一提示的可使用
+(BOOL)checkAndNoticeErrorWithSignal:(id)obj
{
    void(^NoticeBlock)(BOOL) = ^(BOOL network)
    {
        SamuraiSignal * signal = (SamuraiSignal *)obj;
        ZAHTTPResponse *resp = signal.object;
        
        NSString * str = resp.returnMsg;
        if(!str)
        {
            str = kAppNone_Service_Error;
            if(!network)
            {
                str = @"当前无网络，请稍后再试";
            }
        }
        [DZUtils noticeCustomerWithShowText:str];
    };
    
    return [[self class] checkAndNoticeErrorWithSignal:obj andNoticeBlock:NoticeBlock];
    
    return NO;
}
+(BOOL)checkAndNoticeErrorWithSignal:(id)obj andNoticeBlock:(void(^)(BOOL net))block
{
    SamuraiSignal * signal = (SamuraiSignal *)obj;
    ZAHTTPResponse *resp = signal.object;
    if(resp&&[resp.returnCode intValue] == HTTPReturnSuccess)
    {
        return YES;
    }
    
    //token失效
    if(resp && [resp.returnCode integerValue] == HTTPReturnTokenExpire)
    {
        //发送token失效通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TOKEN_EXPIRE_STATE object:nil];
        return NO;
    }
    
    BOOL netWork = [[self class] deviceWebConnectEnableCheck];
    if(block){
         block(netWork);   
    }
    
    return NO;
}



//可通过苹果review
+ (NSString*)getDeviceVersion
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return platform;
}

+ (NSString *) platformString
{
    NSString *platform = [self getDeviceVersion];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

+ (NSString *)currentDeviceIdentifer
{
    NSString * preStr = [SFHFKeychainUtils commonStaticAppDeviceId];
    NSString * defautStr = [[NSUserDefaults standardUserDefaults] valueForKey:NSUSERDEFAULT_CHECK_DEVICEID_IDENTIFIER];
    
    if(!defautStr)
    {
        return preStr;
    }
    
    if([defautStr isEqualToString:preStr])
    {
        return preStr;
    }
    
    return defautStr;
}


+(NSInteger)checkErrorCodeWithBackUrlString:(NSString *)url
{
    NSString * sepStr = @"&";
    NSString * error = @"error=";
    NSArray * arr = [url componentsSeparatedByString:sepStr];
    
    NSInteger errorNum = NSNotFound;
    for (NSString * eve in arr)
    {
        if([eve hasPrefix:error])
        {
            NSString * num = [eve stringByReplacingOccurrencesOfString:error withString:@""];
            errorNum = [num intValue];
            break;
        }
    }
    return errorNum;
}



+(NSString *)currentAppBundleVersion{
    static NSString* bundleVersion;
    static dispatch_once_t onceTokenV;
    dispatch_once(&onceTokenV, ^{
        NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
        bundleVersion =[infoDict objectForKey:@"CFBundleVersion"];
    });
    return bundleVersion;
}
+(NSString *)currentAppBundleShortVersion{
    static NSString* bundleShortVersion;
    static dispatch_once_t onceTokenShort;
    dispatch_once(&onceTokenShort, ^{
        NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
        bundleShortVersion =[infoDict objectForKey:@"CFBundleShortVersionString"];
    });
    return bundleShortVersion;
}

+ (NSDateFormatter *)sharedDateFormatter
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    return dateFormatter;
}

+ (NSString *)md5:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+ (NSString *)genNonceStr
{
    return [self md5:[NSString stringWithFormat:@"%d", arc4random() % 10000]];
}


+(float)getCenterXWithSuperViewWidth:(float)superWidth subViewWidth:(float)subWidth
{
    return superWidth/2 - subWidth/2;
}

+(float)getCenterYWithSuperViewHeight:(float)superHeight subViewHeight:(float)subHeight
{
    return superHeight/2 - subHeight/2;
}

+(float)getLeftViewEndX:(UIView *)left
{
    return left.frame.origin.x + left.frame.size.width;
}

+ (NSString *)urlEncodeValue:(NSString *)str
{
    return [self urlEncode:str stringEncode:kCFStringEncodingUTF8];
}

+ (NSString *)urlDecodeValue:(NSString *)str
{
    return [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}



+ (NSString *)getMimeTypeFromFile:(NSString *)filePath
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]];
    
    NSError *error;
    NSURLResponse*response;
    
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
    
    return [response MIMEType];
}

+ (BOOL)stringContainsWithString:(NSString *)str key:(NSString *)keyStr
{
    NSRange textRange = [str rangeOfString:keyStr];
    return textRange.location != NSNotFound;
}

+ (float)OSVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (NSString *)getString:(id)obj safetyValue:(NSString *)v
{
    return [DZUtils isValidateString:obj] ? obj : v;
}

// 获取时间戳
+(NSString *)genTimeStamp
{
    return [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
}

+ (int)localTimeSpan
{
    return (int)round([[NSDate date] timeIntervalSince1970]);
}

+ (UIImage *)ImageStretchedWithName:(NSString *)name top:(NSInteger)t left:(NSInteger)l bottom:(NSInteger)b right:(NSInteger)r
{
    return [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(t, l, b, r)];
}

+ (NSString *)stringFromProjFileWithName:(NSString *)file
{
    NSString *str = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:@"txt"]
                                               encoding:NSUTF8StringEncoding error:NULL];
    
    return str;
}

+ (NSString *)htmlDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&'"];
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"&#039;" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"&lt" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    return string;
}

//+ (BOOL)isWifiEnable
//{
//    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
//}
+ (NSInteger)getMaxDaysFromYear:(NSInteger)year month:(NSInteger)month{
    NSInteger day = 0;
    if(month>12 || month<1)
        NSLog(@"输入有误!");
    else
    {
        if(month==2){
            if((year%4==0&&year%100!=0)||year%400==0){
                NSLog(@"该月有29天");
                day = 29;
            }else{
                NSLog(@"该月有28天");
                day = 28;
            }
            
        }else{
            if(month==1||month==3||month==5||month==7||month==8||month==10||month==12){
                day = 31;
            }else{
                day = 30;
            }
        }
    }
    return day;
}

+(NSString *)getRequsetURL:(NSString *)s page:(NSString *)p
{
    NSString *url;
    NSString *a = [NSString stringWithFormat:@"%@%@?user_id=%@&token=%@",URL_HEAD,s,[UserInfo sharedUser].userId,[UserInfo sharedUser].userToken];
    if (p.intValue != 0) {
        url = [NSString stringWithFormat:@"%@&page=%@",a,p];
    }else{
        url = a;
    }
    return  url;
}


+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+ (BOOL)checkWebJSONDataState:(id)obj andNoticeErrorInfo:(BOOL)notice{
    NSString * errorInfo = nil;
    NSString * state = nil;
    if([DZUtils isValidateDictionary:obj])
    {
        errorInfo = obj[@"info"];
        state = obj[@"state"];
    }
    
    if([state intValue]==1) return YES;
    if(notice)
    {
        if(![DZUtils isValidateString:errorInfo])
        {
            errorInfo = @"获取info失败";
        }
        
        [[self class] noticeCustomerWithShowText:errorInfo];
    }

    return NO;
}

+(int)charNumber:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

+(void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData* imageData = UIImagePNGRepresentation(tempImage);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    // Now we get the full path to the file
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    // and then we write it out
    [imageData writeToFile:fullPathToFile atomically:NO];
}

+(BOOL)userIsLogin
{
    [DZUtils getUserInfo];
    return [DZUtils isValidateString:[UserInfo sharedUser].userId];
}

+(void)userLogout
{
     NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    //添加数据到 user defaults:
    [accountDefaults setValue:@""forKey:@"token"];
    [accountDefaults setValue:@"" forKey:@"user_img"];
    [accountDefaults setValue:@"" forKey:@"user_id"];
    [accountDefaults setValue:@"" forKey:@"phone"];
    [accountDefaults setValue:@"" forKey:@"username"];
    // 把属性置空
    [self getUserInfo];
}

+(void)getUserInfo
{
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
    [UserInfo sharedUser].useImg = [accountDefaults objectForKey:@"user_img"];
    [UserInfo sharedUser].userId = [accountDefaults objectForKey:@"user_id"];
    [UserInfo sharedUser].userToken = [accountDefaults objectForKey:@"token"];
    [UserInfo sharedUser].phone = [accountDefaults objectForKey:@"phone"];
    [UserInfo sharedUser].username = [accountDefaults objectForKey:@"username"];
}

+(void)saveUserInfnfo:(NSDictionary *)user
{
   NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    
   //添加数据到 user defaults:
    [accountDefaults setValue:user[@"token"]forKey:@"token"];
    [accountDefaults setValue:user[@"user_img"] forKey:@"user_img"];
    [accountDefaults setValue:user[@"user_id"] forKey:@"user_id"];
    [accountDefaults setValue:user[@"phone"] forKey:@"phone"];
    [accountDefaults setValue:user[@"username"] forKey:@"username"];
}

+(void)saveUserInfnfo:(NSString *)key value:(NSString *)value
{
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    //添加数据到 user defaults:
    [accountDefaults setValue:value forKey:key];
}

+(NSString *)encodedString:(NSString *)t
{
   NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)t, NULL, NULL,  kCFStringEncodingUTF8 ));
    return encodedString;
}

+(void)wechatPayOrderWithSing:(NSDictionary *)orderinfo
{
    NSDictionary *payinfo = orderinfo[@"data"][@"service_sign"];
 
    PayReq *request = [[PayReq alloc] init];
    request.openID = @"wxea9e84e29aa13ae3";
    request.partnerId = payinfo[@"partnerId"];
    request.prepayId = payinfo[@"prepayId"];
    request.package = @"Sign=WXPay";
    request.nonceStr = payinfo[@"nonceStr"];
    NSString *timeStamp = payinfo[@"timeStamp"];
    request.timeStamp = [timeStamp intValue];
    request.sign = payinfo[@"ios_sign"];
    
//    [WXApi safeSendReq:request];
}

+(void)aliPayOrderWithSing:(NSString *)orderinfo
{
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"photography2";
    if (orderinfo != nil) {

        [[AlipaySDK defaultService] payOrder:orderinfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
}

+ (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"/"
                               withString:@"%"
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(void)showBigImageWithPhotoURLs:(NSArray *)array smallImageViews:(NSArray *)views andTapedIndex:(NSInteger)tapedIndex
{
    if(!array||[array count]==0) return;
    if(!views||[views count]==0) return;
    if([array count]!=[views count]) return;
    if([array count]<=tapedIndex) return;
    
//    NSMutableArray *myphotos = [NSMutableArray new];
//    // 一个MJPhoto对应一张显示的图片
//    for (int i=0;i<array.count;i++)
//    {
//        NSString * url = [array objectAtIndex:i];
//        UIImageView * imgView = nil;
//        if([views count]>i)
//        {
//            imgView = [views objectAtIndex:i];
//        }
//        MJPhoto *mjphoto = [[MJPhoto alloc] init];
//        mjphoto.srcImageView = imgView; // 来源于哪个UIImageView
//        mjphoto.url = [NSURL URLWithString:url]; // 图片路径;
//        [myphotos addObject:mjphoto];
//    }
//    
//    // 2.显示相册
//    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
//    browser.currentPhotoIndex = tapedIndex; // 弹出相册时显示的第一张图片是？
//    browser.photos = myphotos; // 设置所有的图片
//    [browser show];
}

+(void)sendImageContentWithScene:(int)_scene imgae:(UIImage *)img
{
    WXMediaMessage *message = [WXMediaMessage message];
  
    img =[DZUtils scaleToSize:img size:CGSizeMake(120, 120)];
    [message setThumbImage:img];
    NSData * data = UIImageJPEGRepresentation(img, 1.0);
    
    if(!data){
        data = UIImagePNGRepresentation(img);
    }
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = data;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    [WXApi sendReq:req];
}

**/
@end
