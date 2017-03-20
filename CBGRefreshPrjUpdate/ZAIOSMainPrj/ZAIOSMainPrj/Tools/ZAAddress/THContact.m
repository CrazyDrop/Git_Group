//
//  Contact.m
//  upsi
//
//  Created by Mac on 3/24/14.
//  Copyright (c) 2014 Laith. All rights reserved.
//

#import "THContact.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
@implementation THContact
@synthesize fullName = _fullName;
@synthesize updateFullName = _updateFullName;
#pragma mark - NSObject - Creating, Copying, and Deallocating Objects

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:attributes];
    }
    
    return self;
}

#pragma mark - NSKeyValueCoding Protocol

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.recordId = [value integerValue];
    } else if ([key isEqualToString:@"firstName"]) {
        self.firstName = value;
    } else if ([key isEqualToString:@"lastName"]) {
        self.lastName = value;
    } else if ([key isEqualToString:@"phone"]) {
        self.phone = value;
    }else if ([key isEqualToString:@"email"]) {
        self.email = value;
    }else if ([key isEqualToString:@"image"]) {
        self.image = value;
    }else if ([key isEqualToString:@"isSelected"]) {
        self.selected = [value boolValue];
    }else if ([key isEqualToString:@"date"]) {
        // TODO: Fix
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        self.date = [dateFormatter dateFromString:value];
    } else if ([key isEqualToString:@"dateUpdated"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        self.dateUpdated = [dateFormatter dateFromString:value];
    }
}

- (NSString *)fullName
{
    if(!_fullName)
    {
        BOOL containChinese = NO;
//        NSString * total = [NSString stringWithFormat:@"%@%@",self.firstName?:@"",self.lastName?:@""];
//        containChinese = [ChineseInclude isIncludeChineseInString:total];
        
        if(self.firstName != nil && self.lastName != nil) {
            if(containChinese)
            {
                _fullName = [NSString stringWithFormat:@"%@%@",self.lastName,self.firstName];
            }else
            {
                 _fullName= [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
            }
        } else if (self.firstName != nil) {
            _fullName = self.firstName;
        } else if (self.lastName != nil) {
            _fullName = self.lastName;
        } else {
            _fullName = @"";
        }

//        if(containChinese)
//        {
//            self.totalPinYin = [PinYinForObjc chineseConvertToPinYin:_fullName];
//            self.firstLetterPinYin = [PinYinForObjc chineseConvertToPinYinHead:_fullName];
//        }
    }
    return _fullName;
}
- (NSString *)updateFullName
{
    if(!_updateFullName)
    {
        BOOL containChinese = NO;
        NSString * total = [NSString stringWithFormat:@"%@%@",self.firstName?:@"",self.lastName?:@""];
        containChinese = [ChineseInclude isIncludeChineseInString:total];
        
        if(self.firstName != nil && self.lastName != nil)
        {
            if(containChinese)
            {
                NSString * str = [NSString stringWithFormat:@"%@%@",self.lastName,self.firstName];
                str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                _updateFullName = str;
            }else
            {
                _updateFullName= [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
            }
        }else{
            _updateFullName = self.fullName;
        }
        //        if(containChinese)
        //        {
        //            self.totalPinYin = [PinYinForObjc chineseConvertToPinYin:_fullName];
        //            self.firstLetterPinYin = [PinYinForObjc chineseConvertToPinYinHead:_fullName];
        //        }
    }
    return _updateFullName;
}


@end
