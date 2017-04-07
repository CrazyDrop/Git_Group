//
//  CBGPlanDetailPreShowWebVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/4/7.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGPlanDetailPreShowWebVC.h"
#import "CBGDetailWebView.h"
@interface CBGPlanDetailPreShowWebVC ()
//@property (nonatomic, strong) UIWebView * planWebView;
@property (nonatomic, strong) NSDate * finishDate;
@end



@implementation CBGPlanDetailPreShowWebVC
-(UIWebView *)planWebView
{
    if(!_planWebView){
        UIWebView * aWeb = [[UIWebView alloc] init];
        _planWebView = aWeb;
    }
    return _planWebView;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(planBuyExchangeForDetailUrlPreUpload:)
//                                                     name:NOTIFICATION_NEED_PLAN_BUY_REFRESH_STATE
//                                                   object:nil];


    }
    return self;
}
-(void)cancelWebViewLatestLoad
{
    if(_planWebView)
    {
        [self.planWebView stopLoading];
        self.planWebView.delegate = nil;
        [self.planWebView removeFromSuperview];
        self.planWebView = nil;
    }
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    //已经被加载过
    
    UIWebView * preWeb = self.showWeb;
    preWeb.hidden = YES;
    
    UIWebView * webView = self.planWebView;
    webView.frame = preWeb.frame;
    webView.delegate = preWeb.delegate;
    [preWeb.superview insertSubview:webView belowSubview:preWeb];
    
    self.showWeb = webView;
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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
