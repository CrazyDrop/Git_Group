//
//  PaPaUserInfo.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "LoginStartModel.h"
#import "ContactsModel.h"
typedef enum {
    PaPaUserInfo_TYPE_ADD = 1,
    PaPaUserInfo_TYPE_UPDATE
} PaPaUserInfoTYPE;



//个人用户信息model
@interface PaPaUserInfoModel : LoginStartModel
//2.0之后，单纯作为数据类型使用
//1、添加
//2、更新
//@property (nonatomic,assign) PaPaUserInfoTYPE type;

@property (nonatomic,copy) NSString * contacts;
@property (nonatomic,copy) NSString * contactedcnt;

@property (nonatomic,copy) NSString * username;
@property (nonatomic,copy) NSString * mobile;
@property (nonatomic,copy) NSString * password;

//附加参数，本地使用
@property (nonatomic,copy) NSString * token;
@property (nonatomic,copy) NSString * messageNum;

@property (nonatomic,strong) NSString * warningId;
@property (nonatomic,strong) NSArray<ContactsModel> * contactsdtl;



@end
