//
//  ZAAutoBuyWebView.m
//  WebConnectPrj
//
//  Created by Apple on 2017/5/17.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZAAutoBuyWebView.h"
@interface ZAAutoBuyWebView()<UIWebViewDelegate>
{
    NSInteger countIndex;
}
@property (nonatomic, strong) NSArray * funcArr;
@property (nonatomic, strong) UILabel * errorLbl;
@property (nonatomic, assign) ZAAutoBuyStep currentStep;
@end

@implementation ZAAutoBuyWebView

-(id)initWithFrame:(CGRect)frame
{
    self =  [super initWithFrame:frame];
    if(self)
    {
        [self addSubview:self.errorLbl];
        countIndex = 0;
        self.delegate = self;
        
    }
    return self;
}
-(UILabel *)errorLbl
{
    if(!_errorLbl)
    {
        UILabel * aLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FLoatChange(50))];
        aLbl.textColor = [UIColor redColor];
        aLbl.textAlignment = NSTextAlignmentCenter;
        self.errorLbl = aLbl;
    }
    return _errorLbl;
}


-(void)setAutoStyle:(ZAAutoBuyStep)autoStyle
{
    _autoStyle = autoStyle;
    if(autoStyle == ZAAutoBuyStep_CBGMsgTotal)
    {
        self.funcArr = [NSArray arrayWithObjects:
                        [NSNumber numberWithInteger:ZAAutoBuyStep_MakeOrder],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_PayCBG],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_SendMessage],
                        nil];
        
    }else if(autoStyle == ZAAutoBuyStep_PasswordTotal)
    {
        self.funcArr = [NSArray arrayWithObjects:
                        [NSNumber numberWithInteger:ZAAutoBuyStep_MakeOrder],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_IngoreRemain],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_PayPassword],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_EditPassword],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_FinishPassword],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_PayFinish],
                        nil];
    }
    else if(autoStyle == ZAAutoBuyStep_MessageTotal)
    {
        self.funcArr = [NSArray arrayWithObjects:
                        [NSNumber numberWithInteger:ZAAutoBuyStep_MakeOrder],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_IngoreRemain],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_PayPassword],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_EditPassword],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_FinishPassword],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_PayFinish],
                        nil];
        
//        useBalance-icon
//        useBankCardBox//列表选中第一个
        
    }
    else if(autoStyle == ZAAutoBuyStep_PrepareTotal)
    {
        self.funcArr = [NSArray arrayWithObjects:
                        [NSNumber numberWithInteger:ZAAutoBuyStep_Login],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_IngoreRemain],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_PayPassword],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_EditPassword],
                        [NSNumber numberWithInteger:ZAAutoBuyStep_FinishPassword],
                        nil];
    }
}

-(void)startNextFunction
{
    if([self.funcArr count] == 0)
    {
        [self startCurrentFunctionsJSWithLatestWebView:0];
        return;
    }
    
    NSNumber * num = [self.funcArr firstObject];
    [self startCurrentFunctionsJSWithLatestWebView:[num integerValue]];
}
-(void)checkAndFinishLatestJSFunction
{
    NSMutableArray * editArr = [NSMutableArray arrayWithArray:self.funcArr];
    NSNumber * num = [NSNumber numberWithInteger:self.currentStep];
    
    if([editArr count] > 0)
    {
        NSNumber * first = [editArr firstObject];
        if([num isEqualToNumber:first])
        {
            [editArr removeObjectAtIndex:0];
        }
    }
    self.funcArr = editArr;
    
    [self startNextFunction];
}


-(void)startCurrentFunctionsJSWithLatestWebView:(ZAAutoBuyStep)runStep
{
    self.currentStep = runStep ;
    NSString * funcJS = [self detailRunJSForDetailWebFunction:runStep];
    if(funcJS)
    {
        NSString * result = [self stringByEvaluatingJavaScriptFromString:funcJS];
        NSLog(@"webResult %lu %@",(unsigned long)runStep,result);
    }
    
    NSArray * ingoreArr =  [NSArray arrayWithObjects:
                            [NSNumber numberWithInteger:ZAAutoBuyStep_EditPassword],
                            [NSNumber numberWithInteger:ZAAutoBuyStep_SelectRemain],
                            [NSNumber numberWithInteger:ZAAutoBuyStep_IngoreRemain],
                            [NSNumber numberWithInteger:ZAAutoBuyStep_PayFinish],
                            nil];
    
    if([ingoreArr containsObject:[NSNumber numberWithInteger:runStep]]){
        [self checkAndFinishLatestJSFunction];
    }
    
}
-(NSString * )detailRunJSForDetailWebFunction:(ZAAutoBuyStep)step
{//zhang1121
    NSString * runJs = nil;
    switch (step)
    {
        case ZAAutoBuyStep_None:
        {
            
        }
            break;
        case ZAAutoBuyStep_Login:
        {
            
        }
            break;
        case ZAAutoBuyStep_TapedList:
        {
            //收藏
        }
            break;
        case ZAAutoBuyStep_TapedBack:
        {
            
        }
            break;
        case ZAAutoBuyStep_MakeOrder:
        {
            runJs = @"window.document.getElementById('btn_buy').click();";

        }
            break;
        case ZAAutoBuyStep_CancelOrder:
        {
            runJs = @"window.document.getElementById('pay_form_box').getElementsByTagName('a')[1].click();";
            
        }
            break;
            
        case ZAAutoBuyStep_PayCBG:
        {//CBG余额支付
            runJs = @"window.document.getElementById('pay_form_box').getElementsByTagName('a')[0].click();";

        }
            break;
        case ZAAutoBuyStep_SendMessage:
        {
            runJs = @"window.document.getElementById('popupDialog').getElementById('btn_get_sms_code').click();";
        }
            break;
            
        case ZAAutoBuyStep_PayInScan:
        {//扫码
            runJs = @"window.document.getElementById('qr_pay_entry').click();";
            
        }
            break;
        case ZAAutoBuyStep_IngoreRemain:
        {//不使用CBG余额
            runJs = @"window.document.getElementById('useWallet')[0].checked = false;";

        }
            break;
        case ZAAutoBuyStep_SelectRemain:
        {
            runJs = @"window.document.getElementById('useWallet')[0].checked =  true;";

        }
            break;
            
        case ZAAutoBuyStep_PayPassword:
        {//和短信支付相同的支付按钮
            runJs = @"window.document.getElementById('pay_form_box').getElementsByTagName('a')[0].click();";
        }
            break;
            
        case ZAAutoBuyStep_EditPassword:
        {
            runJs = @"window.document.getElementById('shortPayPassword').value='zhang1121';";
        }
            break;
            
        case ZAAutoBuyStep_FinishPassword:
        {
            runJs = @"window.document.getElementById('activeBtn').click();";

        }
            break;
            
        case ZAAutoBuyStep_PayFinish:
        {
            //界面结束，有下一个的话执行下一个购买，可以考虑再次打开刷新的APP，以便能够实现继续购买
            [DZUtils noticeCustomerWithShowText:@"自动支付结束"];
        }
            break;
            
        default:
            break;
    }
//                runJs = @"window.document.getElementById('eKey').value='222222';";
//                runJs = @"window.document.getElementById('form-shortPayPassword-box').getElementById('shortPayPassword').value ='zhang11';";

    return runJs;
}

#pragma mark - WEBViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"absoluteString %@",request.URL.absoluteString);
    return YES;
}

//支付
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString * absUrl = webView.request.URL.absoluteString;
    [self checkFunctionResultWithLatestBackRequestUrl:absUrl];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}
#pragma mark -
-(void)checkFunctionResultWithLatestBackRequestUrl:(NSString *)urlStr
{
    BOOL  runNext = NO;
    
    if([urlStr containsString:@"equipquery.py?"]){
        //初次加载
        runNext = YES;
    }else if([urlStr containsString:@"usertrade.py?"])
    {//下单
        if([urlStr containsString:@"&new=1"])
        {
            runNext = YES;
        }else{
            self.errorLbl.text = @"下单失败";
        }
    }else if([urlStr containsString:@"standardCashier?"])
    {
        countIndex ++ ;
        if(countIndex % 2 == 0)
        {
            runNext = YES;
        }
    }
    
    
    //    加载、下单、支付，密码编辑
    //    http://xyq.cbg.163.com/cgi-bin/equipquery.py?
    //    http://xyq.cbg.163.com/cgi-bin/usertrade.py?
    //    https://epay.163.com/cashier/standardCashier?
    //    https://epay.163.com/cashier/standardCashier?orderId=2017052410JY53633234
    
    //下单失败url
    //    http://xyq.cbg.163.com/cgi-bin/usertrade.py?obj_serverid=443&obj_equipid=2624458&device_id=59674f59680dc0a51d83a14276640b23&equip_refer=1&act=add_cross_buy_role_order
    
    //下单成功url
    //    http://xyq.cbg.163.com/cgi-bin/usertrade.py?act=cross_server_buy_order_info&orderid=5307231&new=1
    
    //点击付款  成功，但是有两次刷新，可能是重定向跳转
    //    https://epay.163.com/cashier/standardCashier?orderId=2017052412JY54556214
    
    
    
    //成功，调用下一次
    if(runNext)
    {
        [self checkAndFinishLatestJSFunction];
    }
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
