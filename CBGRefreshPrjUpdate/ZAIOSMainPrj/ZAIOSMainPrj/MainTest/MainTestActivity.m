//
//  MainTestActivity.m
//  demo
//
//  Created by zhangchaoqun on 15/4/29.
//  Copyright (c) 2015年 Geek-Zoo Studio. All rights reserved.
//

#import "MainTestActivity.h"
#import "WebActivity.h"
#import "GetContactsModelAPI.h"

@interface MainTestActivity ()
{
    BaseRequestModel * _model;
}
@end

@implementation MainTestActivity

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat startY = 50;
    CGFloat startX = 10;
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(startX, startY, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"Location" forState:UIControlStateNormal];
    btn.tag = 10;
    
    startY +=  150;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(startX, startY, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"userinfo" forState:UIControlStateNormal];
    btn.tag = 11;
    
    startY  = 50;
    startX += 150;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(startX, startY, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"联系人add" forState:UIControlStateNormal];
    btn.tag = 12;
    
    startY +=  150;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(startX, startY, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"联系人up" forState:UIControlStateNormal];
    btn.tag = 13;
    
    startY +=  150;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(startX, startY, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(tapedOnButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"网络测试 百度" forState:UIControlStateNormal];
    btn.tag = 14;
}
-(void)tapedOnButton:(id)sender
{
    NSInteger num = [(UIButton *)sender tag] - 10;
    BaseRequestModel * model = nil;
    switch (num)
    {
        case 0:
        {
            
            

            
            LocationModel * locModel = [[LocationModel alloc] init];
            locModel.latitude = @"123.45";
            locModel.longtitude = @"45.67";
            locModel.altitude = @"100.23";
            locModel.scene = @"1";
            locModel.priority = @"0";
            model = locModel;

        }
            break;
            
        case 1:
        {
            
            WarnTimingModel * warn = [[WarnTimingModel alloc] init];
            warn.scene = @"1";
            warn.duration = @"20";
            model = warn;

//            PaPaUserInfoModel * infoModel = [[PaPaUserInfoModel alloc] init];
//            infoModel.username = @"fsaf";
//            infoModel.mobile = @"13051850106";
//            model = infoModel;
        }
            break;
        case 2:
        {
            WarningModel * warn = [[WarningModel alloc] init];
//            warn.timingId = @"12001";
//            warn.type = WarningModel_TYPE_START;
            model = warn;
            
//            ContactsModel * aModel = [[ContactsModel alloc] init];
//            aModel.contactName = @"添加";
//            aModel.contactMobile = @"13468095825";
//            aModel.relation = @"同学";
//            model = aModel;
        }
            break;
        case 3:
        {
            GetContactsModel * aModel = [[GetContactsModel alloc] init];
            model = aModel;
            
//            DelContactsModel * delCon = [[DelContactsModel alloc] init];
//            delCon.id = @"12001";
//            model = delCon;
            
//            ContactsModel * aModel = [[ContactsModel alloc] init];
//            aModel.id = @"8002";
//            aModel.contactName = @"修改";
//            aModel.contactMobile = @"11111111111";
//            aModel.relation = @"朋友";
//            model = aModel;
        }
            break;
        case 4:
        {
            ZAHTTPApi * api = [[ZAHTTPApi alloc] init];
            AFHTTPSessionManager * manager =  [api HTTPSessionManager];
            NSLog(@"start AFHTTPSessionManager");
            [manager GET:@"http://www.baidu.com/"
              parameters:nil
                 success:^(NSURLSessionDataTask *task, id responseObject) {
                     NSLog(@"%s success",__FUNCTION__);
                 } failure:^(NSURLSessionDataTask *task, NSError *error) {
                     NSLog(@"%s fail",__FUNCTION__);
                 }];
            
        }
            break;
        default:
            break;
    }

    _model = model;
    [model addSignalResponder:self];
    [model sendRequest];
    
}

#pragma mark LocationModel
handleSignal( GetContactsModel, requestError )
{
    
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
handleSignal( GetContactsModel, requestLoading )
{
    [self showLoading];
}

handleSignal( GetContactsModel, requestLoaded )
{
    NSLog(@"GetContactsModel contacts %@",[(GetContactsModel *)_model contacts]);
    
    [self hideLoading];
    if([DZUtils checkAndNoticeErrorWithSignal:signal])
    {
        [DZUtils noticeCustomerWithShowText:@"退出登录"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark WarningModel
handleSignal( LocationModel, requestError )
{
    NSLog(@"%s",__FUNCTION__);
    [self hideLoading];
    [DZUtils checkAndNoticeErrorWithSignal:signal];
}
#pragma mark -
handleSignal( LocationModel, requestLoading )
{
    [self showLoading];
    
}

handleSignal( LocationModel, requestLoaded )
{
    NSLog(@"%s",__FUNCTION__);
//    NSString * lockStr = signal.object;
    [self hideLoading];
    
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
