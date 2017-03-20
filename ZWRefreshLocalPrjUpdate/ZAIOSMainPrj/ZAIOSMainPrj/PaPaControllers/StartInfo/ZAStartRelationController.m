//
//  ZAStartRelationController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAStartRelationController.h"
#import "ZAContactSelectEditController.h"
@interface ZAStartRelationController ()

@end

@implementation ZAStartRelationController

- (void)viewDidLoad {
    self.showLeftBtn = YES;
    [super viewDidLoad];
    topNumView.numIndex = 2;
    // Do any additional setup after loading the view.
    [bottomBtn setTitle:@"完成" forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(tapedOnNextBtn:) forControlEvents:UIControlEventTouchUpInside];
    topGuideLbl.text = @"请选择接头暗号";

}

-(void)tapedOnNextBtn:(id)sender
{
    //获取数据
    NSString *relation = [self textFromCellTfdWithIndexNum:1];
    NSString *inputPWD = [self textFromCellTfdWithIndexNum:2];
    
    //数据校验
    NSString * errorStr = nil;
    //判定联系人姓名
    errorStr = [ZATfdLocalCheck localCheckInputContactRelationNameWithText:relation];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    //判定电话号码
    errorStr = [ZATfdLocalCheck localCheckInputContactPWDWithText:inputPWD];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }

    
    [[startTableview TPKeyboardAvoiding_findFirstResponderBeneathView:startTableview] resignFirstResponder];

    
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
    
//    //界面仅1次展示
//    ContactsModel * model = [[ContactsModel alloc] init];
//    model.contactName = _editContact.contactName;
//    model.contactMobile = _editContact.contactMobile;
//    model.relation = relation;
//    model.contactPwd = inputPWD;
//    model.id = [NSString stringWithFormat:@"1"];
//    [ContactsModel contactSaveToLocalWithObj:model];
    
//    NSUserDefaults * stand = [NSUserDefaults standardUserDefaults];
//    [stand setObject:[NSNumber numberWithBool:YES]  forKey:USERDEFAULT_StartInfo_Finished];
//    [stand synchronize];
    [DZUtils localSaveObject:@"1" withKeyStr:USERDEFAULT_StartInfo_Finished];
    
    //界面返回
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    ZAStartCustomCell *cell = (ZAStartCustomCell *)[startTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell.editTfd.text;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    static NSString *cellDetailIdentifier = @"StartCustomCell";
    ZAStartCustomCell *cell = (ZAStartCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellDetailIdentifier];
    if (cell == nil)
    {
        cell = [[ZAStartCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDetailIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    UIKeyboardType keyboard = UIKeyboardTypeNumberPad;
    if(rowNum == 0) keyboard = UIKeyboardTypeDefault;
    
    NSString * hold = @"选择与紧急联系人的关系";
    NSString * iconName = @"name_icon";
    NSString * txtValue = _editContact.contactName;
    switch (rowNum) {
        case 0:
            hold = @"紧急联系人姓名";
            iconName = @"name_icon";
            txtValue = _editContact.contactName;
            break;
        case 1:
            hold = @"选择与紧急联系人的关系";
            iconName = @"relation_icon";
            txtValue = _editContact.relation;
            break;
        case 2:
            hold = @"输入或选择接头暗号";
            iconName = @"contact_pwd_icon";
            txtValue = _editContact.contactPwd;
            break;
        default:
            break;
    }
    [cell refreshHeaderImgWith];
    cell.editTfd.text = txtValue;
    cell.editTfd.enabled = NO;
    cell.editTfd.placeholder = hold;
    cell.editTfd.keyboardType = keyboard;
    cell.headerImg.image = [UIImage imageNamed:iconName];
    //    cell.editTfd.text = [NSString stringWithFormat:@"姓名%ld",indexPath.section];
    cell.endEditBtn.hidden = (rowNum == 0);
    
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
    [startTableview reloadData];
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
