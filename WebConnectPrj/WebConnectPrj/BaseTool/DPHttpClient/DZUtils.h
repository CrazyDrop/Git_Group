//
//  DZUtils.h
//  DiscuzAppFramework
//
//  Created by doopcl-mac on 12-10-18.
//  Copyright (c) 2012年 Lone Choy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DZ_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

@interface DZUtils : NSObject

+ (void)vibrate;

+(void)startNoticeWithLocalUrl:(NSString *)localUrl;
+(BOOL)equipServerIdCheckResultWithSubServerId:(NSInteger)serverId;

+(NSString *)detailNumberStringSubFromBottomCombineStr:(NSString *)str;
+(NSString *)detailNumberStringSubFromHeaderCombineStr:(NSString *)detailCopy;

+(BOOL)checkSubCharacterIsNumberString:(NSString *)last;

+(NSString *)DESEncryptAndURLEncodeWithWarningID:(NSString *)warnid;

+(NSString *)currentLoginToken;

+ (BOOL)localWarningStateCheckIsNone;

+ (NSString *)lastestAddressRecordId;

+(NSString *)currentLoginToken;

+(NSAttributedString *)attributedStringFromPlaceHoldText:(NSString *)txt;

+(void)localSoundTimeNotificationWithAfterSecond;

+(void)localTimeNotificationAppendedWithTimeLength:(NSTimeInterval)second;

+(void)localTimeNotificationCancel;

+(BOOL)deviceWebConnectEnableCheck;

+(void)localSaveObject:(id)obj withKeyStr:(NSString *)str;
+(id)localSaveObjectFromLocalSaveKeyStr:(NSString *)str;


+(UIView *)ToolCustomLineView;

+(void)saveCurrentTimingWithEndTime:(NSDate *)endTime andTotalSecond:(NSInteger)second;
+(NSTimeInterval)endTimeSecondNeedContinue;
+(BOOL)endTimeNeedFinishedPWD;

+(void)saveCurrentPWDState:(BOOL)show;
+(BOOL)currentPWDShowState;

+(BOOL)checkAndNoticeErrorWithSignal:(id)obj;
+(BOOL)checkAndNoticeErrorWithSignal:(id)obj andNoticeBlock:(void(^)(BOOL netEnable))block;

+ (NSString *) platformString;

+(NSInteger)checkErrorCodeWithBackUrlString:(NSString *)url;

+(UIViewController *)currentRootViewController;

+(NSString*)currentAppBundleVersion;
+(NSString*)currentAppBundleShortVersion;

+ (NSString *)currentDeviceIdentifer;

+ (NSDateFormatter *)sharedDateFormatter;

+ (NSString *)decodeFromPercentEscapeString: (NSString *) input;

+ (BOOL)isNull:(id)obj;

+ (BOOL)isValidateString:(id)obj;

+ (BOOL)isValidateDictionary:(id)obj;

+ (BOOL)isValidateArray:(id)obj;

+ (BOOL)stringContainsWithString:(NSString *)str key:(NSString *)keyStr;


//未验证
+ (NSString *)urlEncode:(NSString *)str stringEncode:(CFStringEncoding)encode;

+ (NSString *)urlEncodeValue:(NSString *)str;

+ (NSString *)urlDecodeValue:(NSString *)str;

+ (NSString *)getMimeTypeFromFile:(NSString *)filePath;

+ (float)OSVersion;

+ (NSString *)getString:(id)obj safetyValue:(NSString *)v;

+ (UIColor *)colorWithHex:(NSString *)colorStr;

+ (int)localTimeSpan;


+ (UIImage *)ImageStretchedWithName:(NSString *)name top:(NSInteger)t left:(NSInteger)l bottom:(NSInteger)b right:(NSInteger)r;

+ (NSString *)stringFromProjFileWithName:(NSString *)file;

+ (NSString *)htmlDecode:(NSString *)string;

+(float)getCenterXWithSuperViewWidth:(float)superWidth subViewWidth:(float)subWidth;

+(float)getCenterYWithSuperViewHeight:(float)superHeight subViewHeight:(float)subHeight;

+(float)getLeftViewEndX:(UIView *)left;

//+ (NSInteger)getInt:(id)obj safetyValue:(NSInteger)v;
//Get count of days of one Month frome one Year
+ (NSInteger)getMaxDaysFromYear:(NSInteger)year month:(NSInteger)month;

+(NSString *)getRequsetURL:(NSString *)s page:(NSString *)p;


+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (BOOL)checkWebJSONDataState:(id)obj andNoticeErrorInfo:(BOOL)notice;

+(void)noticeCustomerWithShowText:(NSString *)text;

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

+(int)charNumber:(NSString*)strtemp ;

+(void)userLogout;

+(BOOL)userIsLogin;

+(void)getUserInfo;

+(void)saveUserInfnfo:(NSDictionary *)user;

+(NSString *)encodedString:(NSString *)t;

//+(void)aliPayOrder:(Order*)orderinfo;

+(void)aliPayOrderWithSing:(NSString *)orderinfo;

+(void)showBigImageWithPhotoURLs:(NSArray *)array smallImageViews:(NSArray *)views andTapedIndex:(NSInteger)tapedIndex;
+(void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName;

+(void)saveUserInfnfo:(NSString *)key value:(NSString *)value;
//wechat share
+(void)sendImageContentWithScene:(int)_scene imgae:(UIImage *)img;

+(void)wechatPayOrderWithSing:(NSDictionary *)orderinfo;
@end
