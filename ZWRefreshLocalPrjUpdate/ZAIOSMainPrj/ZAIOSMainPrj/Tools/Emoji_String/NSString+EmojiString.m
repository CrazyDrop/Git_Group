//
//  EmojiString.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/8/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "NSString+EmojiString.h"

@implementation NSString (EmojiString)

- (NSString*) telNumHidePartString
{
    NSInteger length = [self length];
    NSInteger headerLength = 3;
    NSInteger endLength = 4;
    if(length<headerLength+endLength) return self;
    NSMutableString * result = [NSMutableString string];
    [result appendString:[self substringToIndex:3]];
    [result appendString:@"****"];
    [result appendString:[self substringFromIndex:length-endLength]];
    return result;
}


+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    //由于9宫格录入时为特殊字符，故排除此范围
//                                    if (0x2100 <= hs && hs <= 0x27ff) {
//                                        returnValue = YES;
//                                    } else
                                        if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}
-(BOOL)stringContainSpecialCharacters
{
    if([self length]==0) return NO;
    
    
    NSString *searchText = self;
    NSString *regex = @"[a-zA-Z\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]+";
    regex = @"[a-zA-Z0-9\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:searchText];
//    isMatch标识符合规定，没有特殊字符
    return !isMatch;
    
//        NSError *error = NULL;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[A-Za-z0-9\u4E00-\u9FA5_-]+$" options:NSRegularExpressionCaseInsensitive error:&error];
//    NSTextCheckingResult *result = [regex firstMatchInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
//    if (result)
//    {
//        
//        NSLog(@"%@", [searchText substringWithRange:result.range]);
//        return YES;
//    }
//    return NO;
    
//    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+ "];
//    NSString * tempString = [[self componentsSeparatedByCharactersInSet:doNotWant]componentsJoinedByString: @""];
//    BOOL compare = [tempString length]==[self length];
//    return !compare;
    
    //此方法需要穷尽所有特殊符号
    NSString * str = self;
    NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€"]];
    if (urgentRange.location == NSNotFound)
    {
        return NO;
    }
    return YES;
}

-(NSString *)inputStringExcept9Input
{
    if([self length]==0) return self;
    //，。？！此些9宫格特殊字符不许录入
    NSString * string9 = @"➋➌➍➎➏➐➑➒";
    NSString * string = [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:string9]];
    return string;
}

@end
