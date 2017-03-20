//
//  ContactsModel.h
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "BaseRequestModel.h"
//紧急联系人model
@protocol ContactsModel <NSObject> @end


@interface ContactsModel : BaseRequestModel
//1、添加
//2、更新
@property (nonatomic,copy) NSString * id;
@property (nonatomic,copy) NSString * contactName;
@property (nonatomic,copy) NSString * contactMobile;
@property (nonatomic,copy) NSString * contactPwd;
@property (nonatomic,copy) NSString * relation;

@property (nonatomic,copy) NSString * isDeleted;//是否客服标记失效
@property (nonatomic,copy) NSString * isContacted;

@property (nonatomic,copy) NSString * isLocalNoticed;//新增，本地无效联系人展示红点，仅isDeleted时有效，为YES时，不展示红点


//联系人列表数据刷新时，将本地无效紧急联系人的阅读状态移动到新表
+(void)refreshWebContactsArr:(NSArray *)webArr withLatestLocalArray:(NSArray *)array;

//用户新登录时，无效的紧急联系人阅读状态更新到已读
+(void)refreshContactsLocalNoticedForStartLoginWithArray:(NSArray *)arr;

//紧急联系人红点计算
+(BOOL)contactNeedRedStateForContactListArr:(NSArray *)arr;

+(BOOL)checkEffectiveContactFromArray:(NSArray *)array;

+(NSArray *)contactsEffectiveArrayForCurrentArray:(NSArray *)array;

+(NSArray *)customArray;

+(NSArray *)contactsArrayAddOrUpdateWithModel:(ContactsModel *)model andArray:(NSArray *)arr;

@end
