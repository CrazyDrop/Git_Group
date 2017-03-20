//
//  OtherRegisterController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/5/27.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "OtherRegisterController.h"
#import "JKCountDownButton.h"
#import "InfoCompleteController.h"
@interface OtherRegisterController ()

@end

@implementation OtherRegisterController

-(id)init
{
    self = [super init];
    if(self) self.viewTtle =ZAViewLocalizedStringForKey(@"ZAViewLocal_OtherLogin_Register_Title");
    return self;
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
        [DZUtils noticeCustomerWithShowText:@"补充资料成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

handleSignal( RegisterModel, requestError )
{
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
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
    model.checkType = CaptchaTypeThirdPartyRegister;
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
    
    model.otherToken = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_NAME_OTHERLOGIN_TOKEN];
    model.otherTokenType = [[[NSUserDefaults standardUserDefaults] valueForKey:USERDEFAULT_NAME_OTHERLOGIN_TOKENTYPE] intValue];
    [model sendRequest];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [finishBtn setTitle:ZAViewLocalizedStringForKey(@"ZAViewLocal_OtherLogin_Register_Button_Title") forState:UIControlStateNormal];
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
