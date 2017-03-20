//
//  ForgetPasswordViewController.m
//  Photography
//
//  Created by jialifei on 15/4/12.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "IdentifyViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "JKCountDownButton.h"
@interface ForgetPasswordViewController ()
{
    UIImageView * bgImgView;
    UIView * tfdBgView;
    
    UILabel * noticeLbl;
    UIScrollView * scrollView;
    UITextField * phoneNumTfd;
    UITextField * messageNumTfd;
    UITextField * passwordTfd;
    UITextField * password2Tfd;
    JKCountDownButton * _timerBtn;

    CheckNumModel * _checkNumModel;
    ResetPwdModel * _resetModel;
}
@end

@implementation ForgetPasswordViewController


- (id)init{
    self = [super init];
    if (self) {
        self.viewTtle =ZAViewLocalizedStringForKey(@"ZAViewLocal_ResetPWD_Title");
        self.showRightBtn = NO;
        self.showLeftBtn = YES;
        self.rightTitle = @"发送";
    }
    return self;
}

+ (id)sharedInstance
{
    static ForgetPasswordViewController *sharedForgetViewControllerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedForgetViewControllerInstance = [[self alloc] init];
    });
    return sharedForgetViewControllerInstance;
    return nil;
}



//@"http://115.159.68.180:8080/sdbt/getIdentifyingCode?phoneno=18500053825";
-(void)submit
{
    [KMStatis staticForgetEvent:StaticForgetEventType_Finish];
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
    
    [self startForgetPWDRequest];
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
    model.checkType = CaptchaTypeResetPwd;
    [model sendRequest];
    
}
-(void)startForgetPWDRequest
{
    ResetPwdModel * model = _resetModel;
    if(!model)
    {
        model = [[ResetPwdModel alloc] init];
        [model addSignalResponder:self];
        _resetModel = model;
    }
    model.phoneNo = phoneNumTfd.text;
    model.theNewPassword = passwordTfd.text;
    model.checkNum = messageNumTfd.text;
    [model sendRequest];
    
}


-(void)getCodeFinish:(NSDictionary *)data
{
    IdentifyViewController *vc = [[IdentifyViewController alloc] initWithType:@"for"];
    vc.phoneNumber = _phoneNumber.text;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)getCodeFail:(NSDictionary *)data
{
    [DZUtils noticeCustomerWithShowText:data[@"info"]];
}

-(void)phoneIdentifity
{
    IdentifyViewController *vc = [[IdentifyViewController alloc] init];
    vc.phoneNumber = _phoneNumber.text;
    [self.navigationController pushViewController:vc animated:YES];
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
    phoneNumTfd =  [self logViewWithFrame:CGRectMake(0, startY, width, eveHeight) image:[UIImage imageNamed:@"user"] text:ZAViewLocalizedStringForKey(@"ZAViewLocal_ResetPWD_Title")];
    phoneNumTfd.font = [UIFont systemFontOfSize:12];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, startY + eveHeight -1, width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [tfdBgView addSubview:lineView];
    [self initGetMessageBtn];
    
    startY  += eveHeight;
    messageNumTfd =  [self logViewWithFrame:CGRectMake(0, startY, width, eveHeight) image:[UIImage imageNamed:@"user"] text:ZAViewLocalizedStringForKey(@"ZAViewLocal_ResetPWD_Message_Text")];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, startY + eveHeight - 1 , width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [tfdBgView addSubview:lineView];
    
    startY  += eveHeight;
    passwordTfd =  [self logViewWithFrame:CGRectMake(0, startY, width, eveHeight) image:[UIImage imageNamed:@"password"] text:ZAViewLocalizedStringForKey(@"ZAViewLocal_ResetPWD_Login_PWD_Text")];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, startY + eveHeight - 1 , width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [tfdBgView addSubview:lineView];
    passwordTfd.secureTextEntry = YES;
    
    startY  += eveHeight;
    password2Tfd =  [self logViewWithFrame:CGRectMake(0, startY, width, eveHeight) image:[UIImage imageNamed:@"password"] text:ZAViewLocalizedStringForKey(@"ZAViewLocal_ResetPWD_Confirm_PWD_Text")];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, startY + eveHeight - 1 , width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [tfdBgView addSubview:lineView];
    password2Tfd.secureTextEntry = YES;
    
    CGFloat sepY = 10;
    startY = tfdBgView.frame.origin.y +height + sepY/2.0;
    
    //增加异常提示框
    UILabel * txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [scrollView addSubview:txtLbl];
    txtLbl.text = @"第三方账号快速登录";
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
    [self initButton:CGRectMake(x_sep/2.0, startY, width, height) text:ZAViewLocalizedStringForKey(@"ZAViewLocal_ResetPWD_Button_Title") color:[UIColor blueColor]  action:@selector(submit)];
    
//    phoneNumTfd.text = @"13051850106";
//    passwordTfd.text = @"333333";
//    password2Tfd.text = @"333333";
//    messageNumTfd.text = @"2222";

}
-(void)localNoticeText:(NSString *)error
{
    CGPoint pt = noticeLbl.center;
    noticeLbl.text = error;
    [noticeLbl sizeToFit];
    noticeLbl.center = pt;
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

- (void)initGetMessageBtn
{
    
    CGFloat btnHeight = 30;
    CGFloat sepY = (phoneNumTfd.bounds.size.height - btnHeight)/2.0;
    UIButton *messageBtn = [JKCountDownButton buttonWithType:UIButtonTypeCustom];
    CGRect rect = CGRectMake(phoneNumTfd.bounds.size.width - 110, sepY, 100, btnHeight);
    rect = [scrollView convertRect:rect fromView:phoneNumTfd];
    messageBtn.frame = rect;
    _timerBtn = (JKCountDownButton *)messageBtn;
    
    rect = phoneNumTfd.frame;
    rect.size.width -= messageBtn.bounds.size.width;
    phoneNumTfd.frame = rect;
    
    [scrollView addSubview:messageBtn];
//    [messageBtn addTarget:self action:@selector(getCheckNum:) forControlEvents:UIControlEventTouchUpInside];
    [messageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [messageBtn setBackgroundColor:[UIColor redColor]];
    [messageBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_ResetPWD_Message_Button_Text") forState:UIControlStateNormal];
    [messageBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    messageBtn.layer.cornerRadius = 5.0;
    messageBtn.clipsToBounds = YES;
    messageBtn.layer.borderWidth = 0.5;
    messageBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    
    
    __weak ForgetPasswordViewController * weakSelf = self;
    [(JKCountDownButton *)messageBtn addToucheHandler:^(JKCountDownButton*sender, NSInteger tag) {
        
        BOOL result = [weakSelf getCheckNumCheck:nil];
        if(!result) return ;
        [weakSelf startGetMessageRequest];
        
        sender.enabled = NO;
        [sender startWithSecond:60];
        [sender didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
            NSString *title = [NSString stringWithFormat:ZAViewLocalizedStringForKey(@"ZAViewLocal_ResetPWD_Message_Num_Text"),second];
            return title;
        }];
        [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
            countDownButton.enabled = YES;
            return ZAViewLocalizedStringForKey(@"ZAViewLocal_ResetPWD_Message_Button_Text");
        }];
    }];
}
- (void)initButton:(CGRect)frame text:(NSString *)text color:(UIColor *)cl action:(SEL)action{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = cl;
    [[btn layer]setCornerRadius:5.0];//圆角
    
    [btn setTitle:text forState:UIControlStateNormal];
    [scrollView  addSubview:btn];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
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
#pragma mark ResetPwdModel
handleSignal( ResetPwdModel, requestLoading )
{
    [self showLoading];
    
}

handleSignal( ResetPwdModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [DZUtils noticeCustomerWithShowText:@"账号密码重置成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

handleSignal( ResetPwdModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
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
