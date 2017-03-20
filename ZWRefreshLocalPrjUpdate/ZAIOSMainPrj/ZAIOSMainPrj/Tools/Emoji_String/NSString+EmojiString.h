//
//  EmojiString.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/8/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EmojiString)

- (NSString*) telNumHidePartString;
+ (BOOL)stringContainsEmoji:(NSString *)string;

-(BOOL)stringContainSpecialCharacters;

-(NSString *)inputStringExcept9Input;


@end
