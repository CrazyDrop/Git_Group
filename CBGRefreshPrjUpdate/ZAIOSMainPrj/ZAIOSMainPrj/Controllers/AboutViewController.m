//
//  AboutViewController.m
//  Photography
//
//  Created by jialifei on 15/4/10.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController


- (void)viewDidLoad {
    self.showLeftBtn = YES;
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, YFLoatChange(65), FLoatChange(320), SCREEN_HEIGHT -YFLoatChange(65))];
    [self.view addSubview:webView];
//    http://115.159.68.180:8080/sdbt/about.html
    
//    NSString *urlString = [NSString stringWithFormat:@"%@%@",URL_HEAD,_url];
    NSString * urlString = _url;
    NSURL *url = [NSURL URLWithString:urlString];
    
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    [webView loadData:data MIMEType:@"text/html" textEncodingName:_typeCode baseURL:nil];

    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
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
