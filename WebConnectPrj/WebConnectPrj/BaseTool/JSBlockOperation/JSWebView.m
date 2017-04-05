//
//  JSWebView.m
//  WebConnectPrj
//
//  Created by Apple on 14-11-20.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "JSWebView.h"
@interface JSWebView()<UIWebViewDelegate>
@end
@implementation JSWebView

-(void)loadWebHtml:(NSString *)str
{
    self.delegate =self;
    NSString * localHTML = [self loadHtmlStringFromWebHtmlString:str];
    NSString *path=[[NSBundle mainBundle]bundlePath];
    NSURL * baseURL=[[NSURL alloc]initFileURLWithPath:path];
    [self loadHTMLString:localHTML baseURL:baseURL];
}
-(NSString * )loadHtmlStringFromWebHtmlString:(NSString *)str
{
    NSMutableString * htmlStr = [NSMutableString stringWithString:str];
    NSString * head = @"<head>";
    
    //去掉无关的js的引入<script>
    NSString * regEx = @"<script.*?/script>";
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:regEx options:NSRegularExpressionCaseInsensitive error:nil];
    if (regex != nil)
    {
        NSArray * array = [regex matchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length])];
        for (int i=[array count]-1;i--;i>=0)
        {
            NSTextCheckingResult * eveResult = [array objectAtIndex:i];
            NSLog(@"replacementString %@",[htmlStr substringWithRange:eveResult.range]);
            [htmlStr replaceCharactersInRange:eveResult.range withString:@""];
        }
    }
    
    NSRange  range = [htmlStr rangeOfString:head];
    if (range.location!=NSNotFound)
    {
        NSMutableString * resultStr = [NSMutableString string];
        //导入两行js，
        [resultStr appendString:@"<script type=\"text/javascript\" src=\"jquery.js\"></script>"];
        [resultStr appendString:@"<script type=\"text/javascript\" src=\"blogDetail.js\"></script>"];
        
        NSInteger index = range.location+[head length];
        [htmlStr insertString:resultStr atIndex:index];
    }
    return htmlStr;
}
-(void)finishedWithArr:(NSArray *)arr
{
    if (self.endJSOperationBlcok)
    {
        self.endJSOperationBlcok(arr);
    }
}
-(NSArray *)imageUrlArrayFromJsonFunction:(NSString *)functionStr
{
    //调用js方法，计算当前图片数组
    NSString * resultStr = [self stringByEvaluatingJavaScriptFromString:functionStr];
    NSLog(@"js %@ result %@",functionStr,resultStr);
    NSArray * arr = [NSArray array];
    if (resultStr&&[resultStr length]>0)
    {
        arr =  [resultStr componentsSeparatedByString:@"|"];
    }
    return arr;
}
#pragma mark UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //运行js方法
    NSString * functionStr = @"getAllImgSrc()";
    NSString * secondStr = @"getAllImgSrcContent()";
    NSArray * arr = [self imageUrlArrayFromJsonFunction:functionStr];
    if (arr) {
        arr = [self imageUrlArrayFromJsonFunction:secondStr];
    }
    
    [self finishedWithArr:arr];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{

    [self finishedWithArr:nil];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
