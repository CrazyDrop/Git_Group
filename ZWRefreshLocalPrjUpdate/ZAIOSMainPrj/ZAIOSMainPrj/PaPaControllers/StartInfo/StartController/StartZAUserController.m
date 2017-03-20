//
//  StartZAUserController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/19.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "StartZAUserController.h"
#import "ZAContactAddSecondCell.h"
#import "StartZAContactController.h"
#import "ZAStartLoginCell.h"
@interface StartZAUserController ()
{
    PaPaUserInfoModel * editModel;
}
@end

@implementation StartZAUserController

- (void)viewDidLoad {
    NSArray * arr = self.navigationController.viewControllers;
    self.showLeftBtn =  [arr count]!=1;
    self.showLeftBtn = NO;
    PaPaUserInfoModel * info = [[ZALocalStateTotalModel currentLocalStateModel] userInfo];
    editModel = [info copy];
    self.viewTtle = @"设置个人信息";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString * title = @"输入安全密码是您解除防护或预警的专属方式，请务必牢记密码！";
    topGuideLbl.text = title;
    
    [bottomBtn addTarget:self action:@selector(tapedOnNextBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)tapedOnNextBtn:(id)sender
{
    [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_Next];

    
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
    
    [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_Next_Success];

    
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
    
    
    
    StartZAContactController * contact = [[StartZAContactController alloc] init];
    [self.navigationController pushViewController:contact animated:YES];
}


-(NSString *)textFromCellTfdWithIndexNum:(NSInteger)index
{
    ZAContactAddSecondCell *cell = (ZAContactAddSecondCell *)[startTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell.editTfd.text;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FLoatChange(47);
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    static NSString *cellDetailIdentifier = @"StartCustomCell";
    ZAStartLoginCell *cell = (ZAStartLoginCell *)[tableView dequeueReusableCellWithIdentifier:cellDetailIdentifier];
    if (cell == nil)
    {
        cell = [[ZAStartLoginCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDetailIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    NSInteger count = [tableView numberOfRowsInSection:0];
    cell.bottomLine.hidden = (rowNum == count-1);
    
    UIKeyboardType keyboard = UIKeyboardTypeNumberPad;
    if(rowNum == 0) keyboard = UIKeyboardTypeDefault;
    
    NSString * iconName = @"name_icon_small";
    NSString * hold = @"请留大名,您的朋友要认得出你哦";
    NSString * txt = editModel.username;
    switch (rowNum) {
        case 0:
            iconName = @"name_icon_small";
            hold = @"请留大名,您的朋友要认得出你哦";
            txt = editModel.username;
            break;
            //        case 1:
            //            iconName = @"phoneNum_icon";
            //            hold = @"请填写您的联系电话";
            //            txt = editModel.mobile;
            //            break;
        case 1:
            iconName = @"password_icon";
            hold = @"4位安全密码，仅解除防护时使用";
            txt = editModel.password;
            break;
        default:
            break;
    }
    cell.editTfd.text = txt;
    cell.editTfd.placeholder = hold;
    cell.editTfd.keyboardType = keyboard;
//    cell.headerImg.image = [UIImage imageNamed:iconName];
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
