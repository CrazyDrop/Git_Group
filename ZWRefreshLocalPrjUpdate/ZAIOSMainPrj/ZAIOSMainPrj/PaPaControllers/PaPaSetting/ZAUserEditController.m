//
//  ZAUserEditController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/22.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAUserEditController.h"
#import "ZAContactEditCell.h"
#import "TPKeyboardAvoidingTableView.h"
@interface ZAUserEditController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView * editTable;
    PaPaUserInfoModel * editModel;
}
@end

@implementation ZAUserEditController
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[editTable TPKeyboardAvoiding_findFirstResponderBeneathView:editTable] resignFirstResponder];
    
}

- (void)viewDidLoad {
    self.viewTtle = @"个人信息";
    self.rightTitle = @"保存";
    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PaPaUserInfoModel * info = [[ZALocalStateTotalModel currentLocalStateModel] userInfo];
    editModel = [info copy];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y = CGRectGetMaxY(self.titleBar.frame);
    rect.size.height -= rect.origin.y;
    
    UITableView * table = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
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
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
    return 1;
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
            //此处无效
//            UIView * bgView = [[UIView alloc] initWithFrame:cell.bounds];
//            bgView.backgroundColor = [UIColor redColor];
//            bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//            cell.selectedBackgroundView = bgView;
        }
        PaPaUserInfoModel * model = editModel;
        
        cell.endEditBtn.hidden = YES;
        cell.editTfd.enabled = YES;
        cell.bottomLine.hidden = indexNum==1;
        
        cell.editTfd.userInteractionEnabled = indexNum==1;
        
        NSString * preTxt = @"姓名:";
        NSString * hold = @"请输入您的姓名";
        NSString * contentTxt  = model.username;
        
        UIKeyboardType showType = UIKeyboardTypeDefault;
        switch (indexNum) {
            case 1:
            {
                hold = @"请输入您的姓名";
                preTxt = @"姓名:";
                showType = UIKeyboardTypeDefault;
                contentTxt  = model.username;
            }
                break;
            case 0:
            {
                hold = @"请输入您的联系电话";
                preTxt = @"电话:";
                showType = UIKeyboardTypeNumberPad;
                contentTxt  = model.mobile;
            }
                break;
            default:
                break;
        }
        cell.editTfd.placeholder = hold;
        cell.editTfd.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.headerLbl.text = preTxt;
        cell.editTfd.text = contentTxt;
        cell.editTfd.keyboardType = showType;
        return cell;
    }
    
    NSAssert(YES, @"逻辑上不会到达");
    return  nil;
}
-(NSString *)textFromCellTfdWithIndexNum:(NSInteger)index
{
    ZAContactEditCell *cell = (ZAContactEditCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell.editTfd.text;
}

-(void)submit
{
    //数据检查
    NSString * name =  [self textFromCellTfdWithIndexNum:1];
    NSString * telNum = [self textFromCellTfdWithIndexNum:0];
    
    NSString * errorStr = nil;
    //判定用户名
    errorStr = [ZATfdLocalCheck localCheckInputUserNameWithText:name];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    //判定电话号码
    errorStr = [ZATfdLocalCheck localCheckInputTelNumWithText:telNum];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    
    editModel.username = name;
    
    //数据上传
    ModifyUserInfoModel  * model = (ModifyUserInfoModel *) _dpModel;
    if(!model){
        model = [[ModifyUserInfoModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    model.username = name;
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
    //数据检查
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.userInfo = [editModel copy];
    [total localSave];
    
    //密码，用户名保存
    

    [[editTable TPKeyboardAvoiding_findFirstResponderBeneathView:editTable] resignFirstResponder];

    
    [self.navigationController popViewControllerAnimated:YES];
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.selected = YES;
    
    NSString * name =  [self textFromCellTfdWithIndexNum:1];
    NSString * telNum = [self textFromCellTfdWithIndexNum:0];
    PaPaUserInfoModel * info = editModel;
    info.username = name;
    info.mobile = telNum;
    
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
