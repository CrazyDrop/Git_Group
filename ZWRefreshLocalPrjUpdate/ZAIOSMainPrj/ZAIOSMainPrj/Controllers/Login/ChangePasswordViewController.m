//
//  ChangePasswordViewController.m
//  Photography
//
//  Created by jialifei on 15/4/10.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UserInfo.h"
@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController


- (id)init{
    self = [super init];
    if (self) {
        self.viewTtle =@"修改密码";;
        self.showRightBtn = YES;
        self.showLeftBtn = YES;
        self.rightTitle = @"发送";
        self.rightAction = @selector(submitAction);
    }
    return self;
}

-(void)submit
{
    if (_firstPassword.text.length ==0 ){
          [DZUtils noticeCustomerWithShowText:@"请输入密码"];
        return;
    }
    
    if (_firstPassword.text.length < 6 ){
        [DZUtils noticeCustomerWithShowText:@"修改的密码不能小与6位"];
        return;
    }
    
    if ( ![_firstPassword.text isEqualToString:_secondPassword.text]) {
        [DZUtils noticeCustomerWithShowText:@"新密码二次输入不一致"];
        return;
    }
    
    self.myClient.myNav = self.navigationController;
    self.myClient.delegate =self;
    NSString *url = [NSString stringWithFormat:@"%@sdbt/user_updateUser",URL_HEAD];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:[UserInfo sharedUser].userId forKey:@"user_id"];
    [dic setValue:_firstPassword.text forKey:@"newpassword"];
    [dic setValue:_minePassWord.text forKey:@"password"];
    [dic setValue:[UserInfo sharedUser].userToken forKey:@"token"];
    
    [self.myClient postData:url params:dic file:nil finish:@selector(changePassWordFinsh:) fail:@selector(changePassWordFinsh:) andCancel:nil];
}

-(void)changePassWordFinsh:(NSDictionary *)data
{
    [DZUtils noticeCustomerWithShowText:data[@"info"]];
    if ([data[@"state"] isEqualToString:@"0"]) {//如果是修改失败留在本页面
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)changePassWordFail:(NSDictionary *)data
{
     [DZUtils noticeCustomerWithShowText:data[@"info"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = VIEW_GAYCOLOR;
    
    [_firstBg.layer setCornerRadius:5.0];
    [_secondBg.layer setCornerRadius:5.0];
    [_mineBg.layer setCornerRadius:5.0];
    // Do any additional setup after loading the view from its nib.
    _mineBg.translatesAutoresizingMaskIntoConstraints = YES;
    _firstBg.translatesAutoresizingMaskIntoConstraints = YES;
    _secondBg.translatesAutoresizingMaskIntoConstraints = YES;
    
    _firstPassword.translatesAutoresizingMaskIntoConstraints = YES;
    _secondPassword.translatesAutoresizingMaskIntoConstraints = YES;
    _minePassWord.translatesAutoresizingMaskIntoConstraints = YES;
    
    _firstBg.frame = CGRectMakeAdapter(10, 65+18, 300, 45);
    _firstPassword.frame = CGRectMakeAdapter(5, 0, 300, 45);
    _firstPassword.font = [UIFont systemFontOfSize:FLoatChange(14.0)];

    
    _mineBg.frame = CGRectMakeAdapter(10, 65+18+45+10, 300, 45);
    _minePassWord.frame = CGRectMakeAdapter(5, 0, 300, 45);
    _minePassWord.font = [UIFont systemFontOfSize:FLoatChange(14.0)];

    _secondBg.frame = CGRectMakeAdapter(10, 65+18+45+10 +45+10, 300, 45);
    _secondPassword.frame = CGRectMakeAdapter(5, 0, 300, 45);
    _secondPassword.font = [UIFont systemFontOfSize:FLoatChange(14.0)];
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
