//
//  ZAAgreeMentController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 15/10/30.
//  Copyright (c) 2015年 ZhongAn Insurance. All rights reserved.
//

#import "ZAAgreeMentController.h"

@interface ZAAgreeMentController ()
{
    
}
@end

@implementation ZAAgreeMentController
- (void)viewDidLoad
{
    self.showLeftBtn = YES;
    self.viewTtle = @"怕怕用户协议";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = Custom_View_Gray_BGColor;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y = CGRectGetMaxY(self.titleBar.frame);
    rect.size.height -= rect.origin.y;
    
//    UITextView * txtView = [[UITextView alloc] initWithFrame:rect];
//    [self.view addSubview:txtView];
//    txtView.editable = NO;
//    [txtView setText:[self localAgreeMentTxt]];
//    txtView.font = [UIFont systemFontOfSize:FLoatChange(14)];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:rect];
    [self.view addSubview:webView];
    webView.backgroundColor = [UIColor clearColor];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"papa_agreement.html" ofType:nil];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    [webView loadRequest:request];
}

//-(NSString *)localAgreeMentTxt
//{
//    NSString * totalString = [NSMutableString string];
//
//    
//    return totalString;
//}


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
