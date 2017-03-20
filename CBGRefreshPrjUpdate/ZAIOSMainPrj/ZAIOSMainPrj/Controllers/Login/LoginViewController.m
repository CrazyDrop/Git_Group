//
//  LoginViewController.m
//  Photography
//
//  Created by jialifei on 15/3/21.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
//#import "MianTabBarViewController.h"
#import "RegisterInfoViewController.h"
#import "ForgetPasswordViewController.h"
#import "DPHttpClient.h"
#import "UserInfo.h"
#import "FaceAndTopicLabel.h"
#import "PoundTopicModel.h"
#import "QQSpaceShare.h"
#import "WeixinShare.h"
#import "InfoCompleteController.h"
@interface LoginViewController ()
{
    UIImageView *loginBg;
    UIView *bg;//
    UIImageView *appLogo;
    
    UITextField *loginName;
    UITextField *passWord;
    float startY;
    
    UILabel * noticeLbl;
    DPHttpClient *client;
    
}
@property (nonatomic, strong) LoginModel *loginModel;
@end

@implementation LoginViewController


//phone = 13426458214;
//token = 5E91B5D523AA635A285B7B58C9A62B15;
//"user_id" = 1;
//"user_img" = "http://115.159.68.180:8080//sdbt/uploade/photos/20150402225106296.jpg";

handleSignal( LoginModel, requestLoading )
{
    [self showLoading];
    
}
handleSignal( LoginModel, requestLoaded )
{
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        TokenRefreshManager * manager =  [TokenRefreshManager sharedInstance];
        [manager userLoginSuccess];
        
        LoginResponse *resp = signal.object;
        NSString *userId = resp.userId;
        NSString *token = resp.token;
        NSLog(@"login success userId %@ token %@",userId, token);
        
        Account * account = [[AccountManager sharedInstance] account];
        if(account.isInfoCompleted)//信息齐全
        {
            [DZUtils noticeCustomerWithShowText:@"登录成功"];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        //进行信息补全
        __weak LoginViewController * weakSelf = self;
        InfoCompleteController * complete = [[InfoCompleteController alloc] init];
        complete.TapedOnRightBtnBlock = ^(void){
            [weakSelf.navigationController popToRootViewControllerAnimated:NO];//跳过补全信息到首页
        };
        [self.navigationController pushViewController:complete animated:YES];

    }
}
handleSignal( LoginModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
- (void)viewDidLoad {
    self.loginModel = [[LoginModel alloc] init];
    [self.loginModel addSignalResponder:self];
    
    self.showLeftBtn = YES;
    self.viewTtle = ZAViewLocalizedStringForKey(@"ZAViewLocal_Login_Title");
    
    //登录页面的背景
    loginBg = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:loginBg];
    loginBg.image = [UIImage imageNamed:@"login_bg"];
    loginBg.userInteractionEnabled = YES;
    //applogo
    appLogo = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH -124)/2 , 72, 124, 207/2)];
    appLogo.image = [UIImage imageNamed:@"loggo"];
    [loginBg addSubview:appLogo];
    
    [super viewDidLoad];
    self.titleBar.backgroundColor = [UIColor greenColor];
    
    client = [[DPHttpClient alloc] init];
    client.delegate =self;


    //根据ui临时添加
    startY = CGRectGetMaxY(self.titleBar.frame) + 10;
    float width  = SCREEN_WIDTH - 40;
    float height = 120;
    bg = [[UIView alloc] initWithFrame:CGRectMake(20, startY, width, height)];
    [self.view addSubview:bg];
    bg.layer.cornerRadius = 3.0;
    bg.clipsToBounds = YES;
    bg.layer.borderWidth = 0.5;
    bg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    //登录 名/密码
    loginName =  [self logViewWithFrame:CGRectMake(0, 0, width, height/2) image:[UIImage imageNamed:@"user"] text:@"手机号码"];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, height/2, width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [bg addSubview:lineView];
    
    passWord =  [self logViewWithFrame:CGRectMake(0, height/2+1, width, height/2) image:[UIImage imageNamed:@"password"] text:ZAViewLocalizedStringForKey(@"ZAViewLocal_Login_Login_PWD_Text")];
    passWord.secureTextEntry = YES;
    
    startY = bg.frame.origin.y +height +5;
    
    //增加异常提示框
    UILabel * txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [loginBg addSubview:txtLbl];
    txtLbl.text = ZAViewLocalizedStringForKey(@"ZAViewLocal_Login_OtherLogin_Text");
    txtLbl.font = [UIFont systemFontOfSize:12];
    [txtLbl sizeToFit];
    txtLbl.textColor = TEXT_ERROR_YELLOWCOLOR;
    txtLbl.center = CGPointMake(SCREEN_WIDTH/2.0, startY + txtLbl.bounds.size.height/2.0);
    txtLbl.text = nil;
    noticeLbl = txtLbl;
    
    startY += 5;
    startY += txtLbl.bounds.size.height;
    
    CGFloat x_sep = 40 + 18;
    width = (SCREEN_WIDTH-x_sep);
    height = 44*width/260;
    
    [self initButton:CGRectMake(x_sep/2.0, startY, width, height) text:ZAViewLocalizedStringForKey(@"ZAViewLocal_Login_Button_Title") color:[UIColor blueColor]  action:@selector(userlogin)];
//    [self initButton:CGRectMake((SCREEN_WIDTH-40-18)/2+20+18, y, width, height) text:@"注册" color:[DZUtils colorWithHex:@"8697ab"] action:@selector(userRegister)];
   
    startY += height;
    
    txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [loginBg addSubview:txtLbl];
    txtLbl.text = ZAViewLocalizedStringForKey(@"ZAViewLocal_Login_OtherLogin_Text");
    txtLbl.font = [UIFont systemFontOfSize:12];
    [txtLbl sizeToFit];
    txtLbl.center = CGPointMake(SCREEN_WIDTH/2.0, startY + 20 + txtLbl.bounds.size.height/2.0);
    
    startY += txtLbl.bounds.size.height;
    startY += 20;

    startY += 20;
    CGFloat xLine = loginBg.bounds.size.width/2.0;
    CGFloat sepX = 20;
    CGSize btnSize = CGSizeMake(40, 40);
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBg addSubview:btn];
    btn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    btn.center = CGPointMake(xLine + sepX +btnSize.width/2.0, startY+btnSize.height/2.0);
    [btn setImage:[UIImage imageNamed:@"QQLogin"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"QQLogin"] forState:UIControlStateHighlighted];
    btn.tag = 100;
    [btn addTarget:self action:@selector(tapedOnOtherLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 101;
    [btn addTarget:self action:@selector(tapedOnOtherLogin:) forControlEvents:UIControlEventTouchUpInside];
    [loginBg addSubview:btn];
    btn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    btn.center = CGPointMake(xLine - sepX - btnSize.width/2.0, startY+btnSize.height/2.0);
    [btn setImage:[UIImage imageNamed:@"weiXin"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"weiXin"] forState:UIControlStateHighlighted];
    
    [self initForgetBtn];
   
    CGFloat bottom = SCREEN_HEIGHT - 80;
    
    __typeof (self) __weak weakSelf = self;
    FaceAndTopicLabel * bottomTxt = [[FaceAndTopicLabel alloc] initWithFrame:CGRectMake(0, bottom, SCREEN_WIDTH, 80)];
    bottomTxt.font = [UIFont systemFontOfSize:15.0f];
    bottomTxt.lineSpace = 5.0f;
    bottomTxt.textColor = [UIColor darkGrayColor];
    bottomTxt.numberOfLines = 0;
    bottomTxt.tapTopicBlock=^(PoundTopicModel *topicModel) {
        [weakSelf userRegister];
    };
    
    PoundTopicModel * model = [[PoundTopicModel alloc] init];
    model.content = ZAViewLocalizedStringForKey(@"ZAViewLocal_Login_Register_Now_Text");
    [bottomTxt setTopicArray:@[model]];
    NSString * str = [NSString stringWithFormat:@"%@%@",ZAViewLocalizedStringForKey(@"ZAViewLocal_Login_Register_Text"),ZAViewLocalizedStringForKey(@"ZAViewLocal_Login_Register_Now_Text")];
    [bottomTxt setText: str] ;
    [loginBg addSubview:bottomTxt];
    bottomTxt.textAlignment = NSTextAlignmentCenter;
    
    //
    if ([DZUtils userIsLogin])
    {
//        MianTabBarViewController *vc = [[MianTabBarViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:NO];
    }
    
    
//    loginName.text = @"13051850106";
//    passWord.text = @"222222";
    
    [self checkAndHideWeixinLoginWith:100];
    
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

-(void)tapedOnOtherLogin:(id)sender
{
    NSInteger tag = [(UIButton *)sender tag];
    switch (tag) {
        case 100:
        {
            [KMStatis staticLoginEvent:StaticLoginEventType_QQLogin];
            [[QQSpaceShare shareQQSpace] login];
        }
            break;
        case 101:
        {
            [KMStatis staticLoginEvent:StaticLoginEventType_WXLogin];
            [[WeixinShare shareWeixin] login];
        }
            break;
        default:
            break;
    }
}

-(void)forgetAction
{
    [KMStatis staticLoginEvent:StaticLoginEventType_Forget];
    ForgetPasswordViewController *vc = [ForgetPasswordViewController sharedInstance];
    [self.navigationController pushViewController:vc animated:YES];
//    loginName.text= @"";
//    passWord.text = @"";
}

- (void)initForgetBtn
{
    CGFloat btnHeight = 30;
    CGFloat sepY = (passWord.bounds.size.height - btnHeight)/2.0;
    UIButton *forget = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rect = CGRectMake(passWord.bounds.size.width - 110, sepY, 100, btnHeight);
    rect = [bg convertRect:rect fromView:passWord];
    forget.frame = rect;
    [bg addSubview:forget];
    
    [forget addTarget:self action:@selector(forgetAction) forControlEvents:UIControlEventTouchUpInside];
    [forget setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [forget setBackgroundColor:[UIColor whiteColor]];
    [forget setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_Login_Forget_PWD_Text") forState:UIControlStateNormal];
    [forget.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    forget.layer.cornerRadius = 5.0;
    forget.clipsToBounds = YES;
    forget.layer.borderWidth = 0.5;
    forget.layer.borderColor = [[UIColor grayColor] CGColor];
//    UIImage *icon = [UIImage imageNamed:@"forget"];
//    [forget setImage:icon forState:UIControlStateNormal];
//    [forget setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 30)];
//    [forget setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 10)];
}

- (void)initButton:(CGRect)frame text:(NSString *)text color:(UIColor *)cl action:(SEL)action{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = cl;
    [[btn layer]setCornerRadius:5.0];//圆角

    [btn setTitle:text forState:UIControlStateNormal];
    [loginBg  addSubview:btn];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

-(UITextField *)logViewWithFrame:(CGRect)frame  image:(UIImage *)img text:(NSString *)text
{
    UIImageView *userName = [[UIImageView alloc] initWithFrame:frame];
    [bg addSubview:userName];
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
-(void)localNoticeText:(NSString *)error
{
    CGPoint pt = noticeLbl.center;
    noticeLbl.text = error;
    [noticeLbl sizeToFit];
    noticeLbl.center = pt;
}
- (void)userlogin
{
    [KMStatis staticLoginEvent:StaticLoginEventType_Login];
    
    if(loginName.text.length==0&&passWord.text.length==0){
        [self localNoticeText:@"手机号码与登录密码不能为空"];
        return;
    }
    
    if (loginName.text.length==0) {
        [self localNoticeText:@"用户名不能为空"];
        return;
    }
    if (passWord.text.length==0) {
        [self localNoticeText:@"密码不能为空"];
        return;
    }
    NSString * str = loginName.text;
    BOOL isMatch = [DZUtils checkTelNumMatchWithTelNum:str];
    if(!isMatch)
    {
        [self localNoticeText:@"手机号码格式错误"];
        return;
    }
    
    self.loginModel.phoneNo = loginName.text;
    self.loginModel.password = passWord.text;
    [self.loginModel sendRequest];
    
    return;
    
    NSString * url= [NSString stringWithFormat:@"%@/sdbt/mobileLogin",URL_HEAD];
    
    //[self loadData:url];
   // [client getData:url finish:@selector(loginFinish:) fail:@selector(loginFail:)];
    NSString *name = loginName.text;//
    NSString *password = passWord.text;

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:name forKey:@"phoneno"];
    [dic setValue:password forKey:@"user_password"];
    [client postData:url params:dic file:nil finish:@selector(loginFinish:) fail:@selector(loginFail:) andCancel:nil];
}

-(void)loginFinish:(NSDictionary *)data
{
    NSDictionary *dic = data[@"data"];
    [UserInfo sharedUser].userId = dic[@"user_id"];
    [UserInfo sharedUser].userToken = dic[@"token"];
    [UserInfo sharedUser].username = dic[@"username"];
    [UserInfo sharedUser].phone = dic[@"phone"];
    [UserInfo sharedUser].useImg = dic[@"user_img"];


    [DZUtils saveUserInfnfo:dic];
    
    loginName.text = @"";
    passWord.text = @"";
//    MianTabBarViewController *vc = [[MianTabBarViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

-(void)loginFail:(NSDictionary *)data
{
    if ([DZUtils isValidateDictionary:data]) {
        [DZUtils noticeCustomerWithShowText:data[@"info"]];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [loginName resignFirstResponder];
    [passWord resignFirstResponder];
}

- (void)userRegister
{
    [KMStatis staticLoginEvent:StaticLoginEventType_Register];
    RegisterViewController *reg = [RegisterViewController sharedInstance];
    [self.navigationController pushViewController:reg animated:YES];
}

- (void)leftAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end