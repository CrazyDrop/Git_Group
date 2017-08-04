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
@interface ZWServerRefreshAutoEquipVC ()<UIWebViewDelegate>
@property (nonatomic,strong) UIWebView * showWeb;
@property (nonatomic,strong) ZWServerEquipModel * serverEquip;
@property (nonatomic,strong) UIButton * refreshBtn;

@property (nonatomic,strong) UIButton * saveBtn;
@property (nonatomic,strong) UIButton * payBtn;

@property (nonatomic,strong) UIButton * preEquipBtn;
@property (nonatomic,strong) UIButton * nextEquipBtn;
@end

@implementation ZWServerRefreshAutoEquipVC
-(UIButton *)preEquipBtn
{
    if(!_preEquipBtn)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"上一页" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor blueColor]];
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
        [btn setBackgroundColor:[UIColor blueColor]];
        CGFloat btnWidth = 80;
        btn.frame = CGRectMake(0, 0, btnWidth, btnWidth);
        [btn addTarget:self
                action:@selector(tapedOnShowNextEquipPageWithSender:) forControlEvents:UIControlEventTouchUpInside];
        self.nextEquipBtn = btn;
    }
    return _nextEquipBtn;
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
        [btn setTitle:@"刷新" forState:UIControlStateNormal];
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
        [btn setTitle:@"保存" forState:UIControlStateNormal];
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
//    [self startRefreshDataModelRequest];
//    
//    NSString * urlString = self.cbgList.detailWebUrl;
//    if(!urlString) return;
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request =[NSURLRequest requestWithURL:url];
//    [self.showWeb loadRequest:request];
}

-(void)tapedOnLocalDBSaveBtn:(id)sender
{
    //进行数据刷新
//    if(!self.detailModel){
//        [DZUtils noticeCustomerWithShowText:@"详情不存在"];
//        return;
//    }
//    baseList.equipModel = self.detailModel;
//    
//    //强制刷新
//    [baseList refrehLocalBaseListModelWithDetail:self.detailModel];
//    
//    CBGListModel * cbgList = [baseList listSaveModel];
//    cbgList.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;
//    
//    NSArray * arr = @[cbgList];
//    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
//    [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:arr];
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
    pt.x = self.preEquipBtn.bounds.size.width/2.0;
    [bgView addSubview:self.preEquipBtn];
    self.preEquipBtn.center = pt;
    
    pt.y -= boundHeight;
    [bgView addSubview:self.nextEquipBtn];
    self.nextEquipBtn.center = pt;
    
}
-(void)refreshShowRefreshBtnStyleWithRefresh:(BOOL)refresh
{
    NSString * title = refresh?@"自动":@"停止";
    [self.refreshBtn setTitle:title forState:UIControlStateNormal];
}
-(void)refreshShowNextPageBtnStyleWithNext:(BOOL)next
{//手动的触发后，无效
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
-(NSString *)latestWebRequestUrlWithSelectedServerId
{
    NSString * urlString = [NSString stringWithFormat:@"http://xyq.cbg.163.com/cgi-bin/equipquery.py?act=buy_show_equip_info&equip_id=%ld&server_id=%ld&from=game",self.serverEquip.equipId,self.serverEquip.serverId];
    return urlString;
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
    ZWServerEquipServerSelectedVC * select = [[ZWServerEquipServerSelectedVC alloc] init];
    [[self rootNavigationController] pushViewController:select animated:YES];
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
