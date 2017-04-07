//
//  CBGDetailWebView.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGDetailWebView.h"
@interface CBGDetailWebView()
@property (nonatomic, strong) NSDate * finishDate;
@property (nonatomic, copy) NSString * detailUrl;
@end

@implementation CBGDetailWebView

//+(instancetype)sharedInstance
//{
//    static CBGDetailWebView *shareZWDetailCheckManagerInstance = nil;
//    static dispatch_once_t token;
//    dispatch_once(&token, ^{
//        shareZWDetailCheckManagerInstance = [[[self class] alloc] initWithFrame:CGRectMake(0, FLoatChange(65), SCREEN_WIDTH, SCREEN_HEIGHT -FLoatChange(65))];
//    });
//    return shareZWDetailCheckManagerInstance;
//}

-(id)initDetailWebViewWithDetailString:(NSString *)url
{
    self = [super init];
    if(self){
        [self refreshCBGDetailWebViewDetailUrlString:url];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cancelWebViewLatestLoad)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
    }
    return self;
}

-(void)refreshCBGDetailWebViewDetailUrlString:(NSString *)urlStr
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state == UIApplicationStateBackground){
        return;
    }
    
    
    NSURL * url = [NSURL URLWithString:urlStr];
    
    if(!url) return;
    if([self.detailUrl isEqualToString:urlStr]) return;
    NSTimeInterval count = [self.finishDate timeIntervalSinceNow];
    if(count > 0) return;
    self.finishDate = [NSDate dateWithTimeIntervalSinceNow:20];//20s内部刷新
    self.detailUrl = urlStr;
    
    
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self loadRequest:request];

}
-(void)cancelWebViewLatestLoad
{
    self.delegate = nil;
    [self stopLoading];

}
//-(void)listenToListDataForPlanBuy
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(planBuyExchangeForDetailUrlPreUpload:)
//                                                 name:NOTIFICATION_NEED_PLAN_BUY_REFRESH_STATE
//                                               object:nil];
//}
//-(void)planBuyExchangeForDetailUrlPreUpload:(NSNotification *)noti
//{
//    self.delegate = nil;
//    NSString * urlStr = noti.object;
//    NSURL * url = [NSURL URLWithString:urlStr];
//    
//    if(!url) return;
//    if([self.detailUrl isEqualToString:urlStr]) return;
//    NSTimeInterval count = [self.finishDate timeIntervalSinceNow];
//    if(count > 0) return;
//    self.finishDate = [NSDate dateWithTimeIntervalSinceNow:20];//20s内部刷新
//    self.detailUrl = urlStr;
//    
//    
//    NSURLRequest *request =[NSURLRequest requestWithURL:url];
//    [self loadRequest:request];
//    
////    __weak typeof(self)  weakSelf = self;
////    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
////        NSURLRequest *request =[NSURLRequest requestWithURL:url];
////        [weakSelf loadRequest:request];
////    });
//
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
