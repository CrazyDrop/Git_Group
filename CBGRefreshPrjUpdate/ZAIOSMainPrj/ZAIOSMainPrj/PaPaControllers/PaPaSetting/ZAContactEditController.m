//
//  ZAContactEditController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/17.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactEditController.h"
#import "ZAContactListCell.h"
#import "ZAContactEditCell.h"
#import "ZAContactSelectEditController.h"
#import "ZAContactListController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "MSAlertController.h"
@interface ZAContactEditController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView * editTable;
    UIButton * relationBtn;
    BOOL refreshed;
    BaseRequestModel * _delModel;
}
@property (nonatomic,copy) ContactsModel * compareObj;
@property (nonatomic,strong) UIAlertView * diaAlert;
@end

@implementation ZAContactEditController

- (void)viewDidLoad {
    self.viewTtle = @"联系人设置";
    self.rightTitle = @"保存";
    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y = CGRectGetMaxY(self.titleBar.frame);
    rect.size.height -= rect.origin.y;
    
    TPKeyboardAvoidingTableView * table = [[TPKeyboardAvoidingTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [self.view addSubview:table];
    table.dataSource = self;
    table.delegate = self;
    editTable = table;
//    table.rowHeight = FLoatChange(44);
//    self.listTable = table;
    [table registerClass:[ZAContactEditCell class] forCellReuseIdentifier:@"ContactListDetailCell"];
    
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.separatorColor = [UIColor clearColor];
    table.backgroundColor = [UIColor clearColor];
    
    CGFloat topSpace = FLoatChange(10);
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topSpace)];
    topView.backgroundColor = [UIColor clearColor];
    table.tableHeaderView = topView;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:ZA_Relation_Replace_TXT forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tapedOnSelectRealtionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:Custom_Blue_Button_BGColor forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(14)]];

    //实际使用高度
    btn.backgroundColor = [UIColor clearColor];
    CGFloat btnHeight = FLoatChange(40);
    CGFloat btnWidth = FLoatChange(80);
    btn.frame = CGRectMake(0, 0, btnWidth, btnHeight);
    relationBtn = btn;
    
    UIView * line = [DZUtils ToolCustomLineView];
    rect = line.frame;
    rect.size.width = rect.size.height;
    rect.size.height = btnHeight * 0.8;
    line.frame = rect;
    [btn addSubview:line];
    line.center = CGPointMake(FLoatChange(-5), btnHeight/2.0);
    
    
    self.compareObj = [self.editContact copy];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self firstTfdBecomeResponsder];
}

-(void)firstTfdBecomeResponsder
{
    if(refreshed) return;
    ZAContactEditCell *cell = (ZAContactEditCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.editTfd becomeFirstResponder];
    refreshed = YES;
}


-(void)submit
{
    
    if(self.editUnable)
    {
        [DZUtils noticeCustomerWithShowText:@"您已经添加了三位有效联系人，请删除一位再添加"];
        return;
    }
    
    //数据检查
    NSString * name =  [self textFromCellTfdWithIndexNum:0];
    NSString * telNum = [self textFromCellTfdWithIndexNum:1];
    NSString * pwd =  [self textFromCellTfdWithIndexNum:2];
    NSString * relation =  relationBtn.titleLabel.text;
    
    NSString * errorStr = nil;
    //判定用户名
    errorStr = [ZATfdLocalCheck localCheckInputContactNameWithText:name];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    
    //判定关系
    if([relation isEqualToString:ZA_Relation_Replace_TXT])
    {
        relation = nil;
    }else
    {
        errorStr = [ZATfdLocalCheck localCheckInputContactRelationNameWithText:relation];
        if(errorStr)
        {
            [DZUtils noticeCustomerWithShowText:errorStr];
            return;
        }
    }


    //判定电话号码
    errorStr = [ZATfdLocalCheck localCheckInputTelNumWithText:telNum];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    //判定本地密码
    errorStr = [ZATfdLocalCheck localCheckInputContactPWDWithText:pwd];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    

    [[editTable TPKeyboardAvoiding_findFirstResponderBeneathView:editTable] resignFirstResponder];

    
    //进行个人信息提交、保存
    _editContact.contactName = name;
    _editContact.contactMobile = telNum;
    _editContact.contactPwd = pwd;
    _editContact.relation = relation;
    
    if(self.unableAndCompare && [_editContact.description isEqualToString:self.compareObj.description])
    {
        [self showDialogForNoneEditError];
        return;
    }
    
    [self startEditContactModelRequest];
    
}
-(void)showDialogForNoneEditError
{
    if(!self.diaAlert)
    {
        NSString * log = @"当前无网络，请检查您的网络，您的救助请求已发送，我们仍会和您及您的朋友联系。";
        log = @"检测到联系人信息没有变化，是否仍将其设置为有效联系人";
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:log
                                                        delegate:self
                                               cancelButtonTitle:@"不用了"
                                               otherButtonTitles:@"是的", nil];
        self.diaAlert = alert;
    }
    [self.diaAlert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 1 && alertView == self.diaAlert)
    {
        //展示添加紧急联系人页面
        [self startEditContactModelRequest];
    }
    
}
-(void)startEditContactModelRequest
{
    //数据上传
    ContactsModel * model = (ContactsModel *) _dpModel;
    if(!model){
        model = [[ContactsModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    model.id = _editContact.id;
    model.contactName = _editContact.contactName;
    model.contactMobile = _editContact.contactMobile;
    model.contactPwd = _editContact.contactPwd;
    model.relation = _editContact.relation;
    model.isDeleted = @"0";
    
    [model sendRequest];
}

-(void)tapedOnSelectRealtionBtn:(id)sender
{
    ZAContactSelectEditController * edit = [[ZAContactSelectEditController alloc] init];
    ContactsModel * model = _editContact;
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
    _editContact.relation = txt;
    
    NSString * lastTxt = ZA_Relation_Replace_TXT;
    if(_editContact.relation) lastTxt = _editContact.relation;
    [relationBtn setTitle:lastTxt forState:UIControlStateNormal];
}
-(void)refreshWithSuccess
{
    //获取数据
    //    NSString *inputName = [self textFromCellTfdWithIndexNum:0];
    //    NSString *relation = [self textFromCellTfdWithIndexNum:1];
    //    NSString *inputPWD = [self textFromCellTfdWithIndexNum:2];
    
    ZALocalStateTotalModel * local = [ZALocalStateTotalModel currentLocalStateModel];
    NSArray * contacts = [ContactsModel contactsArrayAddOrUpdateWithModel:_editContact  andArray:local.contacts];
    local.contacts = contacts;
    [local localSave];
    
    [self refreshForGoBack];
}
-(void)refreshForGoBack
{
    //界面返回
    //界面返回
    __block ZAContactListController * vc = nil;
    NSArray * array = self.navigationController.viewControllers;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[ZAContactListController class]]){
            vc = obj;
        }
    }];
    
    if(vc&&[vc isKindOfClass:[ZAContactListController class]])
    {
        vc.refreshList = YES;
        [self.navigationController popToViewController:vc animated:YES];
    }else{
        [self.navigationController  popViewControllerAnimated:YES];
    }
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
    ZAContactEditCell *cell = (ZAContactEditCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell.editTfd.text;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.row==0)
//        return FLoatChange(44);
    
    return FLoatChange(47);
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger secNum = indexPath.section;
    NSInteger indexNum = indexPath.row;
    
//    if([self tableviewShowDetailWithSection:secNum])
    {
        static NSString *cellDetailIdentifier = @"ContactListDetailCell";
        ZAContactEditCell *cell = (ZAContactEditCell *)[tableView dequeueReusableCellWithIdentifier:cellDetailIdentifier];
        if (cell == nil)
        {
            cell = [[ZAContactEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDetailIdentifier];
            cell.backgroundColor = [UIColor clearColor];
        }
        ContactsModel * contact = _editContact;
        
        if(indexNum == 0)
        {
            //添加按钮
            CGRect rect = relationBtn.frame;
            rect.origin.x = SCREEN_WIDTH - rect.size.width - FLoatChange(10);//
            rect.origin.y = (FLoatChange(47) - rect.size.height)/2.0;
            
            //        rect = [editTable convertRect:rect fromView:cell];
            relationBtn.frame = rect;
            [cell addSubview:relationBtn];
            
            NSString * txt = ZA_Relation_Replace_TXT;
            if(contact.relation  && [contact.relation length]!=0) txt = contact.relation;
            [relationBtn setTitle:txt forState:UIControlStateNormal];
        }
        cell.editTfd.clearButtonMode = (indexNum==0)?UITextFieldViewModeNever:UITextFieldViewModeWhileEditing;

        cell.endEditBtn.hidden = YES;
//        cell.editTfd.enabled = (indexNum==2 || indexNum==0);
        cell.editTfd.enabled = YES;
        cell.bottomLine.hidden = indexNum==3;
        
        NSString * preTxt = @"关系:";
        NSString * hold = @"选择与紧急联系人的关系";
        NSString * contentTxt  = contact.relation;
        
        UIKeyboardType showType = UIKeyboardTypeDefault;
        switch (indexNum) {
            case 1:
            {
                preTxt = @"电话:";
                showType = UIKeyboardTypeNumberPad;
                contentTxt = contact.contactMobile;
                hold = @"紧急联系人联系电话";
            }
                break;
            case 2:
            {
                preTxt = @"朋友:";
                showType = UIKeyboardTypeDefault;
                contentTxt = contact.contactPwd;
                hold = @"请填写一个你们认识的共同的朋友";
            }
                break;
            case 0:
            {
                preTxt = @"姓名:";
                showType = UIKeyboardTypeDefault;
                contentTxt = contact.contactName;
                hold = @"紧急联系人姓名";
            }
                break;
            default:
                break;
        }
        cell.editTfd.placeholder = hold;
        cell.headerLbl.text = preTxt;
        cell.editTfd.text = contentTxt;
        cell.editTfd.keyboardType = showType;
        return cell;
    }
    
    NSAssert(YES, @"逻辑上不会到达");
    return  nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //数据保存
    NSString * name =  [self textFromCellTfdWithIndexNum:0];
    NSString * telNum = [self textFromCellTfdWithIndexNum:1];
    NSString * pwd =  [self textFromCellTfdWithIndexNum:2];
    NSString * relation =  relationBtn.titleLabel.text;
    
    _editContact.contactName = name;
    _editContact.contactMobile = telNum;
    _editContact.relation = relation;
    _editContact.contactPwd = pwd;
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

//    NSInteger indexNum = indexPath.row;
//    if(indexNum==0||indexNum==2) return;
//    
//    ZAContactSelectEditController * edit = [[ZAContactSelectEditController alloc] init];
//    ContactsModel * model = _editContact;
//    NSString * editStr = model.relation;
//    PaPaContactSelectType type = PaPaContact_Select_Relation;
//    if(indexNum==3)
//    {
//        //暗号
//        editStr = model.contactPwd;
//        type = PaPaContact_Select_PWDString;
//    }
//    edit.editText = editStr;
//    edit.selectType = type;
//    __weak typeof(self) weakSelf = self;
//    edit.TapedOnFinishedBlock = ^(PaPaContactSelectType type,NSString * endStr){
//        [weakSelf refreshContactDataEndText:endStr andType:type];
//        [weakSelf.navigationController popViewControllerAnimated:YES];
//    };
//    [[self rootNavigationController] pushViewController:edit animated:YES];
}
-(void)refreshContactDataEndText:(NSString *)endTxt andType:(PaPaContactSelectType)atype
{
    if(atype == PaPaContact_Select_PWDString)
    {
        _editContact.contactPwd = endTxt;
    }else
    {
        _editContact.relation = endTxt;
    }
    [editTable reloadData];
}

-(void)removeContactObjFromList
{
    
    if(self.canNotRemove)
    {
        [DZUtils noticeCustomerWithShowText:@"无法删除您当前的最后一位紧急联系人"];
        return;
    }
    
    NSString * idStr = self.editContact.id;
    if(!idStr)
    {
        [DZUtils noticeCustomerWithShowText:@"删除失败，请稍后再试"];
        [self refreshForGoBack];
        return;
    }
    
    [self removeCurrentContactObj];
    
}
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

#pragma mark PaPaUserInfoModel
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
        [self refreshForGoBack];
    }
}
#pragma mark -
//上下边线
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FLoatChange(56);
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIFont * font = [UIFont systemFontOfSize:FLoatChange(14)];
    
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, FLoatChange(56));
    UIView * bgView = [[UIView alloc] initWithFrame:rect];
    
    CGFloat btnHeight = FLoatChange(47);
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    rect.origin.y = rect.size.height - btnHeight;
    rect.size.height = btnHeight;
    btn.frame = rect;
    btn.titleLabel.font = font;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"删除当前联系人" forState:UIControlStateNormal];
    [btn refreshZASelectedButtonWithCurrentBGColor:[UIColor whiteColor]];
    [btn addTarget:self action:@selector(removeContactObjFromList) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    line.backgroundColor = Custom_Gray_Line_Color;
    [bgView addSubview:line];
    line.center = CGPointMake(SCREEN_WIDTH/2.0,CGRectGetMinY(btn.frame));
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    line.backgroundColor = Custom_Gray_Line_Color;
    [bgView addSubview:line];
    line.center = CGPointMake(SCREEN_WIDTH/2.0,CGRectGetMaxY(btn.frame));
    
    return bgView;

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    line.backgroundColor = Custom_Gray_Line_Color;
//    line.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return line;
}

-(void)removeCurrentContactObj
{
    //弹出按钮
    NSString * log = [NSString stringWithFormat:@"确定删除当前联系人？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"确定" style:MSAlertActionStyleDestructive handler:^(MSAlertAction *action)
                             {
                                 [weakSelf deleteContactWithCurrentContactId:weakSelf.editContact.id];
                             }];
    [alertController addAction:action];
    
    
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
