//
//  ZAContactListController+DataRequest.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/1/8.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactListController+DataRequest.h"
#import "ZAContactListController+DataSource.h"
@implementation ZAContactListController (DataRequest)


#pragma mark PaPaUserInfoModel
-(void)requestForContactList
{
    //数据请求
    GetContactsModel * model = (GetContactsModel *) _dpModel;
    if(!model){
        model = [[GetContactsModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    [model sendRequest];
}
-(void)refreshWithSuccess
{
    self.refreshList = NO;
    
    //进行数据缓存，数据展示
    GetContactsModel * getModel = (GetContactsModel *)_dpModel;
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];

    //    self.dataList = [ContactsModel contactsEffectiveArrayForCurrentArray:getModel.contacts];
    [ContactsModel refreshWebContactsArr:getModel.contacts withLatestLocalArray:local.contacts];
    self.dataList = [NSArray arrayWithArray:getModel.contacts];
    
    local.contacts = self.dataList;
    [local localSave];
    [self refreshLocalTableView];
    
    
    //总数达到8条
    if(startedRrefresh && [self.dataList count]>=[ZA_Contacts_List_Max_Num intValue])
    {
        [DZUtils noticeCustomerWithShowText:@"您的联系人已满，请删除一个后再添加"];
    }
    startedRrefresh = NO;
}

handleSignal( GetContactsModel, requestError )
{
    [self hideLoading];
    
    if(self.dataList && [self.dataList count]>0)
    {
        [DZUtils checkAndNoticeErrorWithSignal:signal];
        return;
    }
    
    {
        NSString * msg = @"网络异常，建议检测后";
        BOOL netEnable = [DZUtils deviceWebConnectEnableCheck];
        if(netEnable)
        {
            msg = kAppNone_Service_Error;
        }
        [self refreshErrorViewWithMessage:msg];
    }
}
handleSignal( GetContactsModel, requestLoading )
{
    if(loadingState)
    {
        [self showLoading];
    }else{
        
        self.errorView.hidden = NO;
        [self.errorView refreshErrorViewWithLoading:YES];
    }
}

handleSignal( GetContactsModel, requestLoaded )
{
    [self hideLoading];
    __weak typeof(self) weakSelf = self;
    if([DZUtils checkAndNoticeErrorWithSignal:signal andNoticeBlock:^(BOOL netEnable) {
        ZAHTTPResponse *resp = signal.object;
        NSString * msg = resp.returnMsg;
        if(!msg||[msg length]==0)
        {//无服务器返回提示
            msg = @"网络异常，建议检测后";
            if(netEnable)
            {
                msg = kAppNone_Service_Error;
            }
        }
        [weakSelf refreshErrorViewWithMessage:msg];
        
    }])
    {
        [self refreshWithSuccess];
        loadingState = YES;
        //首次创建
        
        self.errorView.hidden = YES;
    }
}
#pragma mark -
-(void)refreshErrorViewWithMessage:(NSString *)msg
{
    loadingState = NO;
    self.errorView.hidden = NO;
    self.errorView.errTxt = msg;
    [self.errorView refreshErrorViewWithLoading:NO];
}


#pragma mark ContactTellModel
-(void)startContactTelllRequestWithContactId:(NSString *)idStr
{
    //刷新model状态，并保存total里缓存数据
    
    
    //数据请求
    ContactTellModel * model = (ContactTellModel *) tellModel;
    if(!model){
        model = [[ContactTellModel alloc] init];
        [model addSignalResponder:self];
        tellModel = model;
    }
    model.contactId = idStr;
    [model sendRequest];
}
handleSignal( ContactTellModel, requestError )
{
    
}
handleSignal( ContactTellModel, requestLoading )
{
    
}
handleSignal( ContactTellModel, requestLoaded )
{
    
}
#pragma mark -
#pragma mark DeletePaPaUserInfoModel
-(void)deleteContactWithCurrentContactId:(NSString *)contactId
{
    //数据请求
    DelContactsModel * model = (DelContactsModel *) _delModel;
    if(!model){
        model = [[DelContactsModel alloc] init];
        [model addSignalResponder:self];
        _delModel = model;
    }
    model.id = contactId;
    [model sendRequest];
}

-(void)refreshWithSuccessAfterDelete
{
    if(!_delModel) return;
    
    //进行数据缓存，数据展示
    NSArray * array = self.dataList;
    NSMutableArray * resultArr = [NSMutableArray array];
    NSInteger idNum = [[(DelContactsModel *)_delModel id] intValue];
    
    //    __block NSInteger secNum = NSNotFound;
    //遍历，添加
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ContactsModel * eve = (ContactsModel *)obj;
        if(idNum != [eve.id intValue]){
            [resultArr addObject:obj];
            //            secNum = idx;
        }
    }];
    
    //    if(secNum==NSNotFound) return;
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    local.contacts = resultArr;
    [local localSave];
    
    //    NSIndexPath * cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:secNum];

    //动画效果不理想
//    self.dataList = resultArr;
//    [self refreshLocalTableView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACT_REDCIRCLE_STATE
                                                        object:[NSNumber numberWithBool:NO]];
    
}

handleSignal( DelContactsModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( DelContactsModel, requestLoading )
{
    [self showLoading];
}

handleSignal( DelContactsModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [self refreshWithSuccessAfterDelete];
    }
}
#pragma mark -



@end
