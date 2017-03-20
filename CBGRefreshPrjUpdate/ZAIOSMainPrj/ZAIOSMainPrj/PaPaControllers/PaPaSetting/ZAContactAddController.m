//
//  ZAContactAddController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/10.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAContactAddController.h"
#import "ZAAddressController.h"
#import "ZAContactAddRLController.h"
#import "THContact.h"
#import "ZAContactAddSecondCell.h"
#import "ZAContactEditCell.h"
#import "TPKeyboardAvoidingTableView.h"
@interface ZAContactAddController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * editTable;
}
@property (nonatomic,strong) ContactsModel * editModel;

@end

@implementation ZAContactAddController


- (void)viewDidLoad {
    self.showLeftBtn = YES;
    self.showRightBtn = YES;
    self.viewTtle = @"添加紧急联系人";
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
    [table registerClass:[ZAContactAddSecondCell class] forCellReuseIdentifier:@"ZAContactAddSecondCell"];
    
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.separatorColor = [UIColor clearColor];
    table.backgroundColor = [UIColor clearColor];
    
    //顶部通讯录
    rect = [[UIScreen mainScreen] bounds];
    CGFloat topHeight = FLoatChange(55);
    rect.size.height = topHeight;
    
    UIView * topView = [[UIView alloc] initWithFrame:rect];
    topView.backgroundColor = [UIColor clearColor];
    
    rect.size.width *=  (170/320.0);
    rect.size.height *= (35/55.0);
    
    UIButton * topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    topBtn.frame = rect;
    topBtn.center = CGPointMake(SCREEN_WIDTH/2.0, topHeight/2.0);
    [topBtn setTitle:@"  从通讯录添加" forState:UIControlStateNormal];
    [topBtn.titleLabel setFont:[UIFont  systemFontOfSize:FLoatChange(15)]];
    [topBtn setImage:[UIImage imageNamed:@"local_contacts_icon"] forState:UIControlStateNormal];
    [topBtn addTarget:self action:@selector(tapedOnLocalContactList:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:topBtn];
    [topBtn setBackgroundColor:Custom_Blue_Button_BGColor];
    table.tableHeaderView = topView;
    [topBtn refreshButtonSelectedBGColor];

    
    //底部下一步
    rect = table.bounds;
    CGFloat bottomHeight = FLoatChange(74);
    rect.size.height = bottomHeight;
    UIView * bottom = [[UIView alloc] initWithFrame:rect];
    bottom.backgroundColor = [UIColor clearColor];
    
    rect.size.width *=  (255/320.0);
    rect.size.height *= (40/74.0);
    
    UIButton * addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMoreBtn.frame = rect;
    addMoreBtn.center = CGPointMake(SCREEN_WIDTH/2.0, bottomHeight/2.0);
    [addMoreBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [addMoreBtn addTarget:self action:@selector(tapedOnNextBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:addMoreBtn];
    [addMoreBtn setBackgroundColor:Custom_Green_Button_BGColor];
    table.tableFooterView = bottom;
    
    self.editModel = [[ContactsModel alloc] init];

    [KMStatis staticLocalContactsEvent:StaticPaPaLocalContactsEventType_Show];


}

-(void)tapedOnNextBtn:(id)sender
{
    //获取数据
    NSString *contactName = [self textFromCellTfdWithIndexNum:0];
    NSString *contactTel = [self textFromCellTfdWithIndexNum:1];
    
    NSString * errorStr = nil;
    //判定紧急联系人姓名
    errorStr = [ZATfdLocalCheck localCheckInputUserNameWithText:contactName];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    //判定电话号码
    errorStr = [ZATfdLocalCheck localCheckInputTelNumWithText:contactTel];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
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
        return;
    }
    
    [[editTable TPKeyboardAvoiding_findFirstResponderBeneathView:editTable] resignFirstResponder];


    ContactsModel * model = [[ContactsModel alloc] init];
    model.contactName = contactName;
    model.contactMobile = contactTel;
    

    ZAContactAddRLController * addRL = [[ZAContactAddRLController alloc] init];
    addRL.editContact = model;
    [[self rootNavigationController] pushViewController:addRL animated:YES];
}

-(NSString *)textFromCellTfdWithIndexNum:(NSInteger)index
{
    ZAContactAddSecondCell *cell = (ZAContactAddSecondCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell.editTfd.text;
}

-(void)tapedOnLocalContactList:(id)sender
{
    [KMStatis staticLocalContactsEvent:StaticPaPaLocalContactsEventType_Start];
    

    
    __weak typeof(self) weakSelf  = self;
    ZAAddressController * address = [[ZAAddressController alloc] init];
    address.TapedOnSelectAddressPerson = ^(id obj){
        [weakSelf refreshLocalViewWithBackData:obj];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:address animated:YES];
}
-(void)refreshLocalViewWithBackData:(id)obj
{
    THContact *user = (THContact *)obj;
    
    _editModel.contactName = user.updateFullName;
    NSString * telNum = user.phone;
    telNum = [telNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    telNum = [telNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
    _editModel.contactMobile = telNum;
    
    [editTable reloadData];
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

//cell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FLoatChange(45);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    //针对rowNum = 0返回普通视图
    
    
    static NSString *cellDetailIdentifier = @"ZAContactAddSecondCell";
    ZAContactAddSecondCell *cell = (ZAContactAddSecondCell *)[tableView dequeueReusableCellWithIdentifier:cellDetailIdentifier];
    if (cell == nil)
    {
        cell = [[ZAContactAddSecondCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDetailIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    UIKeyboardType keyboard = UIKeyboardTypeNumberPad;
    if(rowNum != 1) keyboard = UIKeyboardTypeDefault;
    
    NSString * hold = @"紧急联系人姓名";
    NSString * txtValue = _editModel.contactName;
    switch (rowNum) {
        case 0:
            hold = @"紧急联系人姓名";
            txtValue = _editModel.contactName;
            break;
        case 1:
            hold = @"紧急联系人电话号码";
            txtValue = _editModel.contactMobile;
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
    cell.bottomLine.hidden = (rowNum == 1);
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //数据保存
    NSString * name =  [self textFromCellTfdWithIndexNum:0];
    NSString * telNum = [self textFromCellTfdWithIndexNum:1];

    
    _editModel.contactName = name;
    _editModel.contactMobile = telNum;
    
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
