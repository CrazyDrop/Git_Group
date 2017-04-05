//
//  CBGDetailWebView.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGDetailWebView.h"

@implementation CBGDetailWebView

+(instancetype)sharedInstance
{
    static CBGDetailWebView *shareZWDetailCheckManagerInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareZWDetailCheckManagerInstance = [[[self class] alloc] initWithFrame:CGRectMake(0, FLoatChange(65), SCREEN_WIDTH, SCREEN_HEIGHT -FLoatChange(65))];
    });
    return shareZWDetailCheckManagerInstance;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        //增加监听
        [self listenToListDataForPlanBuy];
    }
    return self;
}
-(void)listenToListDataForPlanBuy
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(planBuyExchangeForDetailUrlPreUpload:)
                                                 name:NOTIFICATION_NEED_PLAN_BUY_REFRESH_STATE
                                               object:nil];
}
-(void)planBuyExchangeForDetailUrlPreUpload:(NSNotification *)noti
{
    self.delegate = nil;
    NSString * urlStr = noti.object;
    NSURL * url = [NSURL URLWithString:urlStr];
    
    if(!url) return;
    if([self.detaiUrl isEqualToString:urlStr]) return;
    self.detaiUrl = urlStr;
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self loadRequest:request];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
