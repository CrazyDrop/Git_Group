//
//  UserInfo.h
//  Photography
//
//  Created by jialifei on 15/4/6.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic,retain) NSString *userId;
@property (nonatomic ,copy) NSString *useImg;
@property (nonatomic ,copy) NSString *userToken;
//@property (nonatomic ,copy) NSString *userNickName;
@property (nonatomic ,copy) NSString *phone;
@property (nonatomic ,copy) NSString *username;

@property (nonatomic ,retain) UINavigationController *minNavgation;

+ (UserInfo *) sharedUser;



@end
