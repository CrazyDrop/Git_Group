//
//  ZAAutoBuyHomeVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/24.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZAAutoBuyHomeVC.h"
#import "ZAAutoBuyWebView.h"
@interface ZAAutoBuyHomeVC ()
@property (nonatomic, strong) ZAAutoBuyWebView * showWeb;
@end

@implementation ZAAutoBuyHomeVC

- (void)viewDidLoad {
    
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    BOOL autoBuy =
    total.limitPrice > self.price &&
    total.limitRate < self.rate;

    self.viewTtle = @"自动购买";
    self.showRightBtn = YES;
    if(autoBuy)
    {
        self.rightTitle = @"继续";
    }else{
        self.rightTitle = @"购买";
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * bgView = self.view;
    bgView.backgroundColor = [UIColor whiteColor];
    
    NSString * urlString = self.webUrl;
    
    
    ZAAutoBuyWebView * autoWeb = self.showWeb;
    [bgView addSubview:autoWeb];
    if(autoBuy)
    {
        autoWeb.autoStyle = ZAAutoBuyStep_PasswordTotal;
    }
    
    if(urlString)
    {
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        [autoWeb loadRequest:request];
    }
}
-(void)submit
{
    if(self.showWeb.autoStyle == ZAAutoBuyStep_None)
    {
        self.showWeb.autoStyle = ZAAutoBuyStep_PayPassword;
        [self.showWeb checkAndFinishLatestJSFunction];
    }else{
        [self.showWeb checkAndFinishLatestJSFunction];
    }
}

-(ZAAutoBuyWebView *)showWeb
{
    if(!_showWeb)
    {
        ZAAutoBuyWebView * aWeb = [[ZAAutoBuyWebView alloc] initWithFrame:CGRectMake(0, FLoatChange(65), SCREEN_WIDTH, SCREEN_HEIGHT -FLoatChange(65))];
        self.showWeb = aWeb;
    }
    return _showWeb;
    
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
