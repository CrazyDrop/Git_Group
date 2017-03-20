//
//  IdentifyViewController.m
//  Photography
//
//  Created by jialifei on 15/3/21.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "IdentifyViewController.h"
#import "PassWordViewController.h"


@interface IdentifyViewController ()
{
    float endY;
    BOOL timeout;
    UILabel *time;
    int times;
    NSTimer *mytimer;
    UITextField  *number;
}

@end

@implementation IdentifyViewController



-(id)initWithType:(NSString *)type 
{
    self = [super init];
    if (self) {
        self.type = type;
        if ([type isEqualToString:@"reg"]) {
            self.viewTtle =@"注册";
            self.showLeftBtn = YES;
            self.showRightBtn = YES;
            self.rightTitle = @"下一步";
        }else{
            self.viewTtle =@"忘记密码";
            self.showLeftBtn = YES;
            self.showRightBtn = YES;
            self.rightTitle = @"下一步";
        }
    }
    return self;
}

-(void)showTimeLable
{
    CGPoint center = self.titleBar.center;
    time= [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH -FLoatChange(106), center.y-YFLoatChange(5) , FLoatChange(45) ,YFLoatChange(30))];
    time.backgroundColor = [UIColor whiteColor];
    time.layer.borderWidth = 1.0;
    time.textAlignment = NSTextAlignmentCenter;
    time.layer.borderColor = [TITLE_LABLE_GAYCOLOR CGColor];
//    time.font = [UIFont systemFontOfSize:6.0];
    time.text = @"90s";
    time.hidden = timeout;
    time.textColor = TITLE_LABLE_GAYCOLOR;
    [self.titleBar  addSubview:time];
}

-(void)submit
{
//    PassWordViewController *vc = [[PassWordViewController alloc] initWithType:@"for"];
//    vc.identifiy = number.text;
//    vc.phoneNumber = self.phoneNumber;
//    [self.navigationController pushViewController:vc animated:YES];
    
    if (number.text.length==0) {
        [DZUtils noticeCustomerWithShowText:@"验证码不能为空"];
        return;
    }
    
    NSString *req  ;

    if ([_type isEqualToString:@"reg"]) {
        NSLog(@"现在注册");
        req  = [NSString stringWithFormat:@"%@sdbt/user_getCode?validatecode=%@&phoneno=%@",URL_HEAD,number.text,_phoneNumber];
        
        [self.myClient getData:req finish:@selector(registerCodeFinish:) fail:@selector(registerCodeFail:)];
    }else{
        NSLog(@"现在忘记密码");
        req  = [NSString stringWithFormat:@"%@sdbt/validateSmsCode?phoneno=%@&identifyingcode=%@",URL_HEAD,_phoneNumber,number.text];
        [self.myClient getData:req finish:@selector(registerCodeFinish:) fail:@selector(registerCodeFail:)];

    }
}

-(void)registerCodeFinish:(NSDictionary *)data
{
    PassWordViewController *vc = [[PassWordViewController alloc] initWithType: _type];
    vc.phoneNumber = _phoneNumber;
    vc.identifiy = number.text;
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)registerCodeFail:(NSDictionary *)data
{
    [DZUtils noticeCustomerWithShowText:data[@"info"]];
}

-(void)initIdentifyNumber{
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, endY, FLoatChange(300) , YFLoatChange(40))];
    bg.backgroundColor = [UIColor whiteColor];
    [bg.layer setCornerRadius:5.0];//圆角
    bg.userInteractionEnabled =YES;
    [self.view addSubview:bg];
    endY = bg.frame.origin.y;
    number = [[UITextField alloc] initWithFrame:CGRectMakeAdapter(5, 5, 290, 30)];
    [bg addSubview:number];
    number.backgroundColor = [UIColor whiteColor];
    number.keyboardType =UIKeyboardTypePhonePad;
    number.placeholder=@"请输入验证码";//默认显示的
    [number becomeFirstResponder];
}

- (void)showPhoneNumber{
    
    number = [[UITextField alloc] initWithFrame:CGRectMake(10, NAVBAR_HEIGHT+25, self.view.frame.size.width -20, 16)];
    [self.view addSubview:number];
    //number.backgroundColor = [UIColor redColor];
    number.text = [@"你的手机号码: " stringByAppendingString:_phoneNumber];
    number.keyboardType = UIKeyboardTypePhonePad;
    [number.layer setCornerRadius:5.0];
    number.textColor = TITLE_LABLE_COLOR;
    endY = number.frame.size.height +  number.frame.origin.y + 25;
}

- (void)timerAdvanced:(NSTimer *)timer//这个函数将会执行一个循环的逻辑
{
    times--;
    if (times != 0) {
        time.text = [NSString stringWithFormat:@"%ds", times];
        return;
    }
    [timer invalidate];
    timer = nil;
    timeout = YES;
    time.hidden = timeout;
    self.rightBtn.userInteractionEnabled = NO;
    //[self.rightBtn setTitleColor:TITLE_LABLE_GAYCOLOR forState:UIControlStateNormal];
}

- (void)StartTimer
{
    //repeats设为YES时每次 invalidate后重新执行，如果为NO，逻辑执行完后计时器无效
    mytimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAdvanced:) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [mytimer invalidate];
    mytimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor: VIEW_GAYCOLOR];
    
    self.myClient.myNav = self.navigationController;
    self.myClient.delegate =self;
    
    [self.rightBtn setTitleColor:REDCOLOR forState:UIControlStateNormal];
    self.rightBtn.layer.borderWidth = 1.0;
    self.rightBtn.layer.borderColor = [REDCOLOR CGColor];
    
    timeout = NO;
    times = 180;
    self.showRightBtn = YES;
    [self showTimeLable];
    [self StartTimer];
    [self showPhoneNumber];
    [self initIdentifyNumber];
    
    self.myClient.delegate= self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
