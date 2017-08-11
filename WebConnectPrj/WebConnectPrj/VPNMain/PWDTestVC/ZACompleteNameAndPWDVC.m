//
//  ZACompleteNameAndPWDVC.m
//  ZAIOSMainPrj
//
//  Created by 刘建 on 2017/8/9.
//  Copyright © 2017年 ZhongAn Insurance. All rights reserved.
//

#import "ZACompleteNameAndPWDVC.h"
#import "ZALineInputPasswordView.h"
@interface ZACompleteNameAndPWDVC ()<UIScrollViewDelegate,UITextFieldDelegate>
{
    UIImageView * showSexImg;
    UITextField * nameTfd;
    UIScrollView * bgScrollView;
    
    UILabel * pwdTipsLbl;
    UITextField * hidePwdTfd;
}
@property (nonatomic, strong) UIButton * boyBtn;
@property (nonatomic, strong) UIButton * girlBtn;
@property (nonatomic, strong) ZALineInputPasswordView * passwordView;
@property (nonatomic, copy) NSString * prePwd;
@property (nonatomic, copy) NSString * finishPwd;
@property (nonatomic, strong) NSString * editPwd;

@property (nonatomic, assign) BOOL inWaiting;
@end

@implementation ZACompleteNameAndPWDVC

- (void)viewDidLoad {
    
    NSArray * arr = self.navigationController.viewControllers;
    self.showLeftBtn =  [arr count]!=1;
    
    [super viewDidLoad];
    
    [self showSpecialStyleTitle];
    self.titleBar.hidden = YES;
    
    UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:scroll];
    scroll.contentSize = CGSizeMake(SCREEN_WIDTH, 3 * SCREEN_HEIGHT);
    scroll.showsVerticalScrollIndicator = NO;
    scroll.pagingEnabled = YES;
    scroll.delegate = self;
    bgScrollView = scroll;
    
    //性别
    UIView * sexBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [scroll addSubview:sexBgView];
    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(tapedOnBgviewForHideKeyboard:)];
    [sexBgView addGestureRecognizer:backTap];
    
    
    UIColor * txtColor = ZAColorFromRGB(0x666666);
    UILabel * lbl = [[UILabel alloc] init];
    [sexBgView addSubview:lbl];
    lbl.text = @"关于性别";
    lbl.font = [UIFont systemFontOfSize:FLoatChangeBaseIphone6(18)];
    [lbl sizeToFit];
    lbl.textColor = txtColor;
    lbl.center = CGPointMake(SCREEN_WIDTH/2, FLoatChangeBaseIphone6(83));
    
    
    lbl = [[UILabel alloc] init];
    [sexBgView addSubview:lbl];
    lbl.text = @"相信你会选出正确的答案";
    lbl.font = [UIFont systemFontOfSize:FLoatChangeBaseIphone6(15)];
    [lbl sizeToFit];
    lbl.textColor = txtColor;
    lbl.center = CGPointMake(SCREEN_WIDTH/2, FLoatChangeBaseIphone6(118));
    
    
    //    UIImage * img = [UIImage imageNamed:@"img_photo_gril_new"];
    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, FLoatChangeBaseIphone6(108), FLoatChangeBaseIphone6(120))];
    [sexBgView addSubview:icon];
    icon.backgroundColor = [UIColor clearColor];
    icon.center = CGPointMake(SCREEN_WIDTH/2, FLoatChangeBaseIphone6(236));
    showSexImg = icon;
    
    CGFloat centerX = FLoatChangeBaseIphone6(120);
    CGFloat centerY = FLoatChangeBaseIphone6(360);
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sexBgView addSubview:btn];
    self.boyBtn = btn;
    [btn setImage:[UIImage imageNamed:@"icon_male_unclicked"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"icon_male_clicked"] forState:UIControlStateSelected];
    [btn sizeToFit];
    btn.center = CGPointMake(centerX, centerY);
    [btn addTarget:self action:@selector(tapOnBoyButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sexBgView addSubview:btn];
    self.girlBtn = btn;
    [btn setImage:[UIImage imageNamed:@"icon_female_unclicked"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"icon_female_clicked"] forState:UIControlStateSelected];
    [btn sizeToFit];
    btn.center = CGPointMake(SCREEN_WIDTH - centerX, centerY);
    [btn addTarget:self action:@selector(tapOnGirlButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UIImageView * upImgView = nil;
    upImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scroll_up"]];
    [sexBgView addSubview:upImgView];
    upImgView.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - FLoatChangeBaseIphone6(65));
    
    [self tapOnGirlButton:nil];
    
    //密码
    UIView * pwdBgView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [scroll addSubview:pwdBgView];
    backTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(tapedOnBgviewForHideKeyboard:)];
    [pwdBgView addGestureRecognizer:backTap];
    
    
    lbl = [[UILabel alloc] init];
    [pwdBgView addSubview:lbl];
    lbl.text = @"牢记安全密码";
    lbl.font = [UIFont systemFontOfSize:FLoatChangeBaseIphone6(18)];
    [lbl sizeToFit];
    lbl.textColor = txtColor;
    lbl.center = CGPointMake(SCREEN_WIDTH/2, FLoatChangeBaseIphone6(83));
    
    
    lbl = [[UILabel alloc] init];
    [pwdBgView addSubview:lbl];
    lbl.text = @"解除防护时大有用处";
    lbl.font = [UIFont systemFontOfSize:FLoatChangeBaseIphone6(15)];
    [lbl sizeToFit];
    lbl.textColor = txtColor;
    lbl.center = CGPointMake(SCREEN_WIDTH/2, FLoatChangeBaseIphone6(118));
    pwdTipsLbl = lbl;
    
    UIView * pwd = self.passwordView;
    [pwdBgView addSubview:pwd];
    pwd.center = CGPointMake(SCREEN_WIDTH/2.0, FLoatChangeBaseIphone6(294));
    
    UITextField * pwdTfd = [[UITextField alloc] initWithFrame:pwd.bounds];
    [pwdBgView insertSubview:pwdTfd belowSubview:pwd];
    pwdTfd.keyboardType = UIKeyboardTypeNumberPad;
    pwdTfd.delegate = self;
    pwdTfd.hidden = YES;
    hidePwdTfd = pwdTfd;
    
    CGFloat aViewHeight = FLoatChangeBaseIphone6(30);
    UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, aViewHeight)];
    [pwdBgView addSubview:aView];
    aView.backgroundColor = ZAColorFromRGB(0xf4f4f4);
    aView.center = CGPointMake(SCREEN_WIDTH/2, FLoatChangeBaseIphone6(348));
    
    lbl = [[UILabel alloc] init];
    [aView addSubview:lbl];
    lbl.text = @"默认使用注册手机号码后四位";
    lbl.font = [UIFont systemFontOfSize:FLoatChangeBaseIphone6(12)];
    [lbl sizeToFit];
    lbl.textColor = ZAColorFromRGB(0xb5b5b5);
    lbl.center = CGPointMake(SCREEN_WIDTH/2, aViewHeight/2);
    
    
    upImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scroll_up"]];
    [pwdBgView addSubview:upImgView];
    upImgView.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT - FLoatChangeBaseIphone6(65));
    
    //姓名
    UIView * nameBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 2 * SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [scroll addSubview:nameBgView];
    backTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(tapedOnBgviewForHideKeyboard:)];
    [nameBgView addGestureRecognizer:backTap];
    
    
    lbl = [[UILabel alloc] init];
    [nameBgView addSubview:lbl];
    lbl.text = @"使用默认姓名";
    lbl.font = [UIFont systemFontOfSize:FLoatChangeBaseIphone6(18)];
    [lbl sizeToFit];
    lbl.textColor = txtColor;
    lbl.center = CGPointMake(SCREEN_WIDTH/2, FLoatChangeBaseIphone6(83));
    
    
    lbl = [[UILabel alloc] init];
    [nameBgView addSubview:lbl];
    lbl.text = @"这并不符合您的气质";
    lbl.font = [UIFont systemFontOfSize:FLoatChangeBaseIphone6(15)];
    [lbl sizeToFit];
    lbl.textColor = txtColor;
    lbl.center = CGPointMake(SCREEN_WIDTH/2, FLoatChangeBaseIphone6(118));
    
    
    UITextField * aTfd = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, FLoatChangeBaseIphone6(230), FLoatChangeBaseIphone6(30))];
    [nameBgView addSubview:aTfd];
    aTfd.borderStyle = UITextBorderStyleNone;
    aTfd.textAlignment = NSTextAlignmentCenter;
    //    aTfd.placeholder = @"请输入姓名";
    aTfd.center = CGPointMake(SCREEN_WIDTH / 2.0, FLoatChangeBaseIphone6(236));
    nameTfd = aTfd;
    
    UIView * lineView = [DZUtils ToolCustomLineView];
    CGRect rect = lineView.frame;
    rect.size.width = aTfd.bounds.size.width;
    lineView.frame = rect;
    [nameBgView addSubview:lineView];
    lineView.center = CGPointMake(aTfd.center.x, CGRectGetMaxY(aTfd.frame) + lineView.bounds.size.height/2.0);
    
    aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, aViewHeight)];
    [nameBgView addSubview:aView];
    aView.backgroundColor = ZAColorFromRGB(0xf4f4f4);
    aView.center = CGPointMake(SCREEN_WIDTH/2, FLoatChangeBaseIphone6(283));
    
    
    lbl = [[UILabel alloc] init];
    [aView addSubview:lbl];
    lbl.text = @"填写真实姓名有助于我们更好的为您提供安全保障";
    lbl.font = [UIFont systemFontOfSize:FLoatChangeBaseIphone6(12)];
    [lbl sizeToFit];
    lbl.textColor = ZAColorFromRGB(0xb5b5b5);
    lbl.center = CGPointMake(SCREEN_WIDTH/2, aViewHeight/2);
    
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nameBgView addSubview:btn];
    btn.frame = CGRectMake(0, 0, FLoatChangeBaseIphone6(330), FLoatChangeBaseIphone6(40));
    btn.backgroundColor = ZAColorFromRGB(0x3895ec);
    btn.layer.cornerRadius = FLoatChangeBaseIphone6(8);
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:FLoatChangeBaseIphone6(18)]];
    btn.center = CGPointMake(SCREEN_WIDTH/2, FLoatChangeBaseIphone6(360));
    [btn addTarget:self action:@selector(tapOnFinishButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self refreshNameAndPwdTtdText];
}
-(void)refreshNameAndPwdTtdText
{
    //    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    //    OthersLoginModel * others = total.othersModel;
    //    PaPaUserInfoModel * info = total.userInfo;
    //
    NSString * mobile = @"13051850106";
    //    if(others)
    //    {
    //        //名字赋值
    //        nameTfd.text = others.userName;
    //    }else if(!info.username)
    //    {
    nameTfd.text = [NSString stringWithFormat:@"PP%@",mobile];
    //    }
    
    NSString * pwdShow = [mobile substringFromIndex:[mobile length] - 4];
    [self.passwordView refreshShowStyleWithTxt:pwdShow];
    hidePwdTfd.text = pwdShow;
    self.editPwd = pwdShow;
}

-(void)tapedOnBgviewForHideKeyboard:(id)sender
{
    if(self.inWaiting) return;
    
    [hidePwdTfd resignFirstResponder];
    [nameTfd resignFirstResponder];
}
-(void)tapedOnShowPasswordInputSender:(id)sender
{
    if(self.inWaiting) return;
    
    if([self.editPwd length] == 4)
    {
        self.editPwd = @"";
        [self.passwordView refreshShowStyleWithTxt:self.editPwd];
    }
    [hidePwdTfd becomeFirstResponder];
}
- (ZALineInputPasswordView *)passwordView{
    if (_passwordView == nil) {
        _passwordView = [[ZALineInputPasswordView alloc] initWithFrame:CGRectMake(0,0, FLoatChangeBaseIphone6(220), FLoatChangeBaseIphone6(50))];
        //        _passwordView.layer.cornerRadius = FLoatChangeBaseIphone6(8);
        //        _passwordView.layer.borderWidth = 1;
        //        _passwordView.layer.borderColor = ZAColorFromRGB(0xe7e7e7).CGColor;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(tapedOnShowPasswordInputSender:)];
        [_passwordView addGestureRecognizer:tap];
        
    }
    return _passwordView;
}



#pragma mark  - User Actions
-(void)tapOnBoyButton:(id) sender{
    self.boyBtn.selected = YES;
    self.girlBtn.selected = NO;
    [self refreshTopIconImageWithIsMan:YES];
}

-(void)tapOnGirlButton:(id) sender{
    self.girlBtn.selected = YES;
    self.boyBtn.selected = NO;
    [self refreshTopIconImageWithIsMan:NO];
}
-(void)refreshTopIconImageWithIsMan:(BOOL)isMan
{
    
    UIImage * placeImage = nil;
    if(isMan)
    {
        placeImage = [UIImage imageNamed:@"img_photo_boy_new"];
    }else
    {
        placeImage = [UIImage imageNamed:@"img_photo_gril_new"];
    }
    showSexImg.image = placeImage;
    
}
#pragma mark - UIScrollDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint endPt = scrollView.contentOffset;
    NSInteger number = endPt.y / scrollView.bounds.size.height;
    NSLog(@"number %ld",number);
    switch (number) {
        case 0:
        {
            [hidePwdTfd resignFirstResponder];
            [nameTfd resignFirstResponder];
        }
            break;
        case 1:
        {
            if([nameTfd isFirstResponder])
            {
                [nameTfd resignFirstResponder];
            }
        }
            break;
        case 2:
        {
            [nameTfd becomeFirstResponder];
        }
            break;
        default:
            break;
    }
    
}
-(void)tapOnFinishButton:(id)sender
{
    
}

//-(void)tapOnFinishButton:(id) sender
//{
//
//    NSString *inputName = nameTfd.text;
//
//
//    NSString * errorStr = nil;
//    //判定用户名
//    errorStr = [ZATfdLocalCheck localCheckInputUserNameWithText:inputName];
//    if(errorStr)
//    {
//        [DZUtils noticeCustomerWithShowText:errorStr];
//        return;
//    }
//
//    //判定密码状态
//
//    BOOL isMan = YES;
//    if(self.girlBtn.selected){
//        isMan = NO;
//    }
//
//
//    //数据上传
//    ModifyUserInfoModel  * model = (ModifyUserInfoModel *) _dpModel;
//    if(!model){
//        model = [[ModifyUserInfoModel alloc] init];
//        [model addSignalResponder:self];
//        _dpModel = model;
//    }
//    model.username = inputName;
//    model.gender = isMan?@"男":@"女";
//    model.password = @"";
//    [model sendRequest];
//
//}
//#pragma mark ModifyUserInfoModel
//handleSignal( ModifyUserInfoModel, requestError )
//{
//    [self hideLoading];
//    [DZUtils checkAndNoticeErrorWithSignal:signal];
//}
//handleSignal( ModifyUserInfoModel, requestLoading )
//{
//    [self showLoading];
//}
//
//handleSignal( ModifyUserInfoModel, requestLoaded )
//{
//    [self hideLoading];
//    if([DZUtils checkAndNoticeErrorWithSignal:signal])
//    {
//        [self refreshWithSuccess];
//    }
//}
//#pragma mark -
//
//-(void)refreshWithSuccess
//{
//
//    ModifyUserInfoModel  * modifyModel = (ModifyUserInfoModel *) _dpModel;
//
//    //长度
//    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
//    PaPaUserInfoModel * info = model.userInfo ;
//    info.username = modifyModel.username;
//    info.gender = modifyModel.gender;
//    info.password = modifyModel.password;
//    model.userCompleteDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
//    [model localSave];
//
//    //回收，相当于登录成功
//    UIViewController * vc = self.navigationController;
//    if([vc presentingViewController])
//    {
//        [vc dismissViewControllerAnimated:YES completion:nil];
//    }else{
//        //替换
//        AppDelegate * appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [appDel refreshWindowRootViewControllerWithLogin:NO];
//
//        [self.navigationController popToRootViewControllerAnimated:NO];
//    }
//}
#pragma mark - UItextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if([self.editPwd length] == 0)
    {
        //    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        //    OthersLoginModel * others = total.othersModel;
        //    PaPaUserInfoModel * info = total.userInfo;
        //
        NSString * mobile = @"13051850106";
        NSString * pwdShow = [mobile substringFromIndex:[mobile length] - 4];
        if([self.finishPwd length] > 0){
            pwdShow = self.finishPwd;
        }
        [self.passwordView refreshShowStyleWithTxt:pwdShow];
        hidePwdTfd.text = pwdShow;
        self.editPwd = pwdShow;
    }
    [self refreshPasswordTipLblWithDetailTxt:@"解除防护时大有用处"];
    self.prePwd = nil;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(self.inWaiting) return NO;
    
    NSString * result = self.editPwd;
    NSInteger removeLength = range.length;
    
    if(removeLength == 0){
        result = [result stringByAppendingString:string];
    }else{
        if([result length]> removeLength)
        {
            result = [result substringToIndex:[result length] - removeLength];
        }
    }
    
    if([result length] >= 4)
    {
        if([result length] > 4)
        {
            result = [result substringWithRange:NSMakeRange(0, 4)];
        }
        
        CGFloat animationLength = 0.2;
        //进行提示切换
        if(!self.prePwd)
        {
            self.finishPwd = nil;
            self.prePwd = result;
            self.inWaiting = YES;
            [self refreshScrollStateForWaitingState:self.inWaiting];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationLength * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self refreshPasswordTipLblWithDetailTxt:@"请再次输入密码"];
                NSString * endResult = @"";
                [self.passwordView refreshShowStyleWithTxt:endResult];
                self.editPwd = endResult;
                self.inWaiting = NO;
                [self refreshScrollStateForWaitingState:self.inWaiting];
            });
        }else if(![result isEqualToString:self.prePwd])
        {
            self.finishPwd = nil;
            self.prePwd = nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationLength * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self refreshPasswordTipLblWithDetailTxt:@"密码确认失败，请重新输入"];
                NSString * endResult = @"";
                [self.passwordView refreshShowStyleWithTxt:endResult];
                self.editPwd = endResult;
                self.inWaiting = NO;
                [self refreshScrollStateForWaitingState:self.inWaiting];
            });
            //两次不一致，重新输入
        }else
        {
            //设置成功
            self.prePwd = nil;
            self.finishPwd = result;
            [self refreshPasswordTipLblWithDetailTxt:@"密码设置成功"];
            [hidePwdTfd resignFirstResponder];
        }
    }
    if([result length] <= 4)
    {
        [self.passwordView refreshShowStyleWithTxt:result];
        self.editPwd = result;
    }
    return NO;
}
#pragma mark - TipsRefresh
-(void)refreshPasswordTipLblWithDetailTxt:(NSString *)txt
{
    CGPoint pt = pwdTipsLbl.center;
    pwdTipsLbl.text = txt;
    [pwdTipsLbl sizeToFit];
    pwdTipsLbl.center = pt;
}
-(void)refreshScrollStateForWaitingState:(BOOL)waiting
{
    bgScrollView.scrollEnabled = !waiting;
    
}


@end
