//
//  UIScrollView+InputCheck.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/12/29.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "UIScrollView+InputCheck.h"

@implementation UIScrollView (InputCheck)

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * nameStr = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([nameStr isEqualToString:@"emoji"])
    {
        return NO;
    }
    
    //    //emoji无效
    //    if([NSString stringContainsEmoji:string])
    //    {
    //        return NO;
    //    }
    
    string = [string inputStringExcept9Input];
    if([string stringContainSpecialCharacters])
    {
        return NO;
    }
    
    return YES;
}



@end
