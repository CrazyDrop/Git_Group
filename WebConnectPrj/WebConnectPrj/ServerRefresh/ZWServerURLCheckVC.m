//
//  ZWServerURLCheckVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWServerURLCheckVC.h"
@interface ZWServerURLCheckVC ()<UIWebViewDelegate>
@property (nonatomic,strong) UIWebView * showWeb;
@end

@implementation ZWServerURLCheckVC

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
    NSString * urlString = @"http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=buy_show_equip_info&equip_id=2697218&server_id=625&from=game";
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
    NSLog(@"nextUrl %@",nextUrl);
//    NSString * comparePre = @"http://xyq.cbg.163.com/cgi-bin/xyq_overall_search.py?";
//    if([nextUrl hasPrefix:comparePre])
//    {
//        //        NSString * detailStr = [nextUrl stringByReplacingOccurrencesOfString:comparePre withString:@""];
//        //        NSArray * detailArr = [detailStr componentsSeparatedByString:@"&"];
//        comparePre = [comparePre stringByAppendingString:[NSDate unixDate]];
//        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//        total.randomAgent =  [comparePre MD5String];
//    }
    
    return YES;
}
-(void)submit
{
    static int  equipId = 2697219;
    equipId ++;
    NSString * urlString = [NSString stringWithFormat:@"http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=buy_show_equip_info&equip_id=%d&server_id=625&from=game",equipId];
    if(!urlString)
    {
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self.showWeb loadRequest:request];
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
    
//    runJs = @"submit_query_form();";
//    result = [self.showWeb stringByEvaluatingJavaScriptFromString:runJs];
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
