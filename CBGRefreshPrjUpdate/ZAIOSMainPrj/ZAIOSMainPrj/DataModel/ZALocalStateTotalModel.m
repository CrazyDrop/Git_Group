//
//  ZALocalStateTotalModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALocalStateTotalModel.h"
#import "AutoCoding.h"
#import "ContactsModel.h"
@interface ZALocalStateTotalModel()
{
//    BOOL 
}
@end

@implementation ZALocalStateTotalModel

- (void)setToken:(NSString *)name
{
    
}
-(void)setUserLogin:(BOOL)userLogin
{
    
}
-(void)setNeedUpdate:(BOOL)needUpdate
{
    
}
-(void)setNeedAddContact:(BOOL)needAddContact
{
    
}
-(void)setNeedStartedAddContact:(BOOL)needStartedAddContact
{
    
}

-(void)setNeedDialog:(BOOL)needDialog
{
    
}

//是否已经登录的判定
-(BOOL)isUserLogin
{
    PaPaUserInfoModel * model = self.userInfo;
    if(model&&[model isKindOfClass:[PaPaUserInfoModel class]])
    {
        NSString * token = model.token;
//        NSString * tel = model.mobile;
//        if(tel && [tel length]>0 && token && [token length]>0)
        if(token && [token length]>0)
        {
             return YES;
        }
    }
    return NO;
}

//是否需要补全信息
-(BOOL)isNeedUpdate
{
    //未登录、不需要补全信息
    if(!self.isUserLogin) return NO;
    
    PaPaUserInfoModel * model = self.userInfo;
    NSString * pwd = model.password;
    NSString * name = model.username;
    
    //主要信息为空，则需要补全
    if((!pwd || [pwd length]==0) || (!name || [name length]==0)){
         return YES;
    }
    
    return NO;
}
//是否需要补全信息，没有联系人
-(BOOL)isNeedAddContact
{
    //未登录、不需要补全信息
    if(!self.isUserLogin) return NO;
    if(self.isNeedUpdate) return NO;
    
    NSArray * arr = self.contacts;
    PaPaUserInfoModel * model = self.userInfo;
    
    //服务器数量，对于刚登陆，本地没有缓存数据的有效
    if(!arr && model.contacts && [model.contacts intValue]>0) return NO;
    
    BOOL containEffective = [ContactsModel checkEffectiveContactFromArray:arr];
    return !containEffective;
//    //当服务器数据为0，且本地无数据时，弹出补全联系人界面
//    if(model.contacts && [model.contacts intValue]==0 && (!arr || [arr count]==0)){
//        return YES;
//    }
    
    return YES;
}

//是否需要补全联系人信息，没有有效联系人
-(BOOL)isNeedStartedAddContact
{
    //未登录、不需要补全信息
    if(!self.isUserLogin) return NO;
    if(self.isNeedUpdate) return NO;
    
    NSArray * arr = self.contacts;
    PaPaUserInfoModel * model = self.userInfo;
    
    if(model.warningId && [model.warningId length]) return NO;
    //服务器数量，对于刚登陆，本地没有缓存数据的有效
    if(!arr && model.contacts && [model.contacts intValue]>0) return NO;
    
    BOOL containEffective = [ContactsModel checkEffectiveContactFromArray:arr];
    return !containEffective;
    //    //当服务器数据为0，且本地无数据时，弹出补全联系人界面
    //    if(model.contacts && [model.contacts intValue]==0 && (!arr || [arr count]==0)){
    //        return YES;
    //    }
    
    return YES;
}

//是否需要弹出失联4天
-(BOOL)isNeedDialog
{
    //此版本无提示，不再使用4天的提示框
    return NO;
    
    //未登录、不需要补全信息
    if(!self.isUserLogin) return NO;
    if(self.isNeedUpdate) return NO;
    
    
    //主要信息为空，则需要补全
    LoginStartModel * model = self.userInfo;
    return [model userTimingOutOfControlForState];
    
    return NO;
}

-(NSString *)token
{
    NSString * result = nil;
    if(!self.isUserLogin) return result;
    
    PaPaUserInfoModel * model = self.userInfo;
    return model.token;
}

static ZALocalStateTotalModel *shareZALocalStateTotalModelInstance = nil;
+(instancetype)currentLocalStateModel
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZALocalStateTotalModelInstance = [[self class] createInstanceModel];
    });
    return shareZALocalStateTotalModelInstance;
}

//本地统一存储的数据
+(instancetype)createInstanceModel
{
    NSUserDefaults * stand = [[NSUserDefaults alloc] initWithSuiteName:USERDEFAULT_SUIT_NAME_PAPA];
    NSData * data  = [stand objectForKey:Local_File_ZALocalStateTotalModel_Model];
    
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel objectWithContentsOfData:data];
    if(!model)
    {
        model = [[ZALocalStateTotalModel alloc] init];
        model.stateIdentifier = @"stateIdentifier";
        model.refreshTime = @"2";
    }
    return model;
}
//数据存储到本地文件，考虑
-(void)localSave
{
    ZALocalStateModel * model = [[ZALocalStateModel alloc] init];
    model.stateIdentifier = self.stateIdentifier;
    model.warningId = self.warningId;
    model.password = self.password;
    model.showPWD = self.showPWD;
    model.totalTime = self.totalTime;
    model.endDate = self.endDate;
    [model localSave];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults * stand = [[NSUserDefaults alloc] initWithSuiteName:USERDEFAULT_SUIT_NAME_PAPA];
    [stand setObject:data forKey:Local_File_ZALocalStateTotalModel_Model];
    [stand synchronize];
}

-(void)refreshLocalSaveStateDataWithCurrentData
{
    [safeLock lock];
    ZALocalStateTotalModel * model = [[self class] createInstanceModel];
    
    id copyObject = self;
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([copyObject class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithFormat:@"%s",property_getName(property)];
        id value = [model valueForKey:key];
        [copyObject setValue:value forKey:key];

    }
    free (properties);
    
    [safeLock unlock];
}

+(void)clearLocalStateForLogout
{
    ZALocalStateTotalModel * current = [ZALocalStateTotalModel currentLocalStateModel];
    
    ZALocalStateTotalModel * local  = [[ZALocalStateTotalModel alloc] init];
    //两处保持不变
    local.main_Tips_Showed = current.main_Tips_Showed;
    local.start_Tips_Showed = current.start_Tips_Showed;
    local.timer_Tips_Showed = current.timer_Tips_Showed;
    local.start_Introduce_Showed = current.start_Introduce_Showed;
    local.addresslist_Added_Contact = current.addresslist_Added_Contact;
    local.recorder_Alert_Noticed = current.recorder_Alert_Noticed;
    [local localSave];
    
    [current refreshLocalSaveStateDataWithCurrentData];
}


@end
