//
//  InfoCompleteController.m
//  ZAIOSMainPrj
//
//  Created by zhangchaoqun on 15/5/12.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "InfoCompleteController.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface InfoCompleteController()
{
    UIImageView * loginBg;
    UIView * tfdBgView;
    UIScrollView * bgScrollView;
    
    UILabel * welcomLbl;
    UILabel * noticeLbl;
    UITextField * realNameTfd;
    UITextField * indentifyNumTfd;
    GenderType sexTag;
    UpdateInfoModel * _infoModel;
}
@end
@implementation InfoCompleteController
-(void)viewDidLoad
{
    
    //登录页面的背景
    loginBg = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:loginBg];
    loginBg.image = [UIImage imageNamed:@"login_bg"];
    loginBg.backgroundColor = [DZUtils colorWithHex:@"#68b9fe"];
    loginBg.userInteractionEnabled = YES;
    
    [super viewDidLoad];
    self.titleBar.hidden = YES;
    
    //页面布局为两部分，第一部分展示接收性别
    //第二部分接收剩余信息，通过 scrollview 上下跳转
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:rect];
    [self.view addSubview:scroll];
    scroll.scrollEnabled = NO;
    bgScrollView = scroll;
    
    scroll.contentSize = CGSizeMake(rect.size.width, rect.size.height*2);
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"跳过" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    btn.frame = CGRectMake(SCREEN_WIDTH - 80, 30, 60, 40);
    [scroll addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnNextBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGFloat startY = 90;
    UILabel * txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [scroll addSubview:txtLbl];
    txtLbl.text = @"完善个人资料";
    txtLbl.textColor = [UIColor whiteColor];
    txtLbl.font = [UIFont systemFontOfSize:20];
    [txtLbl sizeToFit];
    txtLbl.center = CGPointMake(SCREEN_WIDTH/2.0, startY + txtLbl.bounds.size.height/2.0);
    
    CGFloat sepY = 30;
    startY += txtLbl.bounds.size.height;
    startY += sepY;
    
    startY += sepY;
    CGFloat xLine = scroll.bounds.size.width/2.0;
    CGFloat sepX = 20;
    CGSize btnSize = CGSizeMake(80, 80);
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scroll addSubview:btn];
    btn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    btn.center = CGPointMake(xLine - sepX - btnSize.width/2.0, startY+btnSize.height/2.0);
    [btn setTitle:@"男" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor whiteColor]];
    btn.layer.cornerRadius = 5.0;
    btn.clipsToBounds = YES;
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [[UIColor clearColor] CGColor];
//    [btn setImage:[UIImage imageNamed:@"QQLogin"] forState:UIControlStateNormal];
//    [btn setImage:[UIImage imageNamed:@"QQLogin"] forState:UIControlStateHighlighted];
    
    btn.tag = 100;
    [btn addTarget:self action:@selector(tapedOnOtherLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 101;
    [btn addTarget:self action:@selector(tapedOnOtherLogin:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:btn];
    btn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    btn.center = CGPointMake(xLine + sepX +btnSize.width/2.0, startY+btnSize.height/2.0);
    [btn setTitle:@"女" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:30]];

    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor whiteColor]];
    btn.layer.cornerRadius = 5.0;
    btn.clipsToBounds = YES;
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [[UIColor clearColor] CGColor];
//    [btn setImage:[UIImage imageNamed:@"weiXin"] forState:UIControlStateNormal];
//    [btn setImage:[UIImage imageNamed:@"weiXin"] forState:UIControlStateHighlighted];

    
    rect.origin.y = rect.size.height;
    UIView * nextView = [[UIView alloc] initWithFrame:rect];
    [scroll addSubview:nextView];
    nextView.backgroundColor = [UIColor clearColor];
    
    TPKeyboardAvoidingScrollView * smallScroll = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:nextView.bounds];
    [nextView addSubview:smallScroll];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(tapOnBack:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor redColor]];
    btn.frame = CGRectMake(0, 0, 60, 40);
    [smallScroll addSubview:btn];
    btn.center = CGPointMake(smallScroll.bounds.size.width/2.0, btn.bounds.size.height/2.0 + 40);
    
    
    startY = 100;
    txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [smallScroll addSubview:txtLbl];
    txtLbl.text = @"先生，您好";
    txtLbl.textColor = [UIColor whiteColor];
    txtLbl.font = [UIFont systemFontOfSize:20];
    [txtLbl sizeToFit];
    txtLbl.center = CGPointMake(SCREEN_WIDTH/2.0, startY + txtLbl.bounds.size.height/2.0);
    welcomLbl = txtLbl;

    
    startY += txtLbl.bounds.size.height;
    startY += 40;
    
    float width  = SCREEN_WIDTH - 40;
    CGFloat eveHeight = 50;
    float height = eveHeight*2;
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(20, startY, width, height)];
    [smallScroll addSubview:bgView];
    bgView.layer.cornerRadius = 3.0;
    bgView.clipsToBounds = YES;
    bgView.layer.borderWidth = 0.5;
    bgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    tfdBgView = bgView;
    
    startY = 0;
    //登录 名/密码
    realNameTfd =  [self logViewWithFrame:CGRectMake(0, startY, width, eveHeight) image:[UIImage imageNamed:@"user"] text:@"您的大名"];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, startY + eveHeight -1, width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:lineView];
    
    startY  += eveHeight;
    indentifyNumTfd =  [self logViewWithFrame:CGRectMake(0, startY, width, eveHeight) image:[UIImage imageNamed:@"user"] text:@"身份证号码"];
    
    
    startY = bgView.frame.origin.y + height + 10;
    CGFloat x_sep = 40 + 18 + 100;
    width = (SCREEN_WIDTH-x_sep);
    height = 44*width/130;
    
    
    //增加异常提示框
    txtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [smallScroll addSubview:txtLbl];
    txtLbl.text = @"第三方账号快速登录";
    txtLbl.font = [UIFont systemFontOfSize:14];
    [txtLbl sizeToFit];
    txtLbl.textColor = TEXT_ERROR_YELLOWCOLOR;
    txtLbl.center = CGPointMake(SCREEN_WIDTH/2.0, startY + txtLbl.bounds.size.height/2.0);
    txtLbl.text = nil;
    noticeLbl = txtLbl;
    
    
    startY += txtLbl.bounds.size.height;
    startY += 10;
    
    //注册按钮
    btn = [self createButton:CGRectMake(x_sep/2.0, startY, width, height) text:@"完成" color:[UIColor whiteColor]  action:@selector(submit)];
    [smallScroll addSubview:btn];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
}

- (UIButton *)createButton:(CGRect)frame text:(NSString *)text color:(UIColor *)cl action:(SEL)action{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = cl;
    [[btn layer]setCornerRadius:5.0];//圆角
    
    [btn setTitle:text forState:UIControlStateNormal];
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
-(void)startInfoCompleteRequest
{
    UpdateInfoModel * model = _infoModel;
    if(!model){
        model = [[UpdateInfoModel alloc] init];
        [model addSignalResponder:self];
        _infoModel = model;
    }
    model.realName = realNameTfd.text;
    model.gender = sexTag;
    model.certificateType = CertificateTypeIDCard;
    model.certificateNo = indentifyNumTfd.text;
    model.birthday = @"1990-01-01";
    [model sendRequest];
}
#pragma mark UpdateInfoModel
handleSignal( UpdateInfoModel, requestLoading )
{
    [self showLoading];
    
}

handleSignal( UpdateInfoModel, requestLoaded )
{
    
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        //信息完善改为1
        Account * account = [[AccountManager sharedInstance] account];
        account.acctInfoComplete = [NSNumber numberWithInt:1];
        [[AccountManager sharedInstance] saveAccount:account];
        
        [DZUtils noticeCustomerWithShowText:@"个人信息完善成功"];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

handleSignal( UpdateInfoModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
-(void)localNoticeText:(NSString *)error
{
    CGPoint pt = noticeLbl.center;
    noticeLbl.text = error;
    [noticeLbl sizeToFit];
    noticeLbl.center = pt;
}

-(void)submit
{
    if(realNameTfd.text.length==0&&indentifyNumTfd.text.length==0){
        [self localNoticeText:@"真实姓名、证件号码均不能为空"];
        return;
    }
    
    //判空
    if (realNameTfd.text.length==0) {
        [self localNoticeText:@"真实姓名不能为空"];
        return;
    }
    if (indentifyNumTfd.text.length==0) {
        [self localNoticeText:@"证件号码不能为空"];
        return;
    }

    
    //格式验证
//    NSString * str = indentifyNumTfd.text;
//    BOOL isMatch = [DZUtils checkTelNumMatchWithTelNum:str];
//    if(!isMatch)
//    {
//        [self localNoticeText:@"证件号码格式错误"];
//        return;
//    }

    [self startInfoCompleteRequest];
}

-(void)tapOnBack:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [bgScrollView scrollRectToVisible:rect animated:YES];

    [self.view endEditing:YES];
}

-(void)tapedOnOtherLogin:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y = rect.size.height;
    
    NSInteger tag = [(UIButton *)sender tag];
    NSString * str = @"先生，您好";
    switch (tag) {
        case 100:
        {
            sexTag = GenderTypeMale;
        }
            break;
        case 101:
        {
            sexTag = GenderTypeFemale;
            str = @"女士，您好";
        }
            break;
        default:
            break;
    }
    
    welcomLbl.text = str;
    [bgScrollView scrollRectToVisible:rect animated:YES];

}

-(void)tapedOnNextBtn:(id)sender
{
    if(self.TapedOnRightBtnBlock){
        self.TapedOnRightBtnBlock();
    }
}




@end
