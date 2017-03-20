//
//  StartZAContactController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/19.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "StartZAContactController.h"
#import "ZAAddressController.h"
#import "ZAContactAddRLController.h"
#import "THContact.h"
#import "ZAContactAddSecondCell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "ContactsModel.h"
#import "ZAContactListController.h"
#import "ZAContactSelectEditController.h"
#import "ZAStartLoginCell.h"
#import "DPViewController+NoticeTA.h"
#import "DPViewController+AddressAuth.h"
@interface StartZAContactController()<MFMessageComposeViewControllerDelegate>
{
    UIButton * addressBtn;
    UIButton * moreBtn;
    UIButton * relationBtn;
    NSTimer * checkTimer;
}
@property (nonatomic,strong) ContactsModel * editModel;
@property (nonatomic,assign) BOOL addMore;
@property (nonatomic,strong) UIAlertView * diaAlert;
@property (nonatomic,strong) UIViewController * smsVC;
@property (nonatomic,assign) BOOL noticeState;
@end

@implementation StartZAContactController
- (void)viewDidLoad {
    self.viewTtle = @"设置紧急联系人";
    NSArray * arr = self.navigationController.viewControllers;
    self.showLeftBtn =  [arr count]!=1;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleBar.hidden = NO;
    
    //改变topSelectView位置，居右展示
    CGRect rect = topSelectView.frame;
    rect.origin.x = rect.size.width;
    topSelectView.frame = rect;
    
    
    NSString * title = @"我们会在您可能遇险时，联络您的紧急联系人进行援助。请一定设置同城靠谱的朋友哦~";
    topGuideLbl.text = title;
    [topGuideLbl sizeToFit];
    CGFloat centerY = CGRectGetMaxY(topSelectBGView.frame);
    CGFloat lblHeight = topGuideLbl.bounds.size.height;
    topGuideLbl.center = CGPointMake(SCREEN_WIDTH/2.0, (FLoatChange(65) - lblHeight)/2.0 + lblHeight/2.0 + centerY);
    
    
    //取出之前的header，增加通讯录部分
    CGFloat extendY = FLoatChange(35);
    UIView * header = startTableview.tableHeaderView;
    CGFloat preHeight = header.bounds.size.height;
    rect = header.frame;
    rect.size.height = preHeight + extendY;
    header.frame = rect;
    startTableview.tableHeaderView = header;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"从通讯录选择" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tapedOnLocalContactList:) forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(12)]];
    
    //实际使用高度
    btn.backgroundColor = Custom_Blue_Button_BGColor;
    CGFloat btnHeight = FLoatChange(35);
    CGFloat btnWidth = FLoatChange(110);
    btn.frame = CGRectMake(0, 0, btnWidth, btnHeight);
    [[btn layer]setCornerRadius:5.0];
    
    [header addSubview:btn];
    btn.center = CGPointMake(SCREEN_WIDTH/2.0, rect.size.height - FLoatChange(16) - btnHeight/2.0);
    [btn refreshButtonSelectedBGColor];

    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:ZA_Relation_Replace_TXT forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tapedOnSelectRealtionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:Custom_Blue_Button_BGColor forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(14)]];


    //实际使用高度
    btn.backgroundColor = [UIColor clearColor];
    btnHeight = FLoatChange(40);
    btnWidth = FLoatChange(80);
    btn.frame = CGRectMake(0, 0, btnWidth, btnHeight);
    relationBtn = btn;
    
    
    UIView * line = [DZUtils ToolCustomLineView];
    rect = line.frame;
    rect.size.width = rect.size.height;
    rect.size.height = btnHeight * 0.8;
    line.frame = rect;
    [btn addSubview:line];
    line.center = CGPointMake(FLoatChange(-5), btnHeight/2.0);
    line.backgroundColor = START_LOING_LINE_COLOR;
    
    rect = startTableview.bounds;
    CGFloat bottomHeight = FLoatChange(105);
    rect.size.height = bottomHeight;
    UIView * bottom = [[UIView alloc] initWithFrame:rect];
    bottom.backgroundColor = [UIColor clearColor];
    
    
    rect.size.height = (48/105.0) * bottomHeight;
    UIButton * tableEndBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tableEndBtn.frame = rect;
    [tableEndBtn setTitle:@"完成" forState:UIControlStateNormal];
    [bottom addSubview:tableEndBtn];
    [tableEndBtn setBackgroundColor:Custom_Blue_Button_BGColor];
    startTableview.tableFooterView = bottom;
    tableEndBtn.center = CGPointMake(SCREEN_WIDTH/2.0, bottomHeight - (rect.size.height/2.0));
    [tableEndBtn addTarget:self action:@selector(tapedOnNextBtn:) forControlEvents:UIControlEventTouchUpInside];
    [tableEndBtn refreshButtonSelectedBGColor];

    
    bottomBtn = tableEndBtn;
    
    UIButton * addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rect.size.width *= 0.3;
    addMoreBtn.frame = rect;
    [addMoreBtn setImage:[UIImage imageNamed:@"contact_notice_icon"] forState:UIControlStateNormal];
    [addMoreBtn setTitle:@" 通知TA" forState:UIControlStateNormal];
    [bottom addSubview:addMoreBtn];
    [addMoreBtn setTitleColor:Custom_Blue_Button_BGColor forState:UIControlStateNormal];
//    [addMoreBtn setImage:[UIImage imageNamed:@"add_more_icon"] forState:UIControlStateNormal];
    [addMoreBtn setBackgroundColor:[UIColor clearColor]];
    addMoreBtn.center = CGPointMake(SCREEN_WIDTH/2.0, (bottomHeight - rect.size.height)/2.0);
    [addMoreBtn addTarget:self action:@selector(tapedOnNotificationOthers:) forControlEvents:UIControlEventTouchUpInside];
//    addMoreBtn.hidden = YES;
//    moreBtn = addMoreBtn;

    
    
    self.editModel = [[ContactsModel alloc] init];
    self.editModel.isDeleted = @"0";
    
    [KMStatis staticLocalContactsEvent:StaticPaPaLocalContactsEventType_Show];
    
    //由于有返回按钮，刚进入也要判定数量
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    NSArray *  contacts = local.contacts;
    if(contacts)
    {
        moreBtn.hidden = [contacts count]>=([ZA_Contacts_List_Max_Num intValue]-1);
    }
    
    
}
-(void)tapedOnSelectRealtionBtn:(id)sender
{
    ZAContactSelectEditController * edit = [[ZAContactSelectEditController alloc] init];
    ContactsModel * model = _editModel;
    NSString * editStr = model.relation;
    PaPaContactSelectType type = PaPaContact_Select_Relation;
//    if(NO)
//    {
//        editStr = model.contactPwd;
//        type = PaPaContact_Select_PWDString;
//    }
    edit.editText = editStr;
    edit.selectType = type;
    __weak typeof(self) weakSelf = self;
    edit.TapedOnFinishedBlock = ^(PaPaContactSelectType type,NSString * endStr){
        [weakSelf refreshRelationForTxt:endStr];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:edit animated:YES];

}
-(void)refreshRelationForTxt:(NSString *)txt
{
    _editModel.relation = txt;
    
    NSString * lastTxt = ZA_Relation_Replace_TXT;
    if(_editModel.relation) lastTxt = _editModel.relation;
    [relationBtn setTitle:lastTxt forState:UIControlStateNormal];
}
-(void)tapedOnNotificationOthers:(id)sender
{
    [[startTableview TPKeyboardAvoiding_findFirstResponderBeneathView:startTableview] resignFirstResponder];
    
    self.noticeState = YES;
    NSString * telNum = [self textFromCellTfdWithIndexNum:1];
    [self startActionForNoticeTA:(telNum && [telNum length]>0)?[NSArray arrayWithObject:telNum]:nil];
}
-(void)tapedOnAddMoreBtn:(id)sender
{
    [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_Another];
    self.addMore = YES;
    BOOL result = [self checkUserInputContactDataAndShowLog];
    if(result)
    {
        [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_Another_Success];
        [self hideKeyboardAndStartRequest];
    }

}


-(void)tapedOnNextBtn:(id)sender
{
    [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_Finish];
    self.addMore = NO;
    BOOL result = [self checkUserInputContactDataAndShowLog];
    if(result)
    {
        [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_Finish_Success];
        [self hideKeyboardAndStartRequest];
    }
}
-(BOOL)checkUserInputContactDataAndShowLog
{
    //获取数据
    NSString *contactName = [self textFromCellTfdWithIndexNum:0];
    NSString *contactTel = [self textFromCellTfdWithIndexNum:1];
    NSString *contactPwd = [self textFromCellTfdWithIndexNum:2];
    NSString * relation = [relationBtn.titleLabel text];
    
    
    NSString * errorStr = nil;
    //判定紧急联系人姓名
    errorStr = [ZATfdLocalCheck localCheckInputUserNameWithText:contactName];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return NO;
    }
    //判定关系
    if(relation && [relation isEqualToString:ZA_Relation_Replace_TXT])
    {
        relation = nil;
    }else{
        errorStr = [ZATfdLocalCheck localCheckInputContactRelationNameWithText:relation];
        if(errorStr)
        {
            [DZUtils noticeCustomerWithShowText:errorStr];
            return NO;
        }
    }
    
    //判定电话号码
    errorStr = [ZATfdLocalCheck localCheckInputTelNumWithText:contactTel];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return NO;
    }
    
    //判定暗号，共同的朋友
    errorStr = [ZATfdLocalCheck localCheckInputContactPWDWithText:contactPwd];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return NO;
    }
    
    //本地排重检查
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    NSArray * localArr  = local.contacts;
    errorStr = @"当前电话号码的紧急联系人已经添加";
    ContactsModel * compare = nil;
    for(ContactsModel * eve in localArr)
    {
        if([contactTel isEqualToString:eve.contactMobile])
        {
            compare = eve;
            break;
        }
    }
    
    if(compare)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return NO;
    }
    
    return YES;
}

-(void)hideKeyboardAndStartRequest
{
    [[startTableview TPKeyboardAvoiding_findFirstResponderBeneathView:startTableview] resignFirstResponder];
    
    [self startAddContactRequest];
}

-(void)startAddContactRequest
{
    [self userInputLocalSaveInController];
    
    //数据上传
    ContactsModel * model = (ContactsModel *) _dpModel;
    if(!model){
        model = [[ContactsModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    model.contactName = _editModel.contactName;
    model.contactMobile = _editModel.contactMobile;
    model.contactPwd = _editModel.contactPwd;
    model.isContacted = self.noticeState?@"1":@"0";
    
    NSString * relation = _editModel.relation;
    if(relation && [relation isEqualToString:ZA_Relation_Replace_TXT]){
        relation = nil;
    }
    model.relation = relation;
    [model sendRequest];
    
}
-(void)refreshWithSuccess
{
    //获取数据
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    
    BOOL showRed = !self.noticeState;//为NO时需要展示
    local.contactRed_Need_Show = showRed;
    //处理红点提示逻辑
//    if(showRed)//不判定是否状态改变
    
    NSArray * contacts = [ContactsModel contactsArrayAddOrUpdateWithModel:_editModel  andArray:local.contacts];
    local.contacts = contacts;
    [local localSave];
    
    {//发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACT_REDCIRCLE_STATE
                                                            object:[NSNumber numberWithInt:showRed]];
    }
    
    if(!self.addMore)
    {
        UIViewController * vc = self.navigationController;
        if([vc presentingViewController])
        {
            [vc dismissViewControllerAnimated:YES completion:nil];
        }else{
            //替换
            AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDel refreshWindowRootViewController];
        }
        return;
    }
    
    //清空本地数据
    self.editModel = [[ContactsModel alloc] init];
    BOOL hideBtn = [contacts count]>=([ZA_Contacts_List_Max_Num intValue]-1);
    moreBtn.hidden = hideBtn;
    
    //列表动画，清空，继续添加更多
    UITableView * table = startTableview;
    [table beginUpdates];
    NSIndexSet * set = [NSIndexSet indexSetWithIndex:0];
    [table deleteSections:set withRowAnimation:UITableViewRowAnimationLeft];
    [table insertSections:set withRowAnimation:UITableViewRowAnimationRight];
    [table endUpdates];
}
#pragma mark ContactsModel
handleSignal( ContactsModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( ContactsModel, requestLoading )
{
    [self showLoading];
}

handleSignal( ContactsModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [self refreshWithSuccess];
    }
}
#pragma mark -
-(NSString *)textFromCellTfdWithIndexNum:(NSInteger)index
{
    ZAContactAddSecondCell *cell = (ZAContactAddSecondCell *)[startTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell.editTfd.text;
}

-(void)tapedOnLocalContactList:(id)sender
{
    [KMStatis staticLocalContactsEvent:StaticPaPaLocalContactsEventType_Start];
    [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_AddressList];
    
    
    __weak typeof(self) weakSelf = self;
    //已经许可
    if([ZAAddressController addressBookAuthNeverStarted])
    {
        [self startShowAddressAuthorityViewWithBlock:^(BOOL enable)
        {
            if(enable)
            {
                [weakSelf startAddressListAddContact];
                [weakSelf localAddressEnableForNext];

            }else{
//                [weakSelf showAddressDiaAlert];
            }
        }];
        
    }else
    {
        [ZAAddressController startAddressAddWithBlock:^(BOOL enable){
            if(enable)
            {
                [weakSelf localAddressEnableForNext];
                
            }else{
                [weakSelf showAddressDiaAlert];
            }
        }];
    }
    
}

-(void)showAddressDiaAlert
{
    if(!self.diaAlert)
    {
        NSString * log = kAddress_Service_Notice;
        UIAlertView * alert  = nil;
        if(iOS8_constant_or_later)
        {
            log = kAddress_Service_Notice_Over8;
            alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                               message:log
                                              delegate:self
                                     cancelButtonTitle:@"设置"
                                     otherButtonTitles:@"取消", nil];
        }else{
            alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                               message:log
                                              delegate:nil
                                     cancelButtonTitle:@"确定"
                                     otherButtonTitles:nil, nil];
        }
        
        self.diaAlert = alert;
    }
    [self.diaAlert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //进行首次的定位功能启动提示
    if(buttonIndex==0){
        [[ZALocation sharedInstance] openSystemLocationSettingPage:nil];
    }
}


-(void)localAddressEnableForNext
{
    //获取权限后的处理
    
    __weak typeof(self) weakSelf  = self;
    ZAAddressController * address = [[ZAAddressController alloc] init];
    address.TapedOnSelectAddressPerson = ^(id obj)
    {
        [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_AddressList_Success];
        [weakSelf refreshLocalViewWithBackData:obj];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:address animated:YES];
}
-(void)startAddressListAddContact
{
    [ZAAddressController addContactToUserAddressList];
}

-(void)refreshLocalViewWithBackData:(id)obj
{
    THContact *user = (THContact *)obj;
    
    _editModel.contactName = user.updateFullName;
    NSString * telNum = user.phone;
    telNum = [telNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    telNum = [telNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
    telNum = [telNum stringByReplacingOccurrencesOfString:@"(" withString:@""];
    telNum = [telNum stringByReplacingOccurrencesOfString:@")" withString:@""];
    _editModel.contactMobile = telNum;
    
    [startTableview reloadData];
}

////上下边线
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 1.0;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
//    line.backgroundColor = START_LOING_LINE_COLOR;
//
//    //    line.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    return line;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 1.0;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
//    line.backgroundColor = START_LOING_LINE_COLOR;
//
//    //    line.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    return line;
//}

//cell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FLoatChange(47);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    //针对rowNum = 0返回普通视图
    
    
    static NSString *cellDetailIdentifier = @"ZAContactAddSecondCell";
    ZAStartLoginCell *cell = (ZAStartLoginCell *)[tableView dequeueReusableCellWithIdentifier:cellDetailIdentifier];
    if (cell == nil)
    {
        cell = [[ZAStartLoginCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDetailIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if(rowNum == 0)
    {
        //添加按钮
        CGRect rect = relationBtn.frame;
        rect.origin.x = SCREEN_WIDTH - rect.size.width - FLoatChange(5);//
        rect.origin.y = (FLoatChange(47) - rect.size.height)/2.0;
        
        //        rect = [startTableview convertRect:rect fromView:cell];
        relationBtn.frame = rect;
        [cell addSubview:relationBtn];
        
        NSString * txt = ZA_Relation_Replace_TXT;
        if(_editModel.relation) txt = _editModel.relation;
        [relationBtn setTitle:txt forState:UIControlStateNormal];
    }
    
    cell.editTfd.clearButtonMode = (rowNum==0)?UITextFieldViewModeNever:UITextFieldViewModeWhileEditing;

    UIKeyboardType keyboard = UIKeyboardTypeNumberPad;
    if(rowNum != 1) keyboard = UIKeyboardTypeDefault;
    
    NSString * hold = @"紧急联系人的姓名";
    NSString * txtValue = _editModel.contactName;
    switch (rowNum) {
        case 0:
            hold = @"紧急联系人的姓名";
            txtValue = _editModel.contactName;

            break;
        case 1:
            hold = @"紧急联系人的手机号码";
            txtValue = _editModel.contactMobile;
            break;
        case 2:
            hold = @"请填写一个你们认识的共同的朋友";
            txtValue = _editModel.contactPwd;
            break;
        default:
            break;
    }
    cell.editTfd.text = txtValue;
    cell.editTfd.placeholder = hold;
    cell.editTfd.keyboardType = keyboard;
    //    cell.headerLbl.image = [UIImage imageNamed:@"back"];
    //    cell.editTfd.text = [NSString stringWithFormat:@"姓名%ld",indexPath.section];
    cell.endEditBtn.hidden = YES;
    cell.headerLbl.hidden = YES;
    NSInteger count = [tableView numberOfRowsInSection:0];
    cell.bottomLine.hidden = (rowNum == count-1);
    return cell;
}
-(void)userInputLocalSaveInController
{
    //数据保存
    NSString * name =  [self textFromCellTfdWithIndexNum:0];
    NSString * telNum = [self textFromCellTfdWithIndexNum:1];
    NSString * friend = [self textFromCellTfdWithIndexNum:2];
    NSString * relation = [relationBtn.titleLabel text];
    //关系人
    
    _editModel.contactName = name;
    _editModel.contactMobile = telNum;
    _editModel.contactPwd = friend;
    _editModel.relation = relation;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //本地临时存储
    [self userInputLocalSaveInController];
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
