//
//  PassWordViewController.m
//  Photography
//
//  Created by jialifei on 15/3/21.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "PassWordViewController.h"
#import "RegisterInfoViewController.h"
#import "MKNetworkKit.h"
@interface PassWordViewController ()
{
    UITextField *first;
    UITextField *second;
}
@end

@implementation PassWordViewController

- (id)initWithType:(NSString *)type{
    self = [super init];
    if (self) {
        self.type= type;
        if ([_type isEqualToString:@"reg"]) {
            self.viewTtle =@"注册";
            self.showRightBtn = YES;
            self.showLeftBtn = YES;
            self.rightTitle = @"下一步";
        }else{
            self.viewTtle =@"忘记密码";
            self.showRightBtn = YES;
            self.showLeftBtn = YES;
            self.rightTitle = @"发送";
        }
    }
    return self;
}

//- (void)submit
//{
//    "RegisterInfoViewControlle
//
//}

// http://115.159.68.180:8080/sdbt/modifyPassword

-(BOOL)checkPassword
{
    if (first.text.length == 0) {
        [DZUtils noticeCustomerWithShowText:@"密码不能为空"];
        return YES;
    }
    
    if (first.text.length <6) {
        [DZUtils noticeCustomerWithShowText:@"密码小于6位数"];
        return YES;
    }
    
    if (![first.text isEqualToString:second.text]) {
        
        [DZUtils noticeCustomerWithShowText:@"密码不一致"];
        return YES;
    }
    return NO;
}

-(void)submit
{
    if ([self checkPassword]) {
        return;
    }
    
    if ([_type isEqualToString:@"reg"]) {
        RegisterInfoViewController *vc = [[RegisterInfoViewController alloc] init];
        vc.userPassword = first.text;
        vc.identify= self.identifiy;
        vc.phoneNumber= self.phoneNumber;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        NSString *req = [NSString stringWithFormat:@"%@sdbt/modifyPassword",URL_HEAD];
        self.myClient.delegate= self;
        self.myClient.myNav = self.navigationController;
        
        NSMutableDictionary *postValue = [[NSMutableDictionary alloc] init];
        [postValue setObject:_phoneNumber forKey:@"phoneno"];
        [postValue setObject: first.text  forKey:@"password"];
        
        [self.myClient postData:req params:postValue file:nil finish:@selector(reqDataFinish:) fail:@selector(reqDataFail:) andCancel:@selector(reqDataCancel:)];
    }
}

//修改密码成功
-(void)reqDataFinish:(NSDictionary *)data
{
    if ([DZUtils isValidateDictionary:data]) {
        [DZUtils noticeCustomerWithShowText:data[@"info"]];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}
//修改密码失败
-(void)reqDataFail:(NSDictionary *)data
{
    if ([DZUtils isValidateDictionary:data]) {
        [DZUtils noticeCustomerWithShowText:data[@"info"]];
    }
}

-(void)reqDataCancel:(NSDictionary *)data
{
    [DZUtils noticeCustomerWithShowText:@"修改密码失败"];
}


-(UITextField *)textFiledWitFrame:(CGRect)frame holder:(NSString *)text
{
    UIImageView *userName = [[UIImageView alloc] initWithFrame:frame];
    [self.view addSubview:userName];
    [userName.layer setCornerRadius:3.0];
    userName.userInteractionEnabled = YES;
    userName.backgroundColor = [UIColor whiteColor];
    
    UITextField  *name = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, frame.size.width-8, frame.size.height)];
    [userName addSubview:name];
//    name.textAlignment = NSTextAlignmentCenter;
    name.backgroundColor = [UIColor whiteColor];
    name.placeholder=text;//默认显示的e
    name.secureTextEntry = YES;
    
    return name;
}

-(void)creatDesLable
{
    UILabel *des = [[UILabel alloc] initWithFrame:CGRectMake(10, YFLoatChange(172), SCREEN_WIDTH -20, 12)];
    [self.view addSubview:des];
    des.font = [UIFont systemFontOfSize:12.0];;
    des.textColor = TITLE_LABLE_GAYCOLOR;
    des.text = @"6-16位(字母,数字,符号,区分大小写)";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.rightBtn setTitleColor:REDCOLOR forState:UIControlStateNormal];
    self.rightBtn.layer.borderWidth = 1.0;
    self.rightBtn.layer.borderColor = [REDCOLOR CGColor];

    self.view.backgroundColor = VIEW_GAYCOLOR;
    first =  [self textFiledWitFrame:CGRectMake(10, FLoatChange(80), FLoatChange(300) , YFLoatChange(40)) holder:@"请输入密码"];
    second =[self textFiledWitFrame:CGRectMake(10, FLoatChange (80+36+10), FLoatChange(300), YFLoatChange(40)) holder:@"确认密码"];
    [self creatDesLable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark-net work
-(void)loadData:(NSString *)url
{
    NSMutableDictionary *postValue = [[NSMutableDictionary alloc] init];
    
    [postValue setObject:_phoneNumber forKey:@"phoneno"];
    [postValue setObject: first.text  forKey:@"password"];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
    MKNetworkOperation *op = [engine operationWithURLString:url  params:postValue httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:kNilOptions error:&error];
        if (json == nil) {
            NSLog(@"login is null");
            return;
        }
        NSLog(@"%@",json);
        if ([json[@"state"] isEqualToString:@"1"]) {
            
//            [UserInfo sharedUser].userId = json[@"data"][@"user_id"];
//            [UserInfo sharedUser].userToken = json[@"data"][@"token"];
//            [UserInfo sharedUser].useImg = json[@"data"][@"user_img"];
//            MianTabBarViewController *vc = [[MianTabBarViewController alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
            [self.navigationController popToRootViewControllerAnimated:NO];
            
        }else
        {
//            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"修改势失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [al show];
           [DZUtils noticeCustomerWithShowText:@"修改密码失败"];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
    
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
