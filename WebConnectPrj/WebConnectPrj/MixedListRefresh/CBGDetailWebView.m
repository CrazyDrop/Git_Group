//
//  CBGDetailWebView.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGDetailWebView.h"
@interface CBGDetailWebView()
@property (nonatomic, strong) NSString * showUrl;
@property (nonatomic, strong) NSDate * finishDate;

@end

@implementation CBGDetailWebView

-(id)initWithFrame:(CGRect)frame
{
    self =  [super initWithFrame:frame];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cancelWebViewLatestLoad)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
    }
    return self;
}

-(void)prepareWebViewWithUrl:(NSString *)url
{
    [self refreshCBGDetailWebViewDetailUrlString:url];
}

-(void)refreshCBGDetailWebViewDetailUrlString:(NSString *)urlStr
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state == UIApplicationStateBackground){
        return;
    }
    
    
    NSURL * url = [NSURL URLWithString:urlStr];
    
    if(!url) return;
    if([self.showUrl isEqualToString:urlStr]) return;
    NSTimeInterval count = [self.finishDate timeIntervalSinceNow];
    if(count > 0) return;
    self.finishDate = [NSDate dateWithTimeIntervalSinceNow:20];//20s内部刷新
    self.showUrl = urlStr;
    
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self loadRequest:request];
    
}
-(void)cancelWebViewLatestLoad
{
    self.delegate = nil;
    [self stopLoading];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
