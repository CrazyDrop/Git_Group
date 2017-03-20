//
//  ZATfdLocalCheck.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/8/12.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>
//本地录入校验，鉴于本地数据校验目前过杂乱，统一处理
@interface ZATfdLocalCheck : NSObject

//以下方法有返回值则为错误提示、当返回nil时，标识无异常

//检查用户名
+(NSString *)localCheckInputUserNameWithText:(NSString *)txt;

//检查紧急联系人姓名
+(NSString *)localCheckInputContactNameWithText:(NSString *)txt;

//检查用户手机号
+(NSString *)localCheckInputTelNumForUserWithText:(NSString *)inputPhoneNum;

//检查紧急联系人手机号
+(NSString *)localCheckInputTelNumWithText:(NSString *)txt;

//检查本地密码
+(NSString *)localCheckInputLocalPWDWithText:(NSString *)txt;

//检查关系
+(NSString *)localCheckInputContactRelationNameWithText:(NSString *)txt;

//检查暗号
+(NSString *)localCheckInputContactPWDWithText:(NSString *)txt;

//检查校验码
+(NSString *)localCheckInputMsgNumWithText:(NSString *)inputMsgNum;

//检查去做什么
+(NSString *)localCheckInputWhatToDoWithText:(NSString *)doWhat;

//取出文本中数字
+(NSString *)localInputNumberInputForTotalText:(NSString *)txt;

@end
