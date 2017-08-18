//
//  ZWServerRefreshAutoEquipVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/4.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWServerRefreshAutoEquipVC.h"
#import "ZWServerEquipModel.h"
#import "ZALocationLocalModel.h"
#import "ZWServerEquipServerSelectedVC.h"
#import "OpenTimesRefreshManager.h"
#import "ServerEquipIdRequestModel.h"
#import "EquipDetailArrayRequestModel.h"
#import <WebKit/WKWebView.h>
@interface ZWServerRefreshAutoEquipVC ()<UIWebViewDelegate>
{
    BaseRequestModel * _detailListReqModel;
}
@property (nonatomic,strong) UIWebView * showWeb;
@property (nonatomic,strong) ZWServerEquipModel * serverEquip;
@property (nonatomic,strong) UIButton * refreshBtn;

@property (nonatomic,strong) UIButton * saveBtn;
@property (nonatomic,strong) UIButton * payBtn;

@property (nonatomic,strong) UIButton * preEquipBtn;
@property (nonatomic,strong) UIButton * nextEquipBtn;
@property (nonatomic,strong) UIButton * copyBtn;
@property (nonatomic,strong) UIButton * copyOutBtn;
@property (nonatomic,assign) BOOL autoRefresh;
@property (nonatomic,assign) BOOL autoChecking;
@property (nonatomic,assign) NSInteger checkMaxNum; //作为检查目标
@property (nonatomic,assign) NSInteger waitingNum;
//检查出结果后，检查waitingNum区间内的商品，依次递减，当不在区间内，改变checkMaxNum，重新检查
@property (nonatomic,assign) NSInteger repeatNum;
@property (nonatomic,strong) NSDate * retryDate;//自动刷新时间倒计时   5s后自动刷新
@property (nonatomic,assign) BOOL timerRefresh;
@end

@implementation ZWServerRefreshAutoEquipVC
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self =[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.waitingNum = 20;
        self.checkMaxNum = 0;
    }
    return self;
}
-(UIButton *)copyOutBtn
{
    if(!_copyOutBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"导出" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor greenColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(0, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnCopyOutWithSender:) forControlEvents:UIControlEventTouchUpInside];
        self.copyOutBtn = btn;
    }
    return _copyOutBtn;
}

-(UIButton *)copyBtn
{
    if(!_copyBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"复制" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor greenColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(0, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnCopyEquipPageWithSender:) forControlEvents:UIControlEventTouchUpInside];
        self.copyBtn = btn;
    }
    return _copyBtn;
}

-(UIButton *)preEquipBtn
{
    if(!_preEquipBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"上一页" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor greenColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(0, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnShowPreEquipPageWithSender:) forControlEvents:UIControlEventTouchUpInside];
        self.preEquipBtn = btn;
    }
    return _preEquipBtn;
}
-(UIButton *)nextEquipBtn
{
    if(!_nextEquipBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"下一页" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor greenColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(0, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnShowNextEquipPageWithSender:) forControlEvents:UIControlEventTouchUpInside];
        self.nextEquipBtn = btn;
    }
    return _nextEquipBtn;
}
-(void)tapedOnCopyOutWithSender:(id)sender
{
    if(!self.serverEquip.orderSN)
    {
        [DZUtils noticeCustomerWithShowText:@"未获取编号"];
        [self tapedOnLocalDBSaveBtn:nil];
        return;
    }
    
    NSString * nextUrl = self.serverEquip.detailDataUrl;

    if(!nextUrl) return;
    UIPasteboard * board = [UIPasteboard generalPasteboard];
    board.string = nextUrl;
}
-(void)tapedOnCopyEquipPageWithSender:(id)sender
{
    NSString * nextUrl = [self latestWebRequestUrlWithSelectedServerId];
    
    if(!nextUrl) return;
    UIPasteboard * board = [UIPasteboard generalPasteboard];
    board.string = nextUrl;

}
-(void)tapedOnShowPreEquipPageWithSender:(id)sender
{
    [self refreshShowNextPageBtnStyleWithNext:NO];
}
-(void)tapedOnShowNextEquipPageWithSender:(id)sender
{
    [self refreshShowNextPageBtnStyleWithNext:YES];
}


-(UIButton *)refreshBtn
{
    if(!_refreshBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"停止" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor blueColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(SCREEN_WIDTH - btnWidth * 2- 1, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnRefreshWebViewBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.refreshBtn = btn;
    }
    return _refreshBtn;
}
-(UIButton *)saveBtn
{
    if(!_saveBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"检查" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor blueColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(SCREEN_WIDTH - btnWidth * 2- 1, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnLocalDBSaveBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.saveBtn = btn;
    }
    return _saveBtn;
}
-(void)tapedOnRefreshWebViewBtn:(id)sender
{
    //控制开关
    self.autoRefresh = !self.autoRefresh;
    [self refreshShowRefreshBtnStyleWithRefresh:self.autoRefresh];
    
    if(self.autoRefresh)
    {
        [self checkAndRefreshMaxCheckNumber];
        NSString * nextUrl = [self latestWebRequestUrlWithSelectedServerId];
        [self refreshWebViewWithLatestReqeustUrl:nextUrl];
    }else
    {
        self.checkMaxNum = 0;
    }
}
-(void)tapedOnLocalDBSaveBtn:(id)sender
{
    NSString * nextUrl = [self latestWebRequestUrlWithSelectedServerId];
    [self refreshWebViewWithLatestReqeustUrl:nextUrl];
    
}
-(UIButton *)payBtn
{
    if(!_payBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"支付" forState:UIControlStateNormal];
        [btn setTitle:@"问题" forState:UIControlStateDisabled];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateDisabled];
        [btn setBackgroundColor:[UIColor greenColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(SCREEN_WIDTH - btnWidth, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnPayBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.payBtn = btn;
    }
    return _payBtn;
}
-(void)tapedOnPayBtn:(id)sender
{
    if(!self.serverEquip.orderSN)
    {
        [DZUtils noticeCustomerWithShowText:@"未获取编号"];
        [self tapedOnLocalDBSaveBtn:nil];
        return;
    }
    
    NSString * urlString = self.serverEquip.mobileAppDetailShowUrl;
    
    NSURL *appPayUrl = [NSURL URLWithString:urlString];
    
    if([[UIApplication sharedApplication] canOpenURL:appPayUrl])
    {
        [[UIApplication sharedApplication] openURL:appPayUrl];
    }
    
}
-(void)startLocationDataRequest
{
//    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    
    ZALocation * locationInstance = [ZALocation sharedInstance];
    [locationInstance startLocationRequestUserAuthorization];
    __weak typeof(self) weakSelf = self;
    
    
    [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *location){
        [weakSelf backLocationDataWithString:location];
    }];
}
-(void)backLocationDataWithString:(id)obj
{
    //    NSLog(@"%s",__FUNCTION__);
    
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
    if(manager.isRefreshing) return;
    [self startOpenTimesRefreshTimer];
}

-(void)startOpenTimesRefreshTimer
{
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    //    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger time = 3;
    //    if(total.refreshTime && [total.refreshTime intValue]>0){
    //        time = [total.refreshTime intValue];
    //    }
    manager.refreshInterval = time;
    manager.functionInterval = time;
    manager.funcBlock = ^()
    {
        
#if TARGET_IPHONE_SIMULATOR
//        [weakSelf performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
//                                   withObject:nil
//                                waitUntilDone:NO];
#else
//        [weakSelf performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
//                                   withObject:nil
//                                waitUntilDone:NO];
        [weakSelf performSelectorOnMainThread:@selector(checkAndRefreshFinishDateForAutoRefresh)
                                            withObject:nil
                                         waitUntilDone:NO];
#endif
    };
    [manager saveCurrentAndStartAutoRefresh];
}
-(void)checkAndRefreshFinishDateForAutoRefresh
{
    if(self.autoRefresh && self.checkMaxNum > 0 ){
        NSInteger equipId = self.serverEquip.equipId ;
        if(equipId > self.checkMaxNum - self.waitingNum && equipId < self.checkMaxNum)
        {
            NSTimeInterval count = [self.retryDate timeIntervalSinceNow];
            if(count < 0 )
            {
                self.timerRefresh = YES;
                NSString * nextUrl = [self latestWebRequestUrlWithSelectedServerId];
                [self refreshWebViewWithLatestReqeustUrl:nextUrl];
                
                [self tapedOnCopyEquipPageWithSender:nil];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSDictionary * serNameDic = total.serverNameDic;
    NSInteger serverId = total.refreshServerId;
    if(serverId == 0){
        serverId = 33;//蓬莱岛
        total.refreshServerId = serverId;
        [total localSave];
    }
    NSString * serverName = [serNameDic objectForKey:[NSNumber numberWithInteger:serverId]];
    self.showLeftBtn = YES;
    self.showRightBtn = YES;
    self.viewTtle = serverName;
    self.rightTitle = @"设置";
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, FLoatChange(65), SCREEN_WIDTH, SCREEN_HEIGHT -FLoatChange(65))];
    [self.view addSubview:webView];
    self.showWeb = webView;
    webView.delegate = self;
    //    http://115.159.68.180:8080/sdbt/about.html

    UIView * bgView = self.view;
    CGFloat boundHeight = self.payBtn.bounds.size.height;
    [bgView addSubview:self.payBtn];
    
    CGPoint pt = CGPointZero;
    pt.y = SCREEN_HEIGHT - boundHeight/2.0;
    pt.x = SCREEN_WIDTH - self.payBtn.bounds.size.width/2.0;
    self.payBtn.center = pt;
    
    pt.y -= boundHeight;
    [bgView addSubview:self.saveBtn];
    self.saveBtn.center = pt;
    
    pt.y -= boundHeight;
    [bgView addSubview:self.refreshBtn];
    self.refreshBtn.center = pt;
    
    
    pt.y = SCREEN_HEIGHT - boundHeight/2.0;
    pt.x = self.nextEquipBtn.bounds.size.width/2.0;
    [bgView addSubview:self.nextEquipBtn];
    self.nextEquipBtn.center = pt;
    
    pt.y -= boundHeight;
    [bgView addSubview:self.preEquipBtn];
    self.preEquipBtn.center = pt;

    pt.y -= boundHeight;
    [bgView addSubview:self.copyBtn];
    self.copyBtn.center = pt;

    
    self.autoRefresh = NO;
}

-(void)refreshShowRefreshBtnStyleWithRefresh:(BOOL)refresh
{
    NSString * title = refresh?@"自动":@"停止";
    [self.refreshBtn setTitle:title forState:UIControlStateNormal];
}
-(void)refreshShowNextPageBtnStyleWithNext:(BOOL)next
{//手动的触发后，无效
    if(self.autoChecking) return;
    if(self.autoRefresh)
    {
        self.autoRefresh = NO;
        self.checkMaxNum = 0;
        [self refreshShowRefreshBtnStyleWithRefresh:self.autoRefresh];
    }
    
    //下一页、上一页
    NSInteger nxtPage = next?1:-1;
    self.serverEquip.equipId += nxtPage;
    
    NSString * webUrl = [self latestWebRequestUrlWithSelectedServerId];
    [self refreshWebViewWithLatestReqeustUrl:webUrl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshLocalEquipServerModel];
    [self startLocationDataRequest];
}
-(void)refreshLocalEquipServerModel
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger serverId = total.refreshServerId;
    if(serverId != self.serverEquip.serverId)
    {
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        NSArray * equipArr = [dbManager localSaveEquipServerMaxEquipIdAndServerIdList];
        for (NSInteger index = 0;index < [equipArr count] ;index ++ )
        {
            ZWServerEquipModel * eve = [equipArr objectAtIndex:index];
            if(eve.serverId == serverId)
            {
                self.serverEquip = eve;
            }
        }
        
        if(!self.serverEquip)
        {
            ZWServerEquipModel * eve1 = [[ZWServerEquipModel alloc] init];
            eve1.equipId = 2281755;
            eve1.serverId = 33;
            self.serverEquip = eve1;
        }
        
        NSString * webUrl = [self latestWebRequestUrlWithSelectedServerId];
        [self refreshWebViewWithLatestReqeustUrl:webUrl];
    }
}


-(void)refreshWebViewWithLatestReqeustUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    
    [self.showWeb loadRequest:request];
}
-(void)checkAndRefreshMaxCheckNumber
{
    ZWServerEquipModel * server = self.serverEquip;
    if(self.checkMaxNum  == 0)
    {
        self.checkMaxNum = server.equipId + 1;
        server.equipId = self.checkMaxNum;
    }else if(server.equipId < (self.checkMaxNum - self.waitingNum))
    {//开心新的检查
        self.checkMaxNum += self.waitingNum;//重置检查目标
        server.equipId = self.checkMaxNum;
    }
}

-(NSString *)latestWebRequestUrlWithSelectedServerId
{
    ZWServerEquipModel * server = self.serverEquip;
    NSString * urlString = [NSString stringWithFormat:@"http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=buy_show_equip_info&equip_id=%ld&server_id=%ld&from=game",server.equipId,server.serverId];
    return urlString;
}

-(void)submit
{
    ZWServerEquipServerSelectedVC * select = [[ZWServerEquipServerSelectedVC alloc] init];
    [[self rootNavigationController] pushViewController:select animated:YES];
}
-(void)checkAndRefreshLocalWebCookieRefresh:(BOOL)refresh
{
    NSString * cookieName = @"latest_views";
    NSHTTPCookie * editCookie = nil;
    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookiesArray)
    {
        if([cookie.name isEqualToString:cookieName])
        {
            editCookie = cookie;
            break;
        }
    }
    
    if(editCookie)
    {
        NSString * editValue = editCookie.value;
        NSArray * arr = [editValue componentsSeparatedByString:@"-"];
        if([arr count] >1)
        {
            NSString * editRefresh = [arr lastObject];
            if(!refresh) {editRefresh = [arr firstObject];}
            
            NSDictionary * preDic = [editCookie properties];
            NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
            [cookieProperties addEntriesFromDictionary:preDic];
            [cookieProperties setObject:editRefresh forKey:NSHTTPCookieValue];
            
            NSHTTPCookie *refreshCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
            //            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:editCookie];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:refreshCookie];
        }
    }
}
-(NSString *)randomSid
{
    
    NSString * orderString = [NSString stringWithFormat:@"DFAFDASF2DS-1BFF-4B8E-9970-9823HFSF823FSD8%@%ld",[NSDate unixDate],index];
    NSString * md5Str = [orderString MD5String];
    
    orderString = [orderString stringByAppendingString:@"再来"];
    NSString * nexMd5 = [orderString MD5String];
    
    NSMutableString * total = [NSMutableString string];
    [total appendString:md5Str];
    [total appendString:nexMd5];
    
    for (NSInteger index = 0;index < [total length] ; index++)
    {
        NSInteger randNum = arc4random() % 100;
        if(randNum % 3 == 0)
        {
            NSRange  range = NSMakeRange(index, 0);
            NSString * subStr = [total substringWithRange:range];
            [total replaceCharactersInRange:range withString:[subStr lowercaseString]];
        }
    }
    
    NSString * compareStr = @"jrrfNEOND39xFYsTga5omd2DJEdR5N_lUViPO2Wt";
    NSArray * arr = [compareStr componentsSeparatedByString:@"_"];
    
    NSInteger startIndex = 0;
    for (NSInteger index = 0; index < [arr count] ;index ++ )
    {
        NSInteger eveIndex = [[arr objectAtIndex:index] length];
        startIndex += eveIndex;
        [total insertString:@"_" atIndex:startIndex];
        startIndex += 1;
    }
    NSString * result = [total substringWithRange:NSMakeRange(0, [compareStr length])];
    return result;
}
-(void)exchangeAutoServerSidWithLatestRandomSid:(NSString *)rand
{
    if(!rand) return;
    NSString * cookieName = @"sid";
    NSHTTPCookie * editCookie = nil;
    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookiesArray)
    {
        if([cookie.name isEqualToString:@"sid"])
        {
        }
        if([cookie.name isEqualToString:cookieName])
        {
            editCookie = cookie;
            break;
        }
    }
    
    if(editCookie)
    {
        NSString * editValue = editCookie.value;
        if([editValue length] >1)
        {
            NSDictionary * preDic = [editCookie properties];
            NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
            [cookieProperties addEntriesFromDictionary:preDic];
            
            [cookieProperties setObject:rand forKey:NSHTTPCookieValue];
            
            NSHTTPCookie *refreshCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:editCookie];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:refreshCookie];
        }
    }
}
-(void)clearServerRequestCookieForSidRefresh
{
    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookiesArray)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }

}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * nextUrl = request.URL.absoluteString;
    NSLog(@"nextUrl %@",nextUrl);
    //启动倒计时时间
    
    if(self.autoRefresh){
        self.retryDate = [NSDate dateWithTimeIntervalSinceNow:10];
    }
    
    return YES;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.timerRefresh = NO;
    self.retryDate = nil;
    NSString * nextUrl = [webView request].URL.absoluteString;
    NSLog(@"webViewDidFinishLoad %@",nextUrl);
    if(nextUrl){
        
    }
    
    [self checkAndStartedNextEquipWebRequest];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSString * nextUrl = [webView request].URL.absoluteString;
    NSLog(@"didFailLoadWithError %@",nextUrl);
    if(!self.timerRefresh){//针对timer启动的刷新，错误时不进行终止操作
        self.retryDate = nil;
    }
    
//    [DZUtils noticeCustomerWithShowText:@"加载失败"];
    
    if(self.autoRefresh)
    {
//        [self clearServerRequestCookieForSidRefresh];
//        self.retryDate = [NSDate date];
    }

}
-(void)checkAndStartedNextEquipWebRequest
{

    NSString * runJs = @"window.document.getElementById('equip_desc_value').value;";
    NSString * result = [self.showWeb stringByEvaluatingJavaScriptFromString:runJs];
    
    NSString * petJs = @"window.document.getElementById('pet_desc').value;";
    NSString * petResult = [self.showWeb stringByEvaluatingJavaScriptFromString:petJs];
    
    NSString * nonePrjJS =@"window.document.getElementsByClassName('cDYellow tips').length;";
    NSString * nonePrjResult = [self.showWeb stringByEvaluatingJavaScriptFromString:nonePrjJS];

    NSString * randJs =@"window.document.getElementsByClassName('txt1').length;";
    NSString * randResult = [self.showWeb stringByEvaluatingJavaScriptFromString:randJs];

    NSString * orderSNJS =@"equip.game_ordersn;";
    NSString * orderSN = [self.showWeb stringByEvaluatingJavaScriptFromString:orderSNJS];

    NSString * equipNameJS =@"equip.equip_name;";
    NSString * equipName = [self.showWeb stringByEvaluatingJavaScriptFromString:equipNameJS];

    
    if([orderSN length] > 0)
    {
        self.serverEquip.orderSN = orderSN;
    }
    
    //纯id数据、标识为角色，进行详情请求，发现角色，进行角色详情请求
    if([equipName integerValue] > 100)
    {
        NSString * detailWeb = self.serverEquip.detailDataUrl;
        [self startEquipDetailAllRequestWithUrls:@[detailWeb]];
        
        self.autoChecking = YES;
//        self.autoRefresh = NO;
//        [self refreshShowRefreshBtnStyleWithRefresh:self.autoRefresh];
    }
    
    if(!self.autoRefresh || self.autoChecking) return;
    
    if([result length] > 0 || [petResult length]> 0)
    {
        self.repeatNum = 0;
        [self checkAndRefreshLocalWebCookieRefresh:YES];
        [self startNextEquipPageLoadAndRefresh];
//        ZWServerEquipModel * server = self.serverEquip;
//        server.equipId ++;
//        server.detail = nil;
//        server.equipDesc = nil;
//        server.orderSN = nil;
//        
//        NSString * nextUrl = [self latestWebRequestUrlWithSelectedServerId];
//        [self refreshWebViewWithLatestReqeustUrl:nextUrl];
    }
    else if([nonePrjResult integerValue] > 0)
    {
        self.repeatNum ++ ;
        [self clearServerRequestCookieForSidRefresh];
        NSInteger randNum = arc4random() % 20 + 10;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randNum * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSString * sid = [self randomSid];
//            [self exchangeAutoServerSidWithLatestRandomSid:sid];
            NSString * nextUrl = [self latestWebRequestUrlWithSelectedServerId];
            [self refreshWebViewWithLatestReqeustUrl:nextUrl];
        });
    }else if([randResult integerValue] > 0){
        //停止刷新，等待
        [self checkAndRefreshLocalWebCookieRefresh:NO];
        self.autoRefresh = !self.autoRefresh;
        [self refreshShowRefreshBtnStyleWithRefresh:self.autoRefresh];
    }

}
-(void)startNextEquipPageLoadAndRefresh
{
    ZWServerEquipModel * server = self.serverEquip;
    NSInteger equipId = server.equipId;
    if(equipId <= self.checkMaxNum - self.waitingNum)
    {//到达最后一个检查标识
        self.checkMaxNum += self.waitingNum;//重置检查目标
        server.equipId = self.checkMaxNum;
        equipId = server.equipId;
    }else if(equipId <= self.checkMaxNum)
    {
        equipId --;
    }

    server.equipId =  equipId;
    server.detail = nil;
    server.equipDesc = nil;
    server.orderSN = nil;
    
    NSString * nextUrl = [self latestWebRequestUrlWithSelectedServerId];
    [self refreshWebViewWithLatestReqeustUrl:nextUrl];

}


-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
    NSLog(@"%s",__FUNCTION__);
    
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(!model){
        model = [[EquipDetailArrayRequestModel alloc] init];
        [model addSignalResponder:self];
        _detailListReqModel = model;
    }
    
    if(model.executing) return;
    
    [model refreshWebRequestWithArray:array];
    [model sendRequest];
    
}

#pragma mark EquipDetailArrayRequestModel
handleSignal( EquipDetailArrayRequestModel, requestError )
{
    self.autoChecking = NO;
    if(self.autoRefresh)
    {
        [self startNextEquipPageLoadAndRefresh];
    }
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
handleSignal( EquipDetailArrayRequestModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

handleSignal( EquipDetailArrayRequestModel, requestLoaded )
{
    [self hideLoading];
    NSLog(@"%s",__FUNCTION__);
    self.autoChecking = NO;
    
    //进行存储操作、展示
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *) _detailListReqModel;
    NSArray * total  = model.listArray;
    if([total count] > 0){
        NSArray * detailArr = [total lastObject];
        if([detailArr count] > 0)
        {
            EquipModel * detail = [detailArr lastObject];
            
            ZWServerEquipModel * server = self.serverEquip;
            server.detail = detail;
            server.equipDesc = detail.equip_desc;
            server.orderSN = detail.game_ordersn;
            
            
            CBGListModel * list = detail.listSaveModel;
            list.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;
            if([list preBuyEquipStatusWithCurrentExtraEquip])
            {
                NSString * webUrl = list.mobileAppDetailShowUrl;
                [DZUtils startNoticeWithLocalUrl:webUrl];
                NSURL * appPayUrl = [NSURL URLWithString:webUrl];
                
                if([[UIApplication sharedApplication] canOpenURL:appPayUrl]  &&
                   [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
                {
                    [[UIApplication sharedApplication] openURL:appPayUrl];
                }
            }
            
            ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
            [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:@[list]];
            
            if(self.autoRefresh){
                [self startNextEquipPageLoadAndRefresh];
            }
        }
    }

}


//-(void)startRefreshDataModelRequest
//{
//    if(![DZUtils deviceWebConnectEnableCheck])
//    {
//        return;
//    }
//    
//    if(!self.autoRefresh) return;
//    
//    ServerEquipIdRequestModel * listRequest = (ServerEquipIdRequestModel *)_dpModel;
//    if(listRequest.executing) return;
//    
//    if(!self.serverEquip) return;
//    
//    NSArray * server = @[self.serverEquip];
//    if([server count] == 0) return;
//
//    
//    NSString * webUrl = [self latestWebRequestUrlWithSelectedServerId];
//    [self refreshWebViewWithLatestReqeustUrl:webUrl];
//    
//    NSLog(@"%s",__FUNCTION__);
//    
//    ServerEquipIdRequestModel * model = (ServerEquipIdRequestModel *)_dpModel;
//    
//    if(!model){
//        //model重建，仅界面消失时出现，执行时不处于请求中
//        model = [[ServerEquipIdRequestModel alloc] init];
//        [model addSignalResponder:self];
//        _dpModel = model;
//        
//        /*
//         if(self.totalPageNum >= 3)
//         {
//         [self refreshLatestListRequestModelWithSmallList:YES];
//         }
//         if(self.maxRefresh)
//         {
//         model.pageNum = 100;
//         }
//         */
//    }
//    
//    model.saveCookie = YES;
//    model.serverArr = server;
//    model.timerState = !model.timerState;
//    [model sendRequest];
//}
//#pragma mark ServerEquipIdRequestModel
//handleSignal( ServerEquipIdRequestModel, requestError )
//{
//    [self hideLoading];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    if(self.autoRefresh)
//    {
//        [self startRefreshDataModelRequest];
//    }
//
//    
//}
//handleSignal( ServerEquipIdRequestModel, requestLoading )
//{
//    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
//    if(state != UIApplicationStateActive){
//        return;
//    }
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    //    [self showLoading];
//}
//
//
//handleSignal( ServerEquipIdRequestModel, requestLoaded )
//{
//    [self hideLoading];
//    
//    ServerEquipIdRequestModel * model = (ServerEquipIdRequestModel *)_dpModel;
//    NSArray * total  = model.listArray;
//    if([total count] > 0)
//    {
//        NSArray * objArr = [total lastObject];
//        if([objArr isKindOfClass:[NSArray class]] && [objArr count] > 0)
//        {
//            EquipModel * detail = [objArr lastObject];
//            if(detail.resultType == ServerResultCheckType_Success)
//            {
//                ZWServerEquipModel * server = self.serverEquip;
//                if(server.detail.resultType == ServerResultCheckType_Success)
//                {
//                    server.equipId ++;
//                    
//                    server.detail = nil;
//                    server.equipDesc = nil;
//                }
//            }
//        }
//    }
//    
//    if(self.autoRefresh)
//    {
//        [self startRefreshDataModelRequest];
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
