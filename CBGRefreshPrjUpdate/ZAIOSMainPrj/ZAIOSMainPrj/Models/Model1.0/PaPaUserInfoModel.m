//
//  PaPaUserInfo.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "PaPaUserInfoModel.h"

@implementation PaPaUserInfoModel
//-(void)sendRequest
//{
//    PaPaUserInfoModelAPI *api = [[PaPaUserInfoModelAPI alloc] init];
//    @weakify(self)
//    
//    api.req.username = self.username;
//    api.req.mobile = self.mobile;
//    api.whenUpdate = ^(PaPaUserInfoModelResponse *resp, id error){
//        @strongify(self)
//        if(resp)
//        {
//            [self sendSignal:self.requestLoaded withObject:resp];
//        }else{
//            [self sendSignal:self.requestError];
//        }
//    };
//    
//    [api send];
//    
//    [self sendSignal:self.requestLoading];
//}

//-(void)localSave;
//{
//    NSDictionary * dic = [self dictionaryRepresentation];
//    NSString * str = [dic JSONString];
//    [DZUtils localSaveObject:str withKeyStr:USERDEFAULT_UserInfo_Model];
////    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults] ;
////    [stand setObject:dic forKey:USERDEFAULT_UserInfo_Model];
////    [stand synchronize];
//}
//
//+(PaPaUserInfoModel *)userInfoFromLocalSave
//{
//    NSString * str = [DZUtils localSaveObjectFromLocalSaveKeyStr:USERDEFAULT_UserInfo_Model];
//    NSDictionary * dic = [str objectFromJSONString];
//    
////    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults] ;
////    NSDictionary * dic = [stand objectForKey:USERDEFAULT_UserInfo_Model];
//    
//    PaPaUserInfoModel * model =[PaPaUserInfoModel ac_objectWithDictionary:dic];
//    return model;
//}
- (id)copyWithZone:(NSZone *)zone
{
    id copyObject = [[[self class] allocWithZone:zone] init];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithFormat:@"%s",property_getName(property)];
        id value = [self valueForKey:key];
        [copyObject setValue:value forKey:key];
    }
    free (properties);
    return copyObject;
}


@end
