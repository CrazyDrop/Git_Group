//
//  ContactsModel.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/1.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ContactsModel.h"
#import "ContactsModelAPI.h"
#import "NSObject+AutoCoding.h"
#import "AutoCoding.h"
#import "JSONKit.h"
@implementation ContactsModel


-(void)sendRequest
{
    ContactsModelAPI *api = [[ContactsModelAPI alloc] init];
    api.contanctId = self.id;
    @weakify(self)
    //    Account *account = [[AccountManager sharedInstance] account];
    //    if(account == nil)
    //    {
    //        [self sendSignal:self.requestError];
    //        return;
    //    }
    api.req.id = self.id;
    api.req.contactName = self.contactName;
    api.req.relation = self.relation;
    api.req.contactMobile = self.contactMobile;
    api.req.contactPwd = self.contactPwd;
    api.req.isContacted = self.isContacted;
    api.req.isDeleted = self.isDeleted;

    api.whenUpdate = ^(ContactsModelResponse *resp, id error){
        @strongify(self)
        if(resp)
        {
            [self sendSignal:self.requestLoaded withObject:resp];
        }else{
            [self sendSignal:self.requestError];
        }
    };
    
    [api send];
    
    [self sendSignal:self.requestLoading];
}
+(void)refreshWebContactsArr:(NSArray *)webArr withLatestLocalArray:(NSArray *)array
{
    if(!array || [array count]==0)
    {
        [self refreshContactsLocalNoticedForStartLoginWithArray:webArr];
    }else {
        //检查web数组里的全部，根据id，寻找local里有的数据填充，没有的为NO
        NSMutableArray * idArr = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            ContactsModel * model = (ContactsModel *)obj;
            NSString * idStr = model.id;
            if([model.isLocalNoticed boolValue]){
                 [idArr addObject:idStr];
            }
        }];
        
        [webArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             ContactsModel * model = (ContactsModel *)obj;
             NSString * idStr = model.id;
             if([model.isDeleted boolValue])
             {
                 BOOL noticed = [idArr containsObject:idStr];
                 model.isLocalNoticed = [NSString stringWithFormat:@"%@",[NSNumber numberWithBool:noticed]];
             }
         }];
    }
}


+(void)refreshContactsLocalNoticedForStartLoginWithArray:(NSArray *)array
{
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
        ContactsModel * model = (ContactsModel *)obj;
        model.isLocalNoticed = [NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]];
     }];

}
//紧急联系人红点计算
+(BOOL)contactNeedRedStateForContactListArr:(NSArray *)array
{
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    if(!local.isUserLogin) return NO;
    
    if(!array || [array count]==0) return NO;
    
    __block BOOL showRed = NO;
    //检查通知他红点
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         ContactsModel * model = (ContactsModel *)obj;
         if(![model.isDeleted boolValue] && ![model.isContacted boolValue]){
             showRed = YES;
         }
     }];
    
    if(showRed) return showRed;
    
    //检查无效紧急联系人已经告知红点
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         ContactsModel * model = (ContactsModel *)obj;
         if([model.isDeleted boolValue] && ![model.isLocalNoticed boolValue]){
             showRed = YES;
         }
     }];
    
    return showRed;
}

+(BOOL)checkEffectiveContactFromArray:(NSArray *)array
{
    __block BOOL contain = NO;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         ContactsModel * model = (ContactsModel *)obj;
         NSString * effective = model.isDeleted;
         if(!effective || (effective && [effective intValue]==0))
         {
             contain = YES;
             *stop = YES;
         }
     }];
    
    return contain;
}

+(NSArray *)contactsEffectiveArrayForCurrentArray:(NSArray *)data
{
    NSMutableArray * array = [NSMutableArray array];
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        ContactsModel * model = (ContactsModel *)obj;
        NSString * effective = model.isDeleted;
        if(!effective || [effective intValue]==0)
        {
            [array addObject:obj];
        }
    }];
    return array;
}

+(NSArray *)customArray
{
    NSMutableArray * total = [NSMutableArray array];
    //获取数据，刷新
    for (int i=0; i<4; i++)
    {
        ContactsModel * eve = [[ContactsModel alloc] init];
        eve.id = [NSString stringWithFormat:@"%d",i + 100];
        eve.contactMobile = [NSString stringWithFormat:@"1305185010%d",i];
        eve.contactName = [NSString stringWithFormat:@"张三%d",i + 100];
        eve.contactPwd = [NSString stringWithFormat:@"暗号%d",i * 200];
        eve.relation = [NSString stringWithFormat:@"姐妹%d",i * 200];
        eve.isDeleted = [NSString stringWithFormat:@"%d",i%2];

        [total addObject:eve];
    }
    return total;
}
+(NSArray *)contactsArrayAddOrUpdateWithModel:(ContactsModel *)obj andArray:(NSArray *)objArr
{
    if(!obj||![obj isKindOfClass:[ContactsModel class]]) return objArr;
    ContactsModel * model = (ContactsModel *)obj;
    
    NSMutableArray * array = [NSMutableArray arrayWithArray:objArr];
    NSInteger index = NSNotFound;
    NSString * idStr = model.id;

    if(idStr && [idStr length]>0)
    {
        for (ContactsModel * eve in array)
        {
            if([eve.id intValue] == [model.id intValue])
            {
                index = [array indexOfObject:eve];
                break;
            }
        }
    }
    
    //添加
    if(index==NSNotFound){
        [array addObject:model];
    }else if([array count]>index)
    {
        //替换
        [array replaceObjectAtIndex:index withObject:model];
    }
    
    //保存
    return array;
}


- (id)copyWithZone:(NSZone *)zone
{
    ContactsModel *contact = [[ContactsModel alloc] init];
    
    contact.id = [self.id copy];
    contact.contactMobile = [self.contactMobile copy];
    contact.contactName = [self.contactName copy];
    contact.contactPwd = [self.contactPwd copy];
    contact.relation = [self.relation copy];
    
    return contact;
}
-(NSString *)description
{
    NSMutableString * str = [NSMutableString string];
    if(self.id) [str appendString:self.id];
    if(self.contactName) [str appendString:self.contactName];
    if(self.contactMobile) [str appendString:self.contactMobile];
    if(self.contactPwd) [str appendString:self.contactPwd];
    if(self.relation) [str appendString:self.relation];
    if(self.isDeleted) [str appendString:self.isDeleted];
    return str;
}



@end
