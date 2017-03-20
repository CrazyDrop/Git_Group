//
//  ZALoginController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/9.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZALoginController.h"
#import "StartZAUserController.h"
#import "ZAICountDownButton.h"
#import "ZAContactAddSecondCell.h"
#import "StartZAContactController.h"
#import "ZAStartLoginCell.h"
#import "ZAAgreeMentController.h"
#import "FaceAndTopicLabel.h"
#import "PoundTopicModel.h"
#import "AppDelegate.h"
@interface ZALoginController ()<UITableViewDelegate>
{
    PaPaUserInfoModel * editModel;
    ZAICountDownButton * timeBtn;
    BaseRequestModel * _msgModel;
}
@end

@implementation ZALoginController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(IOS7_OR_LATER)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    if(self.needRefreshStateBar)
    {
        [self refreshLoginControllerStateBarForShow];
    }

}
-(void)refreshLoginControllerStateBarForShow
{
    if(IOS7_OR_LATER)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}
-(NSString *)classNameForKMRecord
{
    if(self.kmNoneAppear) return nil;
    
    NSString * str  = [super classNameForKMRecord];
    return str;
}

- (void)viewDidLoad {
    NSArray * arr = self.navigationController.viewControllers;
    self.showLeftBtn =  [arr count]!=1;
    editModel = [[PaPaUserInfoModel alloc] init];
    [super viewDidLoad];
    topGuideLbl.hidden = YES;
    topSelectBGView.hidden = YES;

    topBgView.hidden = YES;
    self.titleBar.hidden = YES;
    
//    [self showSpecialStyleTitle];
    
    // Do any additional setup after loading the view.
    [bottomBtn setTitle:@"开始使用" forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(tapedOnNextBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString * txt = @"验证手机登录使用，代表您已同意《怕怕用户协议》";
    CGRect rect = self.view.bounds;
    rect.size.height = FLoatChange(30);
    __weak typeof(self) weakSelf = self;
    PoundTopicModel * model = [[PoundTopicModel alloc] init];
    model.content = @"《怕怕用户协议》";
    FaceAndTopicLabel * lbl = [[FaceAndTopicLabel alloc] initWithFrame:rect];
    lbl.font = [UIFont systemFontOfSize:FLoatChange(12)];
    lbl.topicArray = [NSArray arrayWithObjects:model, nil];
    lbl.text = txt;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor grayColor];
    lbl.tapTopicBlock = ^(id data){
        [weakSelf showAgreementView];
    };
    [lbl sizeToFit];
    UIView * btnBGView = bottomBtn.superview;
    [btnBGView addSubview:lbl];
    lbl.center = CGPointMake(SCREEN_WIDTH/2.0, btnBGView.bounds.size.height - lbl.bounds.size.height/2.0);
    lbl.backgroundColor = [UIColor clearColor];
    
    
    UILabel * aLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FLoatChange(30))];
    [btnBGView addSubview:aLbl];
    aLbl.textAlignment = NSTextAlignmentCenter;
    aLbl.font = lbl.font;
    aLbl.text = @"填写手机号是为了在您发出预警时，我们能联系到您";
    aLbl.textColor = Custom_Blue_Button_BGColor;
    [aLbl sizeToFit];
    aLbl.center = CGPointMake(SCREEN_WIDTH/2.0, bottomBtn.center.y * 2 - lbl.center.y);
    
    
    ZAICountDownButton * btn = [ZAICountDownButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startRequestForMessageNum) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:Custom_Blue_Button_BGColor forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChange(14)]];
    
    //实际使用高度
    btn.backgroundColor = [UIColor clearColor];
    CGFloat btnHeight = FLoatChange(40);
    CGFloat btnWidth = FLoatChange(90);
    btn.frame = CGRectMake(0, 0, btnWidth, btnHeight);
    
    timeBtn = btn;
    
    UIView * line = [DZUtils ToolCustomLineView];
    rect = line.frame;
    rect.size.width = rect.size.height;
    rect.size.height = btnHeight * 0.8;
    line.frame = rect;
    [btn addSubview:line];
    line.center = CGPointMake(FLoatChange(-5), btnHeight/2.0);
    line.backgroundColor = START_LOING_LINE_COLOR;
    
    //展示特殊的标题形式，分上下两行
    UIView * headerBGView = startTableview.tableHeaderView;
    
    CGFloat startY = FLoatChange(50.0);
    aLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(25)];
    aLbl.text = @"怕怕";
    [aLbl sizeToFit];
    [headerBGView addSubview:aLbl];
    CGSize barSize = headerBGView.bounds.size;
    aLbl.center = CGPointMake(barSize.width/2.0,startY + aLbl.bounds.size.height / 2.0);
    aLbl.textColor = Custom_Blue_Button_BGColor;

    startY += aLbl.bounds.size.height;
    startY += FLoatChange(10);
    
    aLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    aLbl.font = [UIFont systemFontOfSize:FLoatChange(15)];
    aLbl.textColor = [UIColor lightGrayColor];
    aLbl.text = @"papa";
    [aLbl sizeToFit];
    aLbl.textColor = Custom_Blue_Button_BGColor;
    [headerBGView addSubview:aLbl];
    aLbl.center = CGPointMake(barSize.width/2.0, startY + aLbl.bounds.size.height / 2.0);
    
}
-(void)showAgreementView
{
    ZAAgreeMentController * agree = [[ZAAgreeMentController alloc] init];
    [self.navigationController pushViewController:agree animated:YES];
}

-(void)startRequestForMessageNum
{
    //获取数据
    NSString *inputPhoneNum = [self textFromCellTfdWithIndexNum:0];
    
    //格式校验
    NSString * errorStr = nil;
    errorStr = [ZATfdLocalCheck localCheckInputTelNumForUserWithText:inputPhoneNum];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    
    [timeBtn startCountDown];
    
    GetMessageModel * model = (GetMessageModel *)_msgModel;
    if(!model){
        model = [[GetMessageModel alloc] init];
        [model addSignalResponder:self];
        _msgModel = model;
    }
    model.mobile = inputPhoneNum;
    [model sendRequest];
}

#pragma mark GetMessageModel
handleSignal( GetMessageModel, requestError )
{
    [self hideLoading];
    [timeBtn stopCountDown];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( GetMessageModel, requestLoading )
{
    [self showLoading];
}

handleSignal( GetMessageModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        NSString * version = @"短信验证码已发送";
#ifdef  USERDEFAULT_DEBUG_FOR_COMPANY
        version = @"短信验证码已发送123456";
#endif
        [DZUtils noticeCustomerWithShowText:version];
    }else
    {
        [timeBtn stopCountDown];
    }
}
#pragma mark -



-(void)tapedOnNextBtn:(id)sender
{
    [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_Login];

    
    //获取数据
    NSString *inputPhoneNum = [self textFromCellTfdWithIndexNum:0];
    NSString *inputMesNum = [self textFromCellTfdWithIndexNum:1];
    //    ||!inputPhoneNum||[inputPhoneNum length]==0||!inputPWD||[inputPWD length]==0
    
    NSString * errorStr = nil;
//    //判定用户名
//    errorStr = [ZATfdLocalCheck localCheckInputUserNameWithText:inputName];
//    if(errorStr)
//    {
//        [DZUtils noticeCustomerWithShowText:errorStr];
//        return;
//    }
    //判定电话号码
    errorStr = [ZATfdLocalCheck localCheckInputTelNumForUserWithText:inputPhoneNum];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    //判定校验码
    errorStr = [ZATfdLocalCheck localCheckInputMsgNumWithText:inputMesNum];
    if(errorStr)
    {
        [DZUtils noticeCustomerWithShowText:errorStr];
        return;
    }
    
    [KMStatis staticRegisterEvent:StaticPaPaRegisterEventType_Login_Success];

    [[startTableview TPKeyboardAvoiding_findFirstResponderBeneathView:startTableview] resignFirstResponder];
    
    //数据上传
    RegisterModel * model = (RegisterModel *) _dpModel;
    if(!model){
        model = [[RegisterModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    model.mobile = inputPhoneNum;
    model.vcode = inputMesNum;
    [model sendRequest];
}


#pragma mark RegisterModel
handleSignal( RegisterModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( RegisterModel, requestLoading )
{
    [self showLoading];
}

handleSignal( RegisterModel, requestLoaded )
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
    //本地存储
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    
    PaPaUserInfoModel * info = [(RegisterModel *)_dpModel info];
    total.contacts = [info.contactsdtl copy];
    [ContactsModel refreshContactsLocalNoticedForStartLoginWithArray:total.contacts];
    
    
    //当前有预警
    if([info.lock intValue]!=0)
    {
        //创建倒计时model，并本地保存截止时间
        WarnTimingModel * model = [[WarnTimingModel alloc] init];
        model.scene = info.scene;
        model.duration = [NSString stringWithFormat:@"%@",info.duration];
        model.timeId = info.warningId;
        model.whattodo = info.whattodo;
        
        total.warningId = [info.warningId copy];
        total.timeModel = model;
        //预警为倒计时预警，并且时间未完成
        NSInteger remainNum = [info.remain intValue];
        
        //倒计时
        if ([info.scene intValue] == 1 )
        {
            if(remainNum>=0)
            {
                total.endDate = [NSDate dateWithTimeIntervalSinceNow:remainNum];
                total.totalTime = [info.duration intValue]/60;
            }
        }else if([info.scene intValue] == 2 )
        {
            total.totalTime = [info.duration intValue]/60;
            total.showPWD = YES;
        }
    }
    
    BOOL showState = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACT_REDCIRCLE_STATE
                                                        object:[NSNumber numberWithBool:showState]];
    
    total.userInfo = info;
    total.password = [info.password copy];
    
    [total localSave];
    
    //停止本次的网络状态检查
    total.loginHideCheck = YES;
    //长度
    //    NSUserDefaults * stand =  [NSUserDefaults standardUserDefaults];
    //    [stand setValue:inputPWD forKey:USERDEFAULT_PASSWORD_LOCAL];
    //    [stand synchronize];
    
    
    //    [info localSave];
    
    //判定服务器返回数据，控制是否继续补全信息
    if([total isNeedUpdate] || [total isNeedAddContact])
    {
        StartZAUserController * contact = [[StartZAUserController alloc] init];
        [self.navigationController pushViewController:contact animated:YES];
        return;
    }
//    if([total isNeedAddContact])
//    {
//        StartZAContactController * contact = [[StartZAContactController alloc] init];
//        [self.navigationController pushViewController:contact animated:YES];
//        return;
//    }
    
    //回收，相当于登录成功
    UIViewController * vc = self.navigationController;
    if([vc presentingViewController])
    {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }else{
        //替换
        AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDel refreshWindowRootViewController];
    }

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
    UIKeyboardType keyboard = UIKeyboardTypeNumberPad;
    if(rowNum == 0)
    {
        //添加按钮
        CGRect rect = timeBtn.frame;
        rect.origin.x = SCREEN_WIDTH - rect.size.width - FLoatChange(5);//
        rect.origin.y = (FLoatChange(47) - rect.size.height)/2.0;
        
//        rect = [startTableview convertRect:rect fromView:cell];
        timeBtn.frame = rect;
        [cell addSubview:timeBtn];
    }
    
    cell.editTfd.clearButtonMode = (rowNum==0)?UITextFieldViewModeNever:UITextFieldViewModeWhileEditing;

    NSInteger count = [tableView numberOfRowsInSection:0];
    cell.bottomLine.hidden = (rowNum == count-1);
    
    NSString * iconName = @"phoneNum_icon";
    NSString * hold = @"请输入您的手机号码";
    NSString * txt = editModel.mobile;
    switch (rowNum) {
        case 0:
            iconName = @"phoneNum_icon";
            hold = @"请输入您的手机号码";
            txt = editModel.mobile;
            break;
        case 1:
            iconName = @"password_icon";
            hold = @"请输入短信验证码";
            txt = editModel.messageNum;
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
    NSString *inputPhoneNum = [self textFromCellTfdWithIndexNum:0];
    NSString *inputMesNum = [self textFromCellTfdWithIndexNum:1];
    editModel.mobile = inputPhoneNum;
    editModel.messageNum = inputMesNum;
    
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
