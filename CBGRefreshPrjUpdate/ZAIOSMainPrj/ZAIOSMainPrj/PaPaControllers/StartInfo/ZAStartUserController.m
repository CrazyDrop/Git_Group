//
//  ZAStartUserController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAStartUserController.h"
#import "ZAStartContactController.h"
@interface ZAStartUserController ()<UITableViewDelegate>
{
    PaPaUserInfoModel * editModel;
}
@end

@implementation ZAStartUserController

- (void)viewDidLoad {
    NSArray * arr = self.navigationController.viewControllers;
    self.showLeftBtn =  [arr count]!=1;
    
    PaPaUserInfoModel * info = [[ZALocalStateTotalModel currentLocalStateModel] userInfo];
    editModel = [info copy];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [bottomBtn addTarget:self action:@selector(tapedOnNextBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)tapedOnNextBtn:(id)sender
{
    //获取数据
    NSString *inputName = [self textFromCellTfdWithIndexNum:0];
    NSString *inputPWD = [self textFromCellTfdWithIndexNum:1];
//    NSString *inputPhoneNum = [self textFromCellTfdWithIndexNum:1];

//    ||!inputPhoneNum||[inputPhoneNum length]==0||!inputPWD||[inputPWD length]==0
    
    NSString * errorStr = nil;
    //判定用户名
    errorStr = [ZATfdLocalCheck localCheckInputUserNameWithText:inputName];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
//    //判定电话号码
//    errorStr = [ZATfdLocalCheck localCheckInputTelNumWithText:inputPhoneNum];
//    if(errorStr)
//    {
//        [DZUtils noticeCustomerWithShowText:errorStr];
//        return;
//    }
    
    //判定本地密码
    errorStr = [ZATfdLocalCheck localCheckInputLocalPWDWithText:inputPWD];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    
    [[startTableview TPKeyboardAvoiding_findFirstResponderBeneathView:startTableview] resignFirstResponder];
    
    editModel.username = inputName;
    editModel.password = inputPWD;
    
    //数据上传
    ModifyUserInfoModel  * model = (ModifyUserInfoModel *) _dpModel;
    if(!model){
        model = [[ModifyUserInfoModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    model.username = inputName;
    model.password = inputPWD;
    [model sendRequest];
}


#pragma mark ModifyUserInfoModel
handleSignal( ModifyUserInfoModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( ModifyUserInfoModel, requestLoading )
{
    [self showLoading];
}

handleSignal( ModifyUserInfoModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [self refreshWithSuccess];
    }
}
#pragma mark -

-(void)refreshWithSuccess
{
//    NSString *inputName = [self textFromCellTfdWithIndexNum:0];
//    NSString *inputPWD = [self textFromCellTfdWithIndexNum:1];
//    
    //长度
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    model.userInfo = [editModel copy];
    model.password = [editModel.password copy];
    [model localSave];
    
    
    ZAStartContactController * contact = [[ZAStartContactController alloc] init];
    [self.navigationController pushViewController:contact animated:YES];
}


-(NSString *)textFromCellTfdWithIndexNum:(NSInteger)index
{
    ZAStartCustomCell *cell = (ZAStartCustomCell *)[startTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell.editTfd.text;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row==0) return FLoatChange(55);
    return FLoatChange(51);
    
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
    
    NSString * iconName = @"name_icon_small";
    NSString * hold = @"请输入您的名字";
    NSString * txt = editModel.username;
    switch (rowNum) {
        case 0:
            iconName = @"name_icon_small";
            hold = @"请输入您的名字";
            txt = editModel.username;
            break;
//        case 1:
//            iconName = @"phoneNum_icon";
//            hold = @"请填写您的联系电话";
//            txt = editModel.mobile;
//            break;
        case 1:
            iconName = @"password_icon";
            hold = @"请设置您的安全密码";
            txt = editModel.password;
            break;
        default:
            break;
    }
    cell.editTfd.text = txt;
    cell.editTfd.placeholder = hold;
    cell.editTfd.keyboardType = keyboard;
    cell.headerImg.image = [UIImage imageNamed:iconName];
//    cell.editTfd.text = [NSString stringWithFormat:@"姓名%ld",indexPath.section];
    cell.endEditBtn.hidden = YES;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *inputName = [self textFromCellTfdWithIndexNum:0];
    NSString *inputPWD = [self textFromCellTfdWithIndexNum:2];
    //    NSString *inputPhoneNum = [self textFromCellTfdWithIndexNum:1];
    //    editModel.mobile = inputPhoneNum;
    
    editModel.username = inputName;
    editModel.password = inputPWD;
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
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
