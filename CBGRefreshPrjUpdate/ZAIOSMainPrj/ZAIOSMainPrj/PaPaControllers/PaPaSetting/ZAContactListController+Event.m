//
//  ZAContactListController+Event.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/8.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactListController+Event.h"
#import "ContactsModel.h"
#import "ZAContactAddController.h"
#import "ZAContactEditController.h"
#import "ZAContactAddController.h"
#import "MSAlertController.h"
#import "ZAAddContactController.h"
#import "ZAWebErrorView.h"
#import "DPViewController+WebCheck.h"
#import "DPViewController+NoticeTA.h"
#import "ZAContactListController+DataRequest.h"
#import "ZAContactListController+DataSource.h"
@implementation ZAContactListController (Event)

//增加刷新，每收到状态改变的事情，为红点逻辑刷新列表

-(void)refreshTableViewCellWithLatestSection:(NSInteger)section
{
    UITableView * table = self.listTable;
    [table beginUpdates];
    
    [table reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [table endUpdates];
}
-(void)deleteContactObjectWithIndexPath:(NSIndexPath *)path
{
    ContactsModel * contact = [self contactModelForIndexPath:path];
    
    if(!contact) return;
    
    //弹出按钮
    NSString * log = [NSString stringWithFormat:@"确定要删除紧急联系人%@?",contact.contactName];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"确定" style:MSAlertActionStyleDestructive handler:^(MSAlertAction *action)
                             {
                                 [weakSelf deleteContactWithCurrentContactId:contact.id];
                             }];
    [alertController addAction:action];
    
    
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
        [weakSelf.listTable reloadData];
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
    
    
}
-(void)refreshContactNumForCell:(UITableViewCell *)cell
{
    NSIndexPath * indexPath = [self.listTable indexPathForCell:cell];
    ContactsModel * contact = [self contactModelForIndexPath:indexPath];
    
    [self startContactTelllRequestWithContactId:contact.id];
    [self tapedOnNotificationOthers:contact];
    
    if(![contact.isContacted boolValue])
    {
        contact.isContacted = [NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]];
        
        [self refreshLocalSaveContactsAndPostNotificationWithContact:contact];
    }
}
-(void)refreshLocalSaveContactsAndPostNotificationWithContact:(ContactsModel *)contact
{
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    NSArray * arr = [ContactsModel contactsArrayAddOrUpdateWithModel:contact andArray:local.contacts];
    local.contacts = arr;
    [local localSave];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACT_REDCIRCLE_STATE
                                                        object:[NSNumber numberWithBool:NO]];
}

-(void)tapedOnNotificationOthers:(ContactsModel *)obj
{
    NSString * telNum = obj.contactMobile;
    [self startActionForNoticeTA:(telNum && [telNum length]>0)?[NSArray arrayWithObject:telNum]:nil];
}
-(void)tapedOnAddMoreBtn:(id)sender
{
    //总数达到8条
    if([self.dataList count]>=[ZA_Contacts_List_Max_Num intValue])
    {
        [DZUtils noticeCustomerWithShowText:@"您的联系人已满，请删除一个后再添加"];
        return;
    }
    //有效达到三条
    if([self.effectiveList count]>=[ZA_Contacts_List_Max_Effective_Num intValue])
    {
        [DZUtils noticeCustomerWithShowText:@"您的有效联系人已有三个，请删除一个后再添加"];
        return;
    }
    
    ZAAddContactController * add = [[ZAAddContactController alloc] init];
    [[self rootNavigationController] pushViewController:add animated:YES];
}

-(void)refreshRedCircleForCheckNoUseContact:(ContactsModel *)contact
{
    contact.isLocalNoticed = [NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]];
    
    [self refreshLocalSaveContactsAndPostNotificationWithContact:contact];
}


-(void)tapedOnCellForNextEditViewWithIndexPath:(NSIndexPath *)path
{
    ContactsModel * contact = [self contactModelForIndexPath:path];
    
    BOOL notice = [contact.isDeleted boolValue] && [self.effectiveList count]>=[ZA_Contacts_List_Max_Effective_Num intValue];
    BOOL unable = [contact.isDeleted boolValue] && [self.effectiveList count]<[ZA_Contacts_List_Max_Effective_Num intValue];
    BOOL noneRemove = (![contact.isDeleted boolValue]) && [self.effectiveList count]==1;

    
    if(unable && ![contact.isLocalNoticed boolValue]){
        [self refreshRedCircleForCheckNoUseContact:contact];
    }
    
    ZAContactEditController * edit = [[ZAContactEditController alloc] init];
    edit.editContact = [contact copy];
    edit.editUnable = notice;
    edit.canNotRemove = noneRemove;
    edit.unableAndCompare = unable;

    [[self rootNavigationController] pushViewController:edit animated:YES];
}

@end
