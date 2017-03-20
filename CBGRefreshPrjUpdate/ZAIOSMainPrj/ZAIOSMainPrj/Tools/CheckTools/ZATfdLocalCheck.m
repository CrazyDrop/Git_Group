//
//  ZATfdLocalCheck.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/8/12.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZATfdLocalCheck.h"

@implementation ZATfdLocalCheck

//检查用户名
+(NSString *)localCheckInputUserNameWithText:(NSString *)inputName{
    NSString * result = nil;
    
    //数据校验
    if(!inputName||[inputName length]==0)
    {
        NSString * errorStr = @"姓名不能为空";
        return errorStr;
    }
    
    NSString * name = [inputName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([name length]<2||[name length]>32)
    {
        NSString * errorStr = @"姓名字数应在2-32位之间";
        return errorStr;
    }
    
    if([name length]==0)
    {
        NSString * errorStr = @"用户名不能为空";
        return errorStr;
    }
    
    //inputName换为name，即可允许有空格
    if([name stringContainSpecialCharacters])
    {
        NSString * errorStr = @"用户名不能包含特殊字符";
        return errorStr;
    }
    
    return result;
}

//检查紧急联系人姓名
+(NSString *)localCheckInputContactNameWithText:(NSString *)contactName{
    NSString * result = nil;
    
    //数据校验
    if(!contactName||[contactName length]==0)
    {
        NSString * errorStr = @"请输入联系人姓名";
        return errorStr;
    }
    
    NSString * name = [contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([name length]<2||[name length]>32)
    {
        NSString * errorStr = @"姓名字数应在2-32位之间";
        return errorStr;
    }
    
    if([name length]==0)
    {
        NSString * errorStr = @"请输入联系人姓名";
        return errorStr;
    }
    
    //inputName换为name，即可允许有空格
    if([name stringContainSpecialCharacters])
    {
        NSString * errorStr = @"紧急联系人姓名不能包含特殊字符";
        return errorStr;
    }
    
    return result;
}

//检查用户手机号
+(NSString *)localCheckInputTelNumForUserWithText:(NSString *)inputPhoneNum
{
    NSString * result = nil;
    
    if(!inputPhoneNum||[inputPhoneNum length]==0)
    {
        NSString * errorStr = @"请输入正确的手机号码";
        return errorStr;
    }
    
    
    NSString * str = inputPhoneNum;
    NSString *regex = @"^((17[0-9])|(13[0-9])|(147)|(15[^4,\\D])|(18[0,1-9]))\\d{8}$";
    regex = @"[1][34578]\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if(!isMatch)
    {
        NSString * errorStr = @"请输入正确的手机号";
        return errorStr;
    }
    
    
    return result;
}

//检查紧急联系人手机号
+(NSString *)localCheckInputTelNumWithText:(NSString *)inputPhoneNum
{
    NSString * result = nil;
    
//    if(!inputPhoneNum||[inputPhoneNum length]==0)
//    {
//        NSString * errorStr = @"联系电话不可为空,请输入联系电话";
//        return errorStr;
//    }
//    
//    
//    NSString * str = inputPhoneNum;
//    NSString *regex = @"^((17[0-9])|(13[0-9])|(147)|(15[^4,\\D])|(18[0,1-9]))\\d{8}$";
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    BOOL isMatch = [pred evaluateWithObject:str];
//    if(!isMatch)
//    {
//        NSString * errorStr = @"电话号码格式异常，请输入国内手机号码";
//        return errorStr;
//    }
    result = [[self class] localCheckInputTelNumForUserWithText:inputPhoneNum];
    
    if(result)
    {
        return result;
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * telNum = total.userInfo.mobile;
    
    if([telNum isEqualToString:inputPhoneNum])
    {
        NSString * errorStr = @"紧急联系人号码不能与您的号码重复";
        return errorStr;
    }
    
    return result;
}

//检查本地密码
+(NSString *)localCheckInputLocalPWDWithText:(NSString *)inputPWD{
    NSString * result = nil;
    
    if([inputPWD length]!=4)
    {
        NSString * errorStr = [NSString stringWithFormat:@"密码只能是4位数字"];
        return errorStr;
    }
    
    inputPWD = [inputPWD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([inputPWD length]!=4)
    {
        NSString * errorStr = [NSString stringWithFormat:@"密码只能是4位数字"];
        return errorStr;
    }
    
    NSScanner* scan = [NSScanner scannerWithString:inputPWD];
    int val;
    BOOL numCheck = [scan scanInt:&val] && [scan isAtEnd];
    if(!numCheck)
    {
        NSString * errorStr = [NSString stringWithFormat:@"密码只能是4位数字"];
        return errorStr;
    }
    
    //inputName换为name，即可允许有空格
    if([inputPWD stringContainSpecialCharacters])
    {
        NSString * errorStr = [NSString stringWithFormat:@"密码只能是4位数字"];
        return errorStr;
    }
    
    
    return result;
}

//检查关系
+(NSString *)localCheckInputContactRelationNameWithText:(NSString *)relation{
    NSString * result = nil;

    //数据校验
    if(!relation||[relation length]==0)
    {
        NSString * errorStr = @"请告诉我们TA是谁";
        return errorStr;
    }
    
    NSString * name = [relation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([name length]<2||[name length]>32)
    {
        NSString * errorStr = @"字数应在2-32位之间";
        return errorStr;
    }
    
    if([name length]==0)
    {
        NSString * errorStr = @"关系不能包含空格";
        return errorStr;
    }
    
    //inputName换为name，即可允许有空格
    if([name stringContainSpecialCharacters])
    {
        NSString * errorStr = @"关系不能包含特殊字符";
        return errorStr;
    }
    
    return result;
}

//检查暗号
+(NSString *)localCheckInputContactPWDWithText:(NSString *)relationPWD{
    NSString * result = nil;
    //数据校验
    if(!relationPWD||[relationPWD length]==0)
    {
        NSString * errorStr = @"朋友姓名不能为空";
        return errorStr;
    }
    
    NSString * name = [relationPWD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([name length]<2||[name length]>32)
    {
        NSString * errorStr = @"朋友姓名字数应在2-32位之间";
        return errorStr;
    }
    
    if([name length]==0)
    {
        NSString * errorStr = @"朋友姓名不能为空";
        return errorStr;
    }
    
//    //inputName换为name，即可允许有空格
    if([name stringContainSpecialCharacters])
    {
        NSString * errorStr = @"朋友姓名不能包含特殊字符";
        return errorStr;
    }

    return result;
}

//检查校验码
+(NSString *)localCheckInputMsgNumWithText:(NSString *)inputMsgNum{
    NSString * result = nil;
    
    //数据校验
    if(!inputMsgNum||[inputMsgNum length]==0)
    {
        NSString * errorStr = @"请输入短信验证码";
        return errorStr;
    }
    
    NSString * name = [inputMsgNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([name length]!=6)
    {
        NSString * errorStr = @"请输入6位短信验证码";
        return errorStr;
    }
    
    NSScanner* scan = [NSScanner scannerWithString:inputMsgNum];
    int val;
    BOOL numCheck = [scan scanInt:&val] && [scan isAtEnd];
    if(!numCheck)
    {
        NSString * errorStr = [NSString stringWithFormat:@"验证码只能是6位数字"];
        return errorStr;
    }
    
    //inputName换为name，即可允许有空格
    if([name stringContainSpecialCharacters])
    {
        NSString * errorStr = @"验证码不能包含特殊字符";
        return errorStr;
    }
    
    return result;
}
//检查去做什么
+(NSString *)localCheckInputWhatToDoWithText:(NSString *)doWhat
{
    NSString * result = nil;
    
    //数据校验
    if(!doWhat||[doWhat length]==0)
    {
        NSString * errorStr = @"请输入您想要做什么";
        return errorStr;
    }
    
    if([doWhat length]>30)
    {
        NSString * errorStr = @"输入内容不能超过30个字符";
        return errorStr;
    }
    
    doWhat = [doWhat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //inputName换为name，即可允许有空格
    if([doWhat stringContainSpecialCharacters])
    {
        NSString * errorStr = @"输入内容包含非法字符，请重新输入";
        return errorStr;
    }
    
    return result;
}

+(NSString *)localInputNumberInputForTotalText:(NSString *)str{
    NSString * regEx = @"\\d+";
    //    regEx = @"<script[^>]*>.*?</>|<.*? /script>";
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:regEx options:NSRegularExpressionCaseInsensitive error:nil];
    if (regex != nil)
    {
        NSArray * array = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
        if([array count]>0)
        {
            NSTextCheckingResult * eveResult = [array objectAtIndex:0];
            NSString * eve = [str substringWithRange:eveResult.range];
            return eve;
        }
    }
    return nil;
}


@end
