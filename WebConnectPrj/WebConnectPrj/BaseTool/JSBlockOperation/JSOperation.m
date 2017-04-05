//
//  JSOperation.m
//  WebConnectPrj
//
//  Created by Apple on 14-11-20.
//  Copyright (c) 2014年 zhangchaoqun. All rights reserved.
//

#import "JSOperation.h"
#import "AppDelegate.h"
@interface JSOperation()<UIWebViewDelegate>
{
    UIWebView * web;
    
}
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (strong, atomic) NSThread *thread;
@property (nonatomic,copy) NSString * htmlStr;
@end
@implementation JSOperation
@synthesize executing = _executing;
@synthesize finished = _finished;


-(id)initWithHTMLString:(NSString *)str andWeb:(UIWebView *)aWeb
{
    self =[super init];
    if (self) {
        _executing = NO;
        _finished = NO;
        self.htmlStr = str;
        web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        web.delegate = self;
        
        AppDelegate * app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.window addSubview:web];
    }
    return self;
}
-(NSString * )loadHtmlStringFromWebHtmlString:(NSString *)str
{
    NSMutableString * htmlStr = [NSMutableString stringWithString:str];
    NSString * head = @"<head>";
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

- (void)start {
    @synchronized (self)
    {
        if (self.isCancelled)
        {
            self.finished = YES;
            [self reset];
            return;
        }
        
        self.executing = YES;
        if (!self.htmlStr||[self.htmlStr length]==0)
        {
            [self finishedWithArr:nil];
            [self done];
            return;
        }
        
        self.thread = [NSThread currentThread];
        NSString * localHTML = [self loadHtmlStringFromWebHtmlString:self.htmlStr];
        NSString *path=[[NSBundle mainBundle]bundlePath];
        NSURL * baseURL=[[NSURL alloc]initFileURLWithPath:path];
        [web loadHTMLString:localHTML baseURL:baseURL];
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
            // Make sure to run the runloop in our background thread so it can process downloaded data
            // Note: we use a timeout to work around an issue with NSURLConnection cancel under iOS 5
            //       not waking up the runloop, leading to dead threads (see https://github.com/rs/SDWebImage/issues/466)
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, false);
        }
        else {
            CFRunLoopRun();
        }
    }
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}
- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}
- (void)cancel {
    [self done];
}
- (void)reset {
    
    self.endJSOperationBlcok = nil;
    self.completionBlock = nil;
    self.thread = nil;
}
- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}
- (BOOL)isConcurrent {
    return YES;
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
    NSString * resultStr = [web stringByEvaluatingJavaScriptFromString:functionStr];
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
    @synchronized(self) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.thread = nil;
    }
    //运行js方法
    NSString * functionStr = @"getAllImgSrc()";
    NSString * secondStr = @"getAllImgSrcContent()";
    NSArray * arr = [self imageUrlArrayFromJsonFunction:functionStr];
    if (arr) {
        arr = [self imageUrlArrayFromJsonFunction:secondStr];
    }
    
    [self finishedWithArr:arr];
    [self done];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    CFRunLoopStop(CFRunLoopGetCurrent());
    [self finishedWithArr:nil];
    [self done];
}


@end
