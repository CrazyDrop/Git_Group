//
//  ChangeViewController.m
//  Photography
//
//  Created by jialifei on 15/4/10.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "ChangeViewController.h"
#import "UserInfo.h"
@interface ChangeViewController ()

@end

@implementation ChangeViewController


- (id)initWithType :(NSString *)t{
    self = [super init];
    if (self) {

        self.type = t;
       self.viewTtle =@"修改会员名称";
        self.showRightBtn = YES;
        self.showLeftBtn = YES;
        self.rightTitle = @"提交";
    }
    return self;
}

-(void)submit
{
    if (_userTextfile.text.length ==0) {
        [DZUtils noticeCustomerWithShowText:@"昵称不能为空"];
        return;
    }

    if ([DZUtils charNumber:_userTextfile.text] > 10) {
        [DZUtils noticeCustomerWithShowText:@"昵称太长"];//
        return;
    }
    
    NSString *key = @"username";
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:[UserInfo sharedUser].userId forKey:@"user_id"];
    [dic setValue:_userTextfile.text forKey:key];
    [dic setValue:[UserInfo sharedUser].userToken forKey:@"token"];

    NSString *url = [NSString stringWithFormat:@"%@sdbt/user_updateNickname",URL_HEAD];
    self.myClient.delegate =self;
    self.myClient.myNav = self.navigationController;
    [self.myClient postData:url params:dic file:nil finish:@selector(changePassWordFinsh:) fail:@selector(changePassWordFinsh:) andCancel:@selector(changePassWordCancel:)];
}

-(void)changePassWordFinsh:(NSDictionary *)data
{
    [DZUtils noticeCustomerWithShowText:@"修改成功"];
    [UserInfo sharedUser].username = data[@"username"];
    [DZUtils saveUserInfnfo:data[@"username"] value:@"username"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)changePassWordFail:(NSDictionary *)data
{
    [DZUtils noticeCustomerWithShowText:@"修改失败"];
}

-(void)changePassWordCancel:(id)data
{
    [DZUtils noticeCustomerWithShowText:@"修改失败"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = VIEW_GAYCOLOR;
    [_textBg.layer setCornerRadius:5.0];
    [self.rightBtn setTitleColor:REDCOLOR forState:UIControlStateNormal];
    self.rightBtn.layer.borderWidth = 1.0;
    self.rightBtn.layer.borderColor = [REDCOLOR CGColor];
    
    _textBg.translatesAutoresizingMaskIntoConstraints = YES;
    _userTextfile.translatesAutoresizingMaskIntoConstraints = YES;

    _textBg.frame = CGRectMakeAdapter(10, 83, 300, 45);
    _userTextfile.frame = CGRectMakeAdapter(5, 0, 300, 45);
    _userTextfile.placeholder = [UserInfo sharedUser].username;
    _userTextfile.font = [UIFont systemFontOfSize:FLoatChange(14.0)];
    
    
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
