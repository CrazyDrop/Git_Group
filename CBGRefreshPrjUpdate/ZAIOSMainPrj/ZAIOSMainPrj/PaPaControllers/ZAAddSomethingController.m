//
//  ZAAddSomethingController.m
//  ZAIOSMainPrj
//
//  Created by 赵宪云 on 15/12/31.
//  Copyright © 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAAddSomethingController.h"
#define ZAAddSomethingControllerTotalLength  30
@interface ZAAddSomethingController ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *tfd;
@end

@implementation ZAAddSomethingController

- (id)init{
    self = [super init];
    if (self) {
        self.viewTtle = @"分享个人轨迹";
        self.showLeftBtn = YES;
        self.showRightBtn = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = Custom_View_Gray_BGColor;
    
    CGFloat startX = FLoatChange(12);
    CGFloat startY = CGRectGetMaxY(self.titleBar.frame);
    CGFloat length = SCREEN_WIDTH - startX * 2;
    CGFloat height = FLoatChange(45);
    
    UIView * leftV = [[UIView alloc] initWithFrame:CGRectMake(0, startY, SCREEN_WIDTH, height)];
    leftV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:leftV];
    
    
    UITextField *tfd = [[UITextField alloc]initWithFrame:CGRectMake(startX, startY, length, height)];
    tfd.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewValueChange:) name:UITextViewTextDidChangeNotification object:nil];
    self.tfd = tfd;
    tfd.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tfd];
    tfd.font = [UIFont systemFontOfSize:FLoatChange(12.0)];
    tfd.returnKeyType = UIReturnKeyDone;
    tfd.placeholder = kShare_Default_Message;// 暂定
    [tfd setClearButtonMode:UITextFieldViewModeAlways];
    
    
    UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    lbl.font = [UIFont systemFontOfSize:FLoatChange(11)];
    lbl.text = @"最多只能捎30个字哦！";
    lbl.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lbl];
    [lbl sizeToFit];
    lbl.textColor = [UIColor lightGrayColor];
    lbl.center = CGPointMake(SCREEN_WIDTH/2.0, CGRectGetMaxY(tfd.frame) + lbl.bounds.size.height/2.0 + FLoatChange(15));
    
    
    CGRect rect = self.view.bounds;
    rect.size.width = FLoatChange(275);
    rect.size.height = FLoatChange(43);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = rect;
    btn.backgroundColor = Custom_Blue_Button_BGColor;
    [[btn layer]setCornerRadius:5.0];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.center = CGPointMake(SCREEN_WIDTH/2.0, self.view.bounds.size.height - FLoatChange(100) + rect.size.height/2.0);
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self.tfd becomeFirstResponder];
}
// 提交
- (void)submit
{
    
    NSString * input = self.tfd.text;
    if([input length]==0)
    {
        input = nil;
    }
    
    if(input)
    {
        NSString * check = [input stringByReplacingOccurrencesOfString:@" " withString:@""];
        check = [input stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if([check length]==0)
        {
            input = nil;
        }
    }
    
    if (self.DoneEditToDoBlock) {
        self.DoneEditToDoBlock(input);
    }
    [self.navigationController popViewControllerAnimated:YES];
//    [[NSUserDefaults standardUserDefaults] setObject:self.tfd.text forKey:@"test"];
}

-(void)textViewValueChange:(id)sender
{
    //当数值超过限定值，直接剪切
    
    if ([self.tfd.text length]>ZAAddSomethingControllerTotalLength)
    {
        self.tfd.text = [self.tfd.text substringToIndex:ZAAddSomethingControllerTotalLength];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string length]==0)
    {
        return YES;
    }
    if([textField.text length]>=ZAAddSomethingControllerTotalLength){
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.tfd resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.tfd resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
