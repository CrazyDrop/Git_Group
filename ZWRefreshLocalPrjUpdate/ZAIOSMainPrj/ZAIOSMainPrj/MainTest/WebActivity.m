//
//  WebActivity.m
//  demo
//
//  Created by zhangchaoqun on 15/4/29.
//  Copyright (c) 2015年 Geek-Zoo Studio. All rights reserved.
//

#import "WebActivity.h"
#import "OLWebView.h"
@interface WebActivity ()

@end

@implementation WebActivity

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    OLWebView * web = [[OLWebView alloc] initWithFrame:rect];
    [self.view addSubview:web];
    
    
    if(self.webUrl)
    {
        NSURL * url = [NSURL URLWithString:_webUrl];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [web loadRequest:request];
    }

    if(self.localPath)
    {
        NSString *path=[[NSBundle mainBundle]bundlePath];
        NSURL * baseURL=[[NSURL alloc]initFileURLWithPath:path];
        
        NSString * localHTML = [NSString stringWithContentsOfFile:_localPath encoding:NSUTF8StringEncoding error:nil];
        [web loadHTMLString:localHTML baseURL:baseURL];
    }
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
