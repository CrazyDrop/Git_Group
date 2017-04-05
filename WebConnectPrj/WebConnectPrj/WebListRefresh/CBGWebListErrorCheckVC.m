//
//  CBGWebListErrorCheckVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/25.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGWebListErrorCheckVC.h"

@interface CBGWebListErrorCheckVC ()<UIWebViewDelegate>
@property (nonatomic,strong) UIWebView * showWeb;
@end

@implementation CBGWebListErrorCheckVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showLeftBtn = YES;
    self.showRightBtn = YES;
    self.viewTtle = @"验证码";
    self.rightTitle = @"完成";
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, FLoatChange(65), SCREEN_WIDTH, SCREEN_HEIGHT -FLoatChange(65))];
    [self.view addSubview:webView];
    //    http://115.159.68.180:8080/sdbt/about.html
    
    //    NSString *urlString = [NSString stringWithFormat:@"%@%@",URL_HEAD,_url];
    NSString * urlString = @"http://xyq.cbg.163.com/cgi-bin/xyq_overall_search.py?act=show_search_role_form";
    if(!urlString)
    {
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    webView.delegate = self;
    self.showWeb = webView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * nextUrl = request.URL.absoluteString;
//    NSLog(@"nextUrl %@",nextUrl);
    NSString * comparePre = @"http://xyq.cbg.163.com/cgi-bin/xyq_overall_search.py?";
    if([nextUrl hasPrefix:comparePre])
    {
//        NSString * detailStr = [nextUrl stringByReplacingOccurrencesOfString:comparePre withString:@""];
//        NSArray * detailArr = [detailStr componentsSeparatedByString:@"&"];
        comparePre = [comparePre stringByAppendingString:[NSDate unixDate]];
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        total.randomAgent =  [comparePre MD5String];
    }
    return YES;
}
-(void)submit
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEED_REFRESH_WEB_ERROR_STATE object:[NSNumber numberWithBool:NO]];
    
    [[self rootNavigationController] popViewControllerAnimated:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self startWebDetailJSForNextPage];
    NSString * nextUrl = [webView request].URL.absoluteString;
    NSLog(@"webViewDidFinishLoad %@",nextUrl);
    
//    if()
    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEED_REFRESH_WEB_ERROR_STATE object:[NSNumber numberWithBool:NO]];
    }
    
}
-(void)startWebDetailJSForNextPage
{
    NSString * runJs = @"window.document.getElementById('level_min').value='15'";
    NSString * result = [self.showWeb stringByEvaluatingJavaScriptFromString:runJs];
    
    runJs = @"submit_query_form();";
    result = [self.showWeb stringByEvaluatingJavaScriptFromString:runJs];
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
