//
//  ZAStartContactController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/7/21.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAStartContactController.h"
#import "ZAStartRelationController.h"
#import "ZAAddressController.h"
#import "THContact.h"
#import "ZATipsCoverView.h"
@interface ZAStartContactController ()
{

}
@property (nonatomic,strong) ContactsModel * editModel;
@property (nonatomic,strong) UIAlertView * diaAlert;
@end

@implementation ZAStartContactController


- (void)viewDidLoad {
    self.showLeftBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.editModel = [[ContactsModel alloc] init];
    
    topNumView.numIndex = 1;
    [bottomBtn addTarget:self action:@selector(tapedOnNextBtn:) forControlEvents:UIControlEventTouchUpInside];
    topGuideLbl.text = @"请添加紧急联系人";
    
    [KMStatis staticLocalContactsEvent:StaticPaPaLocalContactsEventType_Show];

    [self checkAndShowMainCoverView];

}
-(void)checkAndShowMainCoverView
{
    if(!IOS7_OR_LATER) return;
    ZALocalStateTotalModel * local  = [ZALocalStateTotalModel currentLocalStateModel];
    if(!local.start_Tips_Showed)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        ZATipsCoverView * cover = [[ZATipsCoverView alloc] initWithFrame:rect];
        cover.tipsIdentifier = USERDEFAULT_CoverView_Tips_Start_Show;
        [self.view addSubview:cover];
        
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, 200)];
        lbl.numberOfLines = 0;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;// 字体的行间距
        NSString * strTxt = @"点击按钮从电话簿添加紧急联系人,\n建议添加同城的靠谱室友和朋友哦";
        NSString * fontName = @"Hannotate SC Bold";
        fontName = @"Marion-Bold";
        NSDictionary *ats = @{
                              
                              NSFontAttributeName : [UIFont fontWithName:fontName size:FLoatChange(15)],
                              NSParagraphStyleAttributeName : paragraphStyle,
                              };
        NSAttributedString * attTxt = [[NSAttributedString alloc] initWithString:strTxt attributes:ats];
        lbl.attributedText = attTxt;
        lbl.textColor = [UIColor whiteColor];
        //        lbl.text = @"紧急防护则用于危机状态";
        [cover addSubview:lbl];
        [lbl sizeToFit];
        
        rect = topGuideLbl.frame;
        lbl.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(rect) - lbl.bounds.size.height/2.0 - 10);
        
        rect = [[UIScreen mainScreen] bounds];
        CGFloat bottomHeight = FLoatChange(55);
        rect.size.height = bottomHeight;
        
        UIView * bottom = [[UIView alloc] initWithFrame:rect];
        bottom.backgroundColor = [UIColor clearColor];
        
        rect.size.width *=  (170/320.0);
        rect.size.height *= (35/55.0);
        
        UIButton * addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addMoreBtn.frame = rect;
        addMoreBtn.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(topGuideLbl.frame) +bottomHeight - rect.size.height/2.0 - 5);
        [addMoreBtn setTitle:@"  从通讯录添加" forState:UIControlStateNormal];
        [addMoreBtn.titleLabel setFont:[UIFont  systemFontOfSize:FLoatChange(15)]];
        [addMoreBtn setImage:[UIImage imageNamed:@"local_contacts_icon"]  forState:UIControlStateNormal];
//        [addMoreBtn addTarget:self action:@selector(tapedOnLocalContactList:) forControlEvents:UIControlEventTouchUpInside];
        [cover addSubview:addMoreBtn];
        addMoreBtn.userInteractionEnabled = NO;
        [addMoreBtn setBackgroundColor:Custom_Blue_Button_BGColor];
        [addMoreBtn refreshButtonSelectedBGColor];
    }
}


-(void)tapedOnNextBtn:(id)sender
{
    //获取数据
    NSString *contactName = [self textFromCellTfdWithIndexNum:0];
    NSString *contactTel = [self textFromCellTfdWithIndexNum:1];
    
    NSString * errorStr = nil;
    //判定联系人姓名
    errorStr = [ZATfdLocalCheck localCheckInputContactNameWithText:contactName];
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

    
    [[startTableview TPKeyboardAvoiding_findFirstResponderBeneathView:startTableview] resignFirstResponder];

    
    ContactsModel * model = [[ContactsModel alloc] init];
    model.contactName = contactName;
    model.contactMobile = contactTel;
    
    ZAStartRelationController * relation = [[ZAStartRelationController alloc] init];
    relation.editContact = model;
    [self.navigationController pushViewController:relation animated:YES];
    
}

-(NSString *)textFromCellTfdWithIndexNum:(NSInteger)index
{
    ZAStartCustomCell *cell = (ZAStartCustomCell *)[startTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
    return cell.editTfd.text;
}

-(void)tapedOnLocalContactList:(id)sender
{
    [KMStatis staticLocalContactsEvent:StaticPaPaLocalContactsEventType_Start];
    
}

-(void)refreshLocalViewWithBackData:(id)obj
{
    THContact *user = (THContact *)obj;
    
    _editModel.contactName = user.updateFullName;
    NSString * telNum = user.phone;
    telNum = [telNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    telNum = [telNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
    _editModel.contactMobile = telNum;
    
    [startTableview reloadData];
}


//头部
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==1) return 0;
    return FLoatChange(55);
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==1) return nil;
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat bottomHeight = FLoatChange(55);
    rect.size.height = bottomHeight;
    
    UIView * bottom = [[UIView alloc] initWithFrame:rect];
    bottom.backgroundColor = [UIColor clearColor];
    
    rect.size.width *=  (170/320.0);
    rect.size.height *= (35/55.0);
    
    UIButton * addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addMoreBtn.frame = rect;
    addMoreBtn.center = CGPointMake(SCREEN_WIDTH/2.0, bottomHeight - rect.size.height/2.0 - 5);
    [addMoreBtn setTitle:@"  从通讯录添加" forState:UIControlStateNormal];
    [addMoreBtn.titleLabel setFont:[UIFont  systemFontOfSize:FLoatChange(15)]];
    [addMoreBtn setImage:[UIImage imageNamed:@"local_contacts_icon"]  forState:UIControlStateNormal];
    [addMoreBtn addTarget:self action:@selector(tapedOnLocalContactList:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:addMoreBtn];
    [addMoreBtn setBackgroundColor:Custom_Blue_Button_BGColor];
    [addMoreBtn refreshButtonSelectedBGColor];
 
    return bottom;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//cell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0) return 0;
    return FLoatChange(51);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0) return 0;
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    //针对rowNum = 0返回普通视图

    
    static NSString *cellDetailIdentifier = @"StartCustomCell";
    ZAStartCustomCell *cell = (ZAStartCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellDetailIdentifier];
    if (cell == nil)
    {
        cell = [[ZAStartCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDetailIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    UIKeyboardType keyboard = UIKeyboardTypeNumberPad;
    if(rowNum != 1) keyboard = UIKeyboardTypeDefault;
    
    NSString * hold = @"紧急联系人姓名";
    NSString * txtValue = _editModel.contactName;
    NSString * iconName = @"name_icon_small";
    switch (rowNum) {
        case 0:
            hold = @"紧急联系人姓名";
            iconName = @"name_icon_small";
            txtValue = _editModel.contactName;
            break;
        case 1:
            hold = @"紧急联系人联系电话";
            iconName = @"phoneNum_icon";
            txtValue = _editModel.contactMobile;
            break;
        default:
            break;
    }
    cell.editTfd.text = txtValue;
    cell.editTfd.placeholder = hold;
    cell.editTfd.keyboardType = keyboard;
    cell.headerImg.image = [UIImage imageNamed:iconName];
    //    cell.editTfd.text = [NSString stringWithFormat:@"姓名%ld",indexPath.section];
    cell.endEditBtn.hidden = YES;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *contactName = [self textFromCellTfdWithIndexNum:0];
    NSString *contactTel = [self textFromCellTfdWithIndexNum:1];
    _editModel.contactMobile = contactTel;
    _editModel.contactName = contactName;
    
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
