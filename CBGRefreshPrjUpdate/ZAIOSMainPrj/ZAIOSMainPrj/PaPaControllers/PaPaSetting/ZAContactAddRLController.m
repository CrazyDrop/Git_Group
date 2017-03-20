//
//  ZAContactAddRLController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/22.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactAddRLController.h"
#import "ZAStartCustomCell.h"
#import "ZAContactAddSecondCell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "ZAContactListController.h"
#import "ZAContactSelectEditController.h"
@interface ZAContactAddRLController ()<UITableViewDataSource,UITableViewDelegate>
{
        UITableView * editTable;
}
@end

@implementation ZAContactAddRLController

- (void)viewDidLoad {
    self.showRightBtn = YES;
    self.viewTtle = @"添加紧急联系人";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    
    
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
    [table registerClass:[ZAContactAddSecondCell class] forCellReuseIdentifier:@"ZAContactAddCell"];
    
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.separatorColor = [UIColor clearColor];
    table.backgroundColor = [UIColor clearColor];
    
    CGFloat topSpace = FLoatChange(10);
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topSpace)];
    topView.backgroundColor = [UIColor clearColor];
    table.tableHeaderView = topView;

    
}

-(void)submit
{
    //获取数据
    NSString *relation = [self textFromCellTfdWithIndexNum:1];
    NSString *inputPWD = [self textFromCellTfdWithIndexNum:2];
    
    //数据校验
    NSString * errorStr = nil;
    //判定关系
    errorStr = [ZATfdLocalCheck localCheckInputContactRelationNameWithText:relation];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    //判定暗号
    errorStr = [ZATfdLocalCheck localCheckInputContactPWDWithText:inputPWD];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    
    [[editTable TPKeyboardAvoiding_findFirstResponderBeneathView:editTable] resignFirstResponder];

    
    //数据上传
    ContactsModel * model = (ContactsModel *) _dpModel;
    if(!model){
        model = [[ContactsModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    model.contactName = _editContact.contactName;
    model.contactMobile = _editContact.contactMobile;
    model.contactPwd = inputPWD;
    model.relation = relation;
    
    [model sendRequest];
    
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
//    [self.viewDeckController closeLeftViewAnimated:YES];
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
    ZAStartCustomCell *cell = (ZAStartCustomCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell.editTfd.text;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FLoatChange(45);
}
//上下边线
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    line.backgroundColor = Custom_Gray_Line_Color;
    //    line.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return line;
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    static NSString *cellDetailIdentifier = @"ZAContactAddCell";
    ZAContactAddSecondCell *cell = (ZAContactAddSecondCell *)[tableView dequeueReusableCellWithIdentifier:cellDetailIdentifier];
    if (cell == nil)
    {
        cell = [[ZAContactAddSecondCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDetailIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    UIKeyboardType keyboard = UIKeyboardTypeNumberPad;
    if(rowNum == 0) keyboard = UIKeyboardTypeDefault;
    
    NSString * hold = @"选择与紧急联系人的关系";
    NSString * txtValue = _editContact.contactName;
    switch (rowNum) {
        case 0:
            hold = @"紧急联系人姓名";
            txtValue = _editContact.contactName;
            break;
        case 1:
            hold = @"选择与紧急联系人的关系";
            txtValue = _editContact.relation;
            break;
        case 2:
            hold = @"输入或选择接头暗号";
            txtValue = _editContact.contactPwd;
            break;
        default:
            break;
    }
    
    cell.editTfd.text = txtValue;
    cell.editTfd.enabled = NO;
    cell.editTfd.placeholder = hold;
    cell.editTfd.keyboardType = keyboard;
//    cell.headerImg.image = [UIImage imageNamed:@"back"];
    
    cell.headerLbl.hidden = YES;
    //    cell.editTfd.text = [NSString stringWithFormat:@"姓名%ld",indexPath.section];
    cell.endEditBtn.hidden = (rowNum == 0);
    cell.bottomLine.hidden = (rowNum == 2);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSInteger indexNum = indexPath.row;
    if(indexNum==0) return;
    
    
    ZAContactSelectEditController * edit = [[ZAContactSelectEditController alloc] init];
    ContactsModel * model = _editContact;
    NSString * editStr = model.relation;
    PaPaContactSelectType type = PaPaContact_Select_Relation;
    if(indexNum==2)
    {
        //暗号
        editStr = model.contactPwd;
        type = PaPaContact_Select_PWDString;
    }
    edit.editText = editStr;
    edit.selectType = type;
    __weak typeof(self) weakSelf = self;
    edit.TapedOnFinishedBlock = ^(PaPaContactSelectType type,NSString * endStr){
        [weakSelf refreshContactDataEndText:endStr andType:type];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:edit animated:YES];
    
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
