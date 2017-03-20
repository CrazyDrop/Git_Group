//
//  ShareViewController.m
//  Photography
//
//  Created by jialifei on 15/4/10.
//  Copyright (c) 2015年 jialifei. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareView.h"
@interface ShareViewController ()
{
    ShareView *shareView;
}
@end

@implementation ShareViewController


- (id)init{
    self = [super init];
    if (self) {
        self.viewTtle =@"推荐好友";
        self.showLeftBtn = YES;
        self.showRightBtn = YES;
        self.rightTitle = @"分享";
    }
    return self;
}

-(void)dismissView
{
    [shareView removeFromSuperview];
}

-(void)submit{
    shareView = [[ShareView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) type:@"share"];
    shareView.dp = self;
    [self.view addSubview:shareView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, CONTENT_HEIGHT)];
    [self.view addSubview:webView];
    //    http://115.159.68.180:8080/sdbt/about.html
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",URL_HEAD,_url];
    NSURL *url = [NSURL URLWithString:urlString];
    
    //    NSData *data = [NSData dataWithContentsOfURL:url];
    //    [webView loadData:data MIMEType:@"text/html" textEncodingName:_typeCode baseURL:nil];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)shareWeiChat
{
    [shareView removeFromSuperview];
    UIImage * img = [UIImage imageNamed:@"shareIcon"];
    [DZUtils sendImageContentWithScene:0 imgae:img];
}

-(void)shareSenceFriends
{
    [shareView removeFromSuperview];
    UIImage * img = [UIImage imageNamed:@"shareIcon"];
    [DZUtils sendImageContentWithScene:1 imgae:img];
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
