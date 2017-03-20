//
//  RegisterViewController.m
//  Photography
//
//  Created by jialifei on 15/3/21.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "RegisterViewController.h"
#import "IdentifyViewController.h"
#import "AboutViewController.h"
#import "FaceAndTopicLabel.h"
#import "PoundTopicModel.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "QQSpaceShare.h"
#import "WXApi.h"
#import "WeixinShare.h"
#import "JKCountDownButton.h"
#import "InfoCompleteController.h"
@implementation SelectedBtn

@end

@interface RegisterViewController ()
{
    SelectedBtn *checkBox;
    UITextField  *number;
    float endY;
    DPHttpClient *client;
    UIImageView * bgImgView;
    UIView * tfdBgView;
    
    UILabel * noticeLbl;
    UIScrollView * scrollView;

}
@end

@implementation RegisterViewController

- (id)init{
    self = [super init];
    if (self) {
        
        self.viewTtle =ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Title");
        self.showRightBtn = NO;
        self.showLeftBtn = YES;
        self.rightTitle = @"发送";
    }
    return self;
}
+ (id)sharedInstance
{
    static RegisterViewController *sharedRegisterViewControllerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedRegisterViewControllerInstance = [[self alloc] init];
    });
    return sharedRegisterViewControllerInstance;
    return nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    number.keyboardType =UIKeyboardTypePhonePad;
}

- (void)viewDidLoad
{
    bgImgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:bgImgView];
    bgImgView.image = [UIImage imageNamed:@"login_bg"];
    bgImgView.userInteractionEnabled = YES;

    
    [super viewDidLoad];
//    self.view.backgroundColor = VIEW_GAYCOLOR;
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:bgImgView.bounds];
    [bgImgView addSubview:scrollView];
    
    
    CGFloat startY = 80;
    float width  = SCREEN_WIDTH - 40;
    CGFloat eveHeight = 50;
    float height = eveHeight*4;
    tfdBgView = [[UIView alloc] initWithFrame:CGRectMake(20, startY, width, height)];
    [scrollView addSubview:tfdBgView];
    tfdBgView.layer.cornerRadius = 3.0;
    tfdBgView.clipsToBounds = YES;
    tfdBgView.layer.borderWidth = 0.5;
    tfdBgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.myClient.delegate = self;
    startY = 0;
    //登录 名/密码
    phoneNumTfd =  [self logViewWithFrame:CGRectMake(0, startY, width, eveHeight) image:[UIImage imageNamed:@"user"] text:ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Phone_Num_Text")];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, startY + eveHeight -1, width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [tfdBgView addSubview:lineView];
    [self initGetMessageBtn];
    
    startY  += eveHeight;
    messageNumTfd =  [self logViewWithFrame:CGRectMake(0, startY, width, eveHeight) image:[UIImage imageNamed:@"user"] text:ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Message_Text")];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, startY + eveHeight - 1 , width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [tfdBgView addSubview:lineView];

    startY  += eveHeight;
    passwordTfd =  [self logViewWithFrame:CGRectMake(0, startY, width, eveHeight) image:[UIImage imageNamed:@"password"] text:ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Login_PWD_Text")];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, startY + eveHeight - 1 , width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [tfdBgView addSubview:lineView];
    passwordTfd.secureTextEntry = YES;
    
    startY  += eveHeight;
    password2Tfd =  [self logViewWithFrame:CGRectMake(0, startY, width, eveHeight) image:[UIImage imageNamed:@"password"] text:ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Confirm_PWD_Text")];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, startY + eveHeight - 1 , width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [tfdBgView addSubview:lineView];
    password2Tfd.secureTextEntry = YES;
    
    CGFloat sepY = 10;
    startY = tfdBgView.frame.origin.y +height + sepY/2.0;
    
    //增加异常提示框
    UILabel * txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [scrollView addSubview:txtLbl];
    txtLbl.text = ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_OtherLogin_Text");
    txtLbl.font = [UIFont systemFontOfSize:12];
    [txtLbl sizeToFit];
    txtLbl.textColor = TEXT_ERROR_YELLOWCOLOR;
    txtLbl.center = CGPointMake(SCREEN_WIDTH/2.0, startY + txtLbl.bounds.size.height/2.0);
    txtLbl.text = nil;
    noticeLbl = txtLbl;
    
    startY += sepY/2.0;
    startY += txtLbl.bounds.size.height;
    
    CGFloat x_sep = 40 + 18;
    width = (SCREEN_WIDTH-x_sep);
    height = 44*width/260;
    
    //注册按钮
    finishBtn = [self createButton:CGRectMake(x_sep/2.0, startY, width, height) text:ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Button_Title") color:[UIColor blueColor]  action:@selector(submit)];

    //说明文本
    startY += height;
    startY += sepY;
    
    __typeof (self) __weak weakSelf = self;
    FaceAndTopicLabel * bottomTxt = [[FaceAndTopicLabel alloc] initWithFrame:CGRectMake(0, startY, SCREEN_WIDTH, 80)];
    bottomTxt.font = [UIFont systemFontOfSize:15.0f];
    bottomTxt.lineSpace = 5.0f;
    bottomTxt.textColor = [UIColor darkGrayColor];
    bottomTxt.numberOfLines = 0;
    bottomTxt.tapTopicBlock=^(PoundTopicModel *topicModel) {
        [weakSelf showAgreement];
    };
    
    PoundTopicModel * model = [[PoundTopicModel alloc] init];
    model.content = ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Service_Text");
    [bottomTxt setTopicArray:@[model]];
    NSString * str = [NSString stringWithFormat:@"%@%@",ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Notice_Text"),ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Service_Text")];
    [bottomTxt setText: str] ;
    [scrollView addSubview:bottomTxt];
    bottomTxt.textAlignment = NSTextAlignmentCenter;
    [bottomTxt sizeToFit];
    bottomTxt.center = CGPointMake(SCREEN_WIDTH/2.0, startY + bottomTxt.bounds.size.height/2.0);
    
    startY += bottomTxt.bounds.size.height;
    startY += sepY;
    
    txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [scrollView addSubview:txtLbl];
    txtLbl.text = ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_OtherLogin_Text");
    txtLbl.font = [UIFont systemFontOfSize:12];
    [txtLbl sizeToFit];
    txtLbl.center = CGPointMake(SCREEN_WIDTH/2.0, startY + txtLbl.bounds.size.height/2.0);
    
    startY += txtLbl.bounds.size.height;
    startY += sepY;
    
    startY += sepY;
    CGFloat xLine = scrollView.bounds.size.width/2.0;
    CGFloat sepX = 20;
    CGSize btnSize = CGSizeMake(40, 40);
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scrollView addSubview:btn];
    btn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    btn.center = CGPointMake(xLine + sepX +btnSize.width/2.0, startY+btnSize.height/2.0);
    [btn setImage:[UIImage imageNamed:@"QQLogin"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"QQLogin"] forState:UIControlStateHighlighted];
    btn.tag = 100;
    [btn addTarget:self action:@selector(tapedOnOtherLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 101;
    [btn addTarget:self action:@selector(tapedOnOtherLogin:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btn];
    btn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    btn.center = CGPointMake(xLine - sepX - btnSize.width/2.0, startY+btnSize.height/2.0);
    [btn setImage:[UIImage imageNamed:@"weiXin"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"weiXin"] forState:UIControlStateHighlighted];
    
    
    [self checkAndHideWeixinLoginWith:100];

//    phoneNumTfd.text = @"13051850106";
//    passwordTfd.text = @"222222";
//    password2Tfd.text = @"222222";
//    messageNumTfd.text = @"2222";
    
    
}
-(void)checkAndHideWeixinLoginWith:(NSInteger)tag
{
    UIView * QQbtn = [self.view viewWithTag:tag];
    UIView * weiInBtn = [self.view viewWithTag:tag+1];
    
    weiInBtn.hidden = NO;
    //查看是否可以打开微信
    if([WeixinShare AppInstalledAndSupported]) return;
    
    weiInBtn.hidden = YES;
    
    
    CGPoint pt = QQbtn.center;
    pt.x += weiInBtn.center.x;
    pt.y += weiInBtn.center.y;
    CGPoint center = CGPointMake(pt.x/2.0,pt.y/2.0);
    QQbtn.center = center;
}
-(void)localNoticeText:(NSString *)error
{
    CGPoint pt = noticeLbl.center;
    noticeLbl.text = error;
    [noticeLbl sizeToFit];
    noticeLbl.center = pt;
}
-(void)tapedOnOtherLogin:(id)sender
{
    NSInteger tag = [(UIButton *)sender tag];
    switch (tag) {
        case 100:
        {
            [KMStatis staticRegisterEvent:StaticRegisterEventType_QQLogin];
            [[QQSpaceShare shareQQSpace] login];
        }
            break;
        case 101:
        {
            [KMStatis staticRegisterEvent:StaticRegisterEventType_WXLogin];
            [[WeixinShare shareWeixin] login];
        }
            break;
        default:
            break;
    }
}
-(BOOL)getCheckNumCheck:(id)sender
{
    [KMStatis staticForgetEvent:StaticForgetEventType_Message];
    //判空
    if (phoneNumTfd.text.length==0) {
        [self localNoticeText:@"手机号码不能为空"];
        return NO;
    }
    
    //格式校验
    NSString * str = phoneNumTfd.text;
    BOOL isMatch = [DZUtils checkTelNumMatchWithTelNum:str];
    if(!isMatch){
        [self localNoticeText:@"手机格式不正确"];
        return NO;
    }

    return YES;
}
-(void)startGetMessageRequest
{
    CheckNumModel * model = _checkNumModel;
    if(!model)
    {
        model = [[CheckNumModel alloc] init];
        [model addSignalResponder:self];
        _checkNumModel = model;
    }
    model.phoneNo = phoneNumTfd.text;
    model.checkType = CaptchaTypeRegister;
    [model sendRequest];
    
}
-(void)startRegisterRequest
{
    RegisterModel * model = _register;
    if(!model)
    {
        model = [[RegisterModel alloc] init];
        [model addSignalResponder:self];
        _register = model;
    }
    model.phoneNo = phoneNumTfd.text;
    model.password = passwordTfd.text;
    model.checkNum = messageNumTfd.text;
    [model sendRequest];
    
}
- (void)initGetMessageBtn
{
    
    CGFloat btnHeight = 30;
    CGFloat sepY = (phoneNumTfd.bounds.size.height - btnHeight)/2.0;
    UIButton *messageBtn = [JKCountDownButton buttonWithType:UIButtonTypeCustom];
    CGRect rect = CGRectMake(phoneNumTfd.bounds.size.width - 110, sepY, 100, btnHeight);
    rect = [scrollView convertRect:rect fromView:phoneNumTfd];
    messageBtn.frame = rect;
    _timerBtn =(JKCountDownButton *) messageBtn;
    
    rect = phoneNumTfd.frame;
    rect.size.width -= messageBtn.bounds.size.width;
    phoneNumTfd.frame = rect;
    
    [scrollView addSubview:messageBtn];
    //    [messageBtn addTarget:self action:@selector(getCheckNum:) forControlEvents:UIControlEventTouchUpInside];
    [messageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [messageBtn setBackgroundColor:[UIColor redColor]];
    [messageBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Message_Button_Text") forState:UIControlStateNormal];
    [messageBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    messageBtn.layer.cornerRadius = 5.0;
    messageBtn.clipsToBounds = YES;
    messageBtn.layer.borderWidth = 0.5;
    messageBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    
    
    __weak RegisterViewController * weakSelf = self;
    [(JKCountDownButton *)messageBtn addToucheHandler:^(JKCountDownButton*sender, NSInteger tag) {
        
        BOOL result = [weakSelf getCheckNumCheck:nil];
        if(!result) return ;
        [weakSelf startGetMessageRequest];
        sender.enabled = NO;
        [sender startWithSecond:60];
        
        
        [sender didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
            NSString *title = [NSString stringWithFormat:ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Message_Num_Text"),second];
            return title;
        }];
        [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
            countDownButton.enabled = YES;
            return ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Message_Button_Text");
        }];
        
    }];
}

-(void)showAgreement
{
    [KMStatis staticRegisterEvent:StaticRegisterEventType_Service];
    AboutViewController *vc = [[AboutViewController alloc] init];
    vc.viewTtle = ZAViewLocalizedStringForKey(@"ZAViewLocal_Register_Service_Text");
    vc.url = [NSString stringWithFormat:@"%@/sdbt/userAgreement.html",URL_HEAD];
    [self.navigationController pushViewController:vc animated:YES];

}

-(void)iDo:(SelectedBtn *)sender
{
    sender.isAgreed = sender.isAgreed ? NO :YES;
    [sender setBackgroundImage:[UIImage imageNamed: sender.isAgreed ? @"reg_selected":@"reg_select"] forState:UIControlStateNormal];
}
- (UIButton *)createButton:(CGRect)frame text:(NSString *)text color:(UIColor *)cl action:(SEL)action{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = cl;
    [[btn layer]setCornerRadius:5.0];//圆角
    
    [btn setTitle:text forState:UIControlStateNormal];
    [scrollView  addSubview:btn];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(UITextField *)logViewWithFrame:(CGRect)frame  image:(UIImage *)img text:(NSString *)text
{
    UIImageView *userName = [[UIImageView alloc] initWithFrame:frame];
    [tfdBgView addSubview:userName];
    userName.userInteractionEnabled = YES;
    userName.alpha = 0.7;
    userName.backgroundColor = [UIColor whiteColor];//[DZUtils colorWithHex:@"ffffff"];
    
    UIImageView  *head = [[UIImageView alloc] initWithFrame:CGRectMake(10, (frame.size.height-30)/2, 30,30)];
    head.image = img;
    [userName addSubview:head];
    
    UITextField  *name = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, frame.size.width - 60, frame.size.height)];
    [userName addSubview:name];
    name.alpha = 0.7;
    name.placeholder=text;//默认显示的
    name.backgroundColor = [UIColor whiteColor] ;
    
    return name;
}


-(void)initPhoneNumber{
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, NAVBAR_HEIGHT+18, FLoatChange(300) ,YFLoatChange(40) )];
    bg.backgroundColor = [UIColor whiteColor];
    [bg.layer setCornerRadius:5.0];//圆角
    bg.userInteractionEnabled =YES;
    [self.view addSubview:bg];
    endY = bg.frame.origin.y;
    
    number = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, FLoatChange(280) ,YFLoatChange(30))];
    [bg addSubview:number];
    number.backgroundColor = [UIColor whiteColor];
    number.placeholder=@"请输入手机号码";//默认显示的
    [number becomeFirstResponder];
}

- (void)submit
{
    [KMStatis staticRegisterEvent:StaticRegisterEventType_Register];
    if(phoneNumTfd.text.length==0&&messageNumTfd.text.length==0&&passwordTfd.text.length==0){
        [self localNoticeText:@"手机号码、短信验证码、密码均不能为空"];
        return;
    }

    //判空
    if (phoneNumTfd.text.length==0) {
        [self localNoticeText:@"手机号码不能为空"];
        return;
    }
    if (messageNumTfd.text.length==0) {
        [self localNoticeText:@"短信验证码不能为空"];
        return;
    }
    if (passwordTfd.text.length==0) {
        [self localNoticeText:@"密码不能为空"];
        return;
    }
    if (password2Tfd.text.length==0) {
        [self localNoticeText:@"密码不能为空"];
        return;
    }
    
    //格式验证
    NSString * str = phoneNumTfd.text;
    BOOL isMatch = [DZUtils checkTelNumMatchWithTelNum:str];
    if(!isMatch)
    {
        [self localNoticeText:@"手机号码格式错误"];
        return;
    }
    
    str = passwordTfd.text;
    if([str length]<5||[str length]>21){
        [self localNoticeText:@"请输入有效的密码格式"];
        return;
    }
    
    if(![passwordTfd.text isEqualToString:password2Tfd.text])
    {
        [self localNoticeText:@"两次密码不一致"];
        return;
    }
    
    
    
    [self startRegisterRequest];
    
//    NSString *req  = [NSString stringWithFormat:@"%@sdbt/user_getValidateCode?phoneno=%@",URL_HEAD,number.text];
//    [self.myClient getData:req finish:@selector(requestFinish:) fail:@selector(requestFail:)];
}

-(void)requestFinish:(NSDictionary *)data
{
    IdentifyViewController *vc = [[IdentifyViewController alloc] initWithType:@"reg"];
    vc.phoneNumber = number.text;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)requestFail:(NSDictionary *)data
{
    if ([DZUtils isValidateDictionary:data]) {
        [DZUtils noticeCustomerWithShowText:data[@"info"]];
    }
}
#pragma mark CheckNumModel
handleSignal( CheckNumModel, requestLoading )
{
    [self showLoading];
    
}

handleSignal( CheckNumModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [DZUtils noticeCustomerWithShowText:@"短信验证码已发送"];
    }
}

handleSignal( CheckNumModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
    [_timerBtn stop];
}
#pragma mark RegisterModel
handleSignal( RegisterModel, requestLoading )
{
    [self showLoading];
    
}

handleSignal( RegisterModel, requestLoaded )
{
    
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [DZUtils noticeCustomerWithShowText:@"注册成功"];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

handleSignal( RegisterModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
