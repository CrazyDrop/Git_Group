//
//  ZWServerEquipListVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/31.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWServerEquipListVC.h"
#import "ZWServerRefreshListVC.h"
#import "RefreshListCell.h"
#import "ZWDataDetailModel.h"
#import "RecorderTimeRefreshManager.h"
#import "RefreshDataModel.h"
#import "ZWHistoryListController.h"
#import "ZALocationLocalModel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ZALocation.h"
#import "ZWDetailCheckManager.h"
#import "RefreshListDataManager.h"
#import "SFHFKeychainUtils.h"
#import "RefreshListDataManager.h"
#import "MSAlertController.h"
#import "Equip_listModel.h"
#import "RefreshEquipListDataManager.h"
#import "RefreshEquipDetailDataManager.h"
#import "CBGEquipDetailRequestManager.h"
#import "ZACBGDetailWebVC.h"
#import "RefreshEquipListAllDataManager.h"
#import "ServerRefreshRequestModel.h"
#import "ServerEquipIdRequestModel.h"
#import "CBGNearHistoryVC.h"
#import "CBGDetailWebView.h"
#import "CBGPlanDetailPreShowWebVC.h"
#import "ZWServerEquipModel.h"
#import "ZWServerURLCheckVC.h"
#define MonthTimeIntervalConstant 60*60*24*(30)
@interface ZWServerEquipListVC ()<UITableViewDataSource,UITableViewDelegate,
RefreshCellCopyDelgate>
{
    BaseRequestModel * _detailListReqModel;
    BOOL showTotal;
    NSLock * requestLock;
    
}
//界面不消失，一直不重复大范围请求操作
@property (nonatomic,strong) NSArray * totalArr;
@property (nonatomic,assign) NSInteger latestNum;
@property (nonatomic,assign) NSInteger serverNum;

@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,copy) NSArray * dataArr;
@property (nonatomic,copy) NSArray * dataArr2;
@property (nonatomic,assign) BOOL latestContain;
@property (nonatomic,strong) id latest;
@property (nonatomic,strong) UIView * waitingTips;
@property (nonatomic,strong) UIView * randomTips;
@property (nonatomic,strong) UIView * networkTips;
@property (nonatomic,strong) NSArray * detailsArr;
@property (nonatomic,strong) NSArray * showArray;
@property (nonatomic,strong) NSArray * grayArray;

@property (nonatomic,assign) BOOL inWebRequesting;
@property (nonatomic,strong) CBGDetailWebView * planWeb;
@property (nonatomic,assign) BOOL forceRefresh;
@property (nonatomic,strong) NSDictionary * serNameDic;

@end

@implementation ZWServerEquipListVC
    
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.serverNum = 10;
        [self appendNotificationForRestartTimerRefreshWithActive];
        
        ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
        self.totalArr = [dbManager localSaveEquipServerMaxEquipIdAndServerIdList];
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        NSDictionary * serNameDic = total.serverNameDic;
        self.serNameDic = serNameDic;
        
        self.inWebRequesting = NO;
        requestLock = [[NSLock alloc] init];
        
        NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookiesArray)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    
    return self;
}
-(NSArray *)latestServerIdArr
{
    NSArray * allArr = self.totalArr;
    if(!allArr || [allArr count] == 0) return nil;
    
    NSInteger startIndex = self.latestNum;
    NSInteger endIndex = 0;
    if(self.serverNum >= [allArr count])
    {
        startIndex = 0;
        endIndex = [allArr count] ;
    }else{
        if([allArr count] <= startIndex){
            startIndex = 0;
        }
        
        endIndex = self.latestNum  + self.serverNum;
        if([allArr count] <= endIndex)
        {
            endIndex = [allArr count] ;
            self.latestNum = 0;
        }else
        {
            self.latestNum = endIndex;
        }
    }
    
    
    NSArray * part = [allArr subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
    NSMutableArray * data = [NSMutableArray array];
    [data addObjectsFromArray:part];
    return data;
}
    
-(void)appendNotificationForRestartTimerRefreshWithActive
{
    //    UIApplicationDidBecomeActiveNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkLatestVCAndStartTimer)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}
-(void)checkLatestVCAndStartTimer
{
    NSArray * arr = [[self rootNavigationController] viewControllers];
    if([arr count] > 0){
        UIViewController * vc = [arr lastObject];
        
        if([vc isKindOfClass:[self class]]){
            [self startLocationDataRequest];
        }
    }
}
    
    
-(void)checkListInputForNoticeWithArray:(NSArray *)array
{
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(!model.isAlarm){
        return;
    }
    
    NSInteger compareId = model.minServerId;
    CBGListModel * maxCBGModel = nil;
    Equip_listModel * maxModel = nil;
    CGFloat maxRate = 0;
    for (NSInteger index = 0; index < [array count]; index ++)
    {
        Equip_listModel * list = [array objectAtIndex:index];
        CBGListModel * cbgList = [list listSaveModel];
        
        BOOL equipBuy = [cbgList preBuyEquipStatusWithCurrentExtraEquip];
        if(equipBuy && cbgList.server_id  < compareId)
        {
            CBGEquipRoleState state = cbgList.latestEquipListStatus;
            BOOL unSold = ( state == CBGEquipRoleState_InSelling|| state == CBGEquipRoleState_InOrdering || state == CBGEquipRoleState_unSelling);
            CGFloat rate = cbgList.plan_rate;
            if(unSold && rate >= maxRate){
                maxRate = rate;
                maxModel = list;
                maxCBGModel = cbgList;
            }
        }
    }
    
    //进行提醒
    if(maxCBGModel)
    {
        
        NSLog(@"%s %@",__FUNCTION__,maxCBGModel.game_ordersn);
        NSString * webUrl = maxCBGModel.detailWebUrl;
        NSString * urlString = webUrl;
        
        NSString * param = [NSString stringWithFormat:@"rate=%ld&price=%ld",(NSInteger)maxCBGModel.plan_rate,maxCBGModel.equip_price];
        
        NSString * appUrlString = [NSString stringWithFormat:@"refreshPayApp://params?weburl=%@&%@",[urlString base64EncodedString],param];
        
        [DZUtils startNoticeWithLocalUrl:appUrlString];
        
        NSURL *appPayUrl = [NSURL URLWithString:appUrlString];
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        if(!total.isNotSystemApp){
            appPayUrl = [NSURL URLWithString:maxCBGModel.mobileAppDetailShowUrl];
        }
        
        //当需要跳转时系统APP时，对于利率不是很高的，进行快速展示，但不进行主动跳转
        if(!total.isNotSystemApp && maxCBGModel.plan_rate < total.limitRate && total.limitRate > 0){
            return;
        }
        
        if([[UIApplication sharedApplication] canOpenURL:appPayUrl]  &&
           [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        {
            [[UIApplication sharedApplication] openURL:appPayUrl];
        }else
        {
            self.planWeb = [[CBGDetailWebView alloc] init];
            [self.planWeb prepareWebViewWithUrl:urlString];
            
            self.latest = maxModel;
            self.latestContain = YES;
        }
    }
    
}
    
    //列表刷新，按照最新的返回数据,新增，还是替换
-(void)refreshTableViewWithInputLatestListArray:(NSArray *)array  replace:(BOOL)replace
{
    if(!array || [array count] == 0) return;
    self.grayArray = array;
    
    //    if(replace)
    {
        [self checkListInputForNoticeWithArray:array];
    }
    
    NSMutableArray * refreshArray = [NSMutableArray array];
    [refreshArray addObjectsFromArray:self.showArray];
    
    if(replace)
    {
        
        NSInteger minNum = MIN([array count], [refreshArray count]);
        //替换
        for (NSInteger index = 0; index < minNum; index++)
        {
            id eveOjb = [array objectAtIndex:index];
            [refreshArray replaceObjectAtIndex:index withObject:eveOjb];
        }
    }else{
        //插入删除
        
        //最大
        NSInteger maxShowNum = RefreshListMaxShowNum;
        //当前
        NSInteger listNum = [self.showArray count];
        //新增
        NSInteger inputNum = [array count];
        
        if(inputNum >= maxShowNum)
        {
            [refreshArray removeAllObjects];
            [refreshArray addObjectsFromArray:array];
            [refreshArray removeObjectsInRange:NSMakeRange(maxShowNum,inputNum - maxShowNum)];
            
        }else{
            //需要移除的数量
            NSInteger removeNum = listNum - (maxShowNum - inputNum);
            
            if(removeNum > 0)
            {
                [refreshArray removeObjectsInRange:NSMakeRange(listNum - removeNum, removeNum)];
            }
            for (NSInteger index = 0;index < [array count]; index ++)
            {
                NSInteger backIndex = [array count] - index - 1;
                id eveOjb = [array objectAtIndex:backIndex];
                [refreshArray insertObject:eveOjb atIndex:0];
            }
        }
    }
    
    self.showArray = refreshArray;
    self.dataArr2 = refreshArray;
    [self.listTable reloadData];
}
    
- (void)viewDidLoad {
    
    NSDate * date = [NSDate date];
    //    NSDate * date = [NSDate fromString:@"2016-02-05 17:54"];
    date = [date dateByAddingTimeInterval:MonthTimeIntervalConstant];
    //    NSString * select = [date toString:@"MM-dd"];
    showTotal = YES;
    //    @"yyyy-MM-dd HH:mm:ss"
    //    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    //    NSString * str = [NSString stringWithFormat:@"%ds",[total.refreshTime intValue]];
    
    NSString * str = [NSString stringWithFormat:@"%lu",(unsigned long)[self.totalArr count]];
    
    self.viewTtle = [NSString stringWithFormat:@"服务器 %@",str];

    
    self.rightTitle = @"筛选";
    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    CGFloat aHeight = CGRectGetMaxY(self.titleBar.frame);
    rect.origin.y = aHeight;
    rect.size.height -= aHeight;
    
    UITableView * table = [[UITableView alloc] initWithFrame:rect];
    table.delegate = self;
    table.dataSource =self;
    table.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.listTable = table;
    [self.view addSubview:table];
    
    [self.view addSubview:self.waitingTips];
    self.waitingTips.hidden = YES;
    
    [self.view addSubview:self.randomTips];
    self.randomTips.hidden = YES;
    
    [self.view addSubview:self.networkTips];
    self.randomTips.hidden = YES;

    
//    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
//    if(check.serverHistory)
//    {
//        self.showArray = check.serverHistory;
//        self.dataArr2 = check.serverHistory;
//        [self.listTable reloadData];
//    }
    
}
-(UIView *)randomTips
{
    if(!_randomTips)
    {
        CGFloat btnWidth = 150;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor redColor];
        
        UILabel * albl = [[UILabel alloc] initWithFrame:aView.bounds];
        albl.text = @"验证码异常";
        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedRefreshRandNumGesture:)];
        [aView addGestureRecognizer:tapGes];
        self.randomTips = aView;
    }
    return _randomTips;
}
-(void)tapedRefreshRandNumGesture:(UITapGestureRecognizer *)tap
{
    ZWServerURLCheckVC * check = [[ZWServerURLCheckVC  alloc] init];
    [[self rootNavigationController] pushViewController:check animated:YES];
}

-(UIView *)waitingTips{
    if(!_waitingTips)
    {
        CGFloat btnWidth = 150;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor greenColor];
        
        UILabel * albl = [[UILabel alloc] initWithFrame:aView.bounds];
        albl.text = @"Cookiet(刷新)";
        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedRefreshGesture:)];
        [aView addGestureRecognizer:tapGes];
        self.waitingTips = aView;
    }
    return _waitingTips;
}
    
-(void)tapedRefreshGesture:(id)sender
{
    [DZUtils noticeCustomerWithShowText:@"自动获取"];
}
-(UIView *)networkTips
{
    if(!_networkTips)
    {
        CGFloat btnWidth = 150;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor redColor];
        
        UILabel * albl = [[UILabel alloc] initWithFrame:aView.bounds];
        albl.text = @"网络异常(刷新)";
        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedRefreshNetworkGesture:)];
        [aView addGestureRecognizer:tapGes];
        self.networkTips = aView;
    }
    return _networkTips;
}

-(void)tapedRefreshNetworkGesture:(id)sender
{
    [DZUtils noticeCustomerWithShowText:@"自动获取"];
}


-(void)submit
{
    //提供选择
    NSString * log = [NSString stringWithFormat:@"对刷新数据筛选？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"查看历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf showForDetailHistory];
                             }];
    [alertController addAction:action];
    
    
    //    action = [MSAlertAction actionWithTitle:@"刷新上架" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
    //              {
    //                  [weakSelf refreshLocalShowListForLatestSelling];
    //              }];
    //    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"全部并发" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  //                  [weakSelf refreshLocalShowLatestCountPagesRequest];
                  weakSelf.serverNum = 150;
                  [weakSelf refreshLatestListRequestModelWithSmallList:NO];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"每次50个" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  //                  [weakSelf refreshLocalShowLatestCountPagesRequest];
                  weakSelf.serverNum = 50;
                  [weakSelf refreshLatestListRequestModelWithSmallList:NO];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"每次30个" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  //                  [weakSelf refreshLocalShowListForLactestUpdating];
                  weakSelf.serverNum = 30;
                  [weakSelf refreshLatestListRequestModelWithSmallList:NO];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"每次10个" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  //                  [weakSelf refreshLocalShowLatestCountPagesRequest];
                  weakSelf.serverNum = 10;
                  [weakSelf refreshLatestListRequestModelWithSmallList:NO];
              }];
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"清空cookie" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
                    for (NSHTTPCookie *cookie in cookiesArray)
                    {
                        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                    }

              }];
    [alertController addAction:action];

    
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}
-(void)refreshCheckManagerDBIngore:(BOOL)ingore
{
    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    check.ingoreDB = ingore;
}
    
-(void)refreshLocalShowListForLatestSelling
{//3页列表内的新增
    //展示上架
    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    check.ingoreUpdate = YES;
    
}
-(void)refreshLocalShowListForLactestUpdating
{//3页列表数据内的变更
    //展示变更
    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    check.ingoreUpdate = NO;
}
-(void)refreshLocalShowListForLargeRequest
{//3页列表数据内的变更
    //展示变更
    //    self.totalPageNum = 10;
    //    [self refreshLatestListRequestModelWithSmallList:NO];
    
}
    
    
    
-(void)showForDetailHistory
{
    ZWHistoryListController * history = [[ZWHistoryListController alloc] init];
    [[self rootNavigationController] pushViewController:history animated:YES];
}
    
-(void)startLocationDataRequest
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    self.latest = [manager latestLocationModel];
    
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
    
    RecorderTimeRefreshManager * manager = [RecorderTimeRefreshManager sharedInstance];
    if(manager.isRefreshing) return;
    [self startOpenTimesRefreshTimer];
}
    
    
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    _detailListReqModel = nil;
    _dpModel = nil;
    [self startLocationDataRequest];
    
    self.inWebRequesting = NO;
    self.randomTips.hidden = YES;
    //    [requestLock unlock];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s disappear",__FUNCTION__);
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    EquipDetailArrayRequestModel * detailRefresh = (EquipDetailArrayRequestModel *)_detailListReqModel;
    ServerEquipIdRequestModel * refresh = (ServerEquipIdRequestModel *)_dpModel;
    
    if(detailRefresh.executing || refresh.executing)
    {
        [requestLock unlock];
    }
    
    
    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    if([refresh.cookieDic count]> 0){
        check.cookieDic = refresh.cookieDic;
    }
    
    
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
    //    _detailListReqModel = nil;
    
    [refresh cancel];
    [refresh removeSignalResponder:self];
    //    _dpModel = nil;
    
    //    self.inWebRequesting = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    RecorderTimeRefreshManager * manager = [RecorderTimeRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [[ZALocation sharedInstance] stopUpdateLocation];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishRequestWithExchange) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startRefreshDataModelRequest) object:nil];
}
    
-(void)startOpenTimesRefreshTimer
{
    
    RecorderTimeRefreshManager * manager = [RecorderTimeRefreshManager sharedInstance];
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
    [weakSelf performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                               withObject:nil
                            waitUntilDone:YES];
#else
    [weakSelf performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                               withObject:nil
                            waitUntilDone:NO];
#endif
    
};
    [manager saveCurrentAndStartAutoRefresh];
}
-(void)refreshCurrentTitleVLableWithTotal:(CGFloat)totalMoney andCountNum:(NSInteger)number
{
    NSString * total = [NSString stringWithFormat:@"总在售 %.1fW(%d)",totalMoney/10000,number];
    self.titleV.text = total;
}
    
-(void)refreshLatestListRequestModelWithSmallList:(BOOL)small
{
    //变更请求基数，重新发起
    
    
}
    
-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }

    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];

    EquipDetailArrayRequestModel * detailArr = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(detailArr.executing) return;

    ServerEquipIdRequestModel * listRequest = (ServerEquipIdRequestModel *)_dpModel;
    if(listRequest.executing) return;

    if(!self.randomTips.hidden) return;//当展示需要输入验证码时，不进行继续刷新
    
    
    NSArray * server = [self latestServerIdArr];
    if([server count] == 0) return;
    
    
    //    if(self.inWebRequesting)
    //    {
    //        return;
    //    }
    //    self.inWebRequesting = YES;
    [requestLock lock];

    NSLog(@"%s",__FUNCTION__);

    ServerEquipIdRequestModel * model = (ServerEquipIdRequestModel *)_dpModel;

    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[ServerEquipIdRequestModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
        
        /*
         if(self.totalPageNum >= 3)
         {
         [self refreshLatestListRequestModelWithSmallList:YES];
         }
         if(self.maxRefresh)
         {
         model.pageNum = 100;
         }
         */
    }
    
    model.saveKookie = YES;
    model.serverArr = server;
    model.timerState = !model.timerState;
    [model sendRequest];
}
#pragma mark ServerEquipIdRequestModel
handleSignal( ServerEquipIdRequestModel, requestError )
{
    self.networkTips.hidden = NO;
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;


}
handleSignal( ServerEquipIdRequestModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    [self showLoading];
}


handleSignal( ServerEquipIdRequestModel, requestLoaded )
{
    [self hideLoading];
    //    refreshLatestTotalArray
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%s",__FUNCTION__);
    
    //使用total给request赋值
    ServerEquipIdRequestModel * model = (ServerEquipIdRequestModel *) _dpModel;
    NSArray * total  = model.listArray;
    NSArray * request = model.serverArr;
    NSMutableArray * backArray = [NSMutableArray array];//用来展示的
    
    NSMutableArray * finishArr = [NSMutableArray array];
    NSMutableArray * randArr = [NSMutableArray array];
    NSMutableArray * waitingArr = [NSMutableArray array];
    
    
    if([total count] == [request count])
    {
        for (NSInteger index = 0;index < [total count] ;index ++ )
        {
            NSArray * objArr = [total objectAtIndex:index];
            ZWServerEquipModel * req = [request objectAtIndex:index];
            
            if([objArr isKindOfClass:[NSArray class]] && [objArr count] > 0)
            {
                EquipModel * detail = [objArr lastObject];
                req.detail = detail;
                req.equipDesc =  detail.equip_desc;
                
                if([detail.game_ordersn length] > 0)
                {
                    Equip_listModel * list = [[Equip_listModel alloc] init];
                    list.serverid = detail.serverid;
                    list.game_ordersn = detail.game_ordersn;
                    list.equipModel = detail;
                    
                    [backArray addObject:list];
                }
                
                switch (detail.resultType)
                {
                    case ServerResultCheckType_Error:
                    {
                        [randArr addObject:detail];
                    }
                        break;
                    case ServerResultCheckType_Redirect:{
                        [waitingArr addObject:detail];
                    }
                        break;
                    case ServerResultCheckType_None:
                    {
                        [finishArr addObject:detail];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }else
    {
        NSLog(@"数量不相等");
    }

    
    //根据结果，重新刷新totalArr内含int
    [self refreshServerEquipListWithRequestPageIndexArray:request];
    

    self.networkTips.hidden = [finishArr count] == 0;
    self.randomTips.hidden = [randArr count] == 0;
    self.waitingTips.hidden = [waitingArr count] == 0;
    
    //服务器数据排列顺序，最新出现的在最前面
    //服务器返回的列表数据，需要进行详情请求
    //详情请求需要检查，1、本地是否已有存储 2、是否存储于请求队列中
    //不检查本地存储、不检查队列是否存在，仅检查缓存数据
    if([backArray count] > 0)
    {
        ZWDetailCheckManager * checkManager = [ZWDetailCheckManager sharedInstance];
        [checkManager refreshDiskCacheWithDetailRequestFinishedArray:backArray];
        NSArray * refreshArr = checkManager.filterArray;
        if([refreshArr count] > 0)
        {
            NSLog(@"checkManager %lu ",(unsigned long)[refreshArr count]);
            [self refreshTableViewWithInputLatestListArray:refreshArr replace:NO];
        }
    }

    self.inWebRequesting = NO;
    [requestLock unlock];

    
}
-(void)refreshServerEquipListWithRequestPageIndexArray:(NSArray *)array
{
//    NSArray * edit = self.dataArr;
    NSMutableString * moreReq = [NSMutableString string];
    for (NSInteger index = 0; index < [array count]; index ++)
    {
        ZWServerEquipModel * server = [array objectAtIndex:index];
        if(server.detail.resultType == ServerResultCheckType_Success)
        {
            [moreReq appendFormat:@"%ld(%ld)+  ",server.serverId,server.equipId];
            server.equipId ++;
            
            server.detail = nil;
            server.equipDesc = nil;
        }
    }
    if([moreReq length] > 0)
    {
        NSLog(@"moreReq %@",moreReq);
    }
}


    
-(void)startRequestWithEquipModel:(Equip_listModel *)list
{
    CBGEquipDetailRequestManager * manager = [CBGEquipDetailRequestManager sharedInstance];
    [manager addDetailEquipRequestUrlWithEquipModel:list];
}
    
    
-(void)checkCurrentLatestContainState
{
        return;
        ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
        ZWDataDetailModel * contact = [manager latestLocationModel];
        //    self.latest = contact;
        
        if(!contact) return;
        
        __block BOOL contain = NO;
        NSMutableArray * array = [NSMutableArray arrayWithArray:self.dataArr];
        
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZWDataDetailModel  * model = (ZWDataDetailModel *)obj;
            if([contact.product_id isEqualToString:model.product_id]){
                contain = YES;
                contact.left_money  = model.left_money;
            }
        }];
        
    NSIndexSet * set = [NSIndexSet indexSetWithIndex:0];
    [self.listTable reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}
    
    
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"%s",__FUNCTION__);
}
    
    
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return [self.dataArr count];
    }else{
        return [self.dataArr2 count];
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(void)tapedOnRefreshCellCopyDelegateWithIndex:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    Equip_listModel * contact = nil;
    if(secNum == 1){
        contact = [self.dataArr objectAtIndex:rowNum];
    }else if (secNum == 2){
        contact = [self.dataArr2 objectAtIndex:rowNum];
    }else{
        contact = self.latest;
    }
    
    if(contact)
    {
        NSString * planUrl = contact.detailWebUrl;
        if(planUrl)
        {
            UIPasteboard * board = [UIPasteboard generalPasteboard];
            board.string = planUrl;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    Equip_listModel * contact = nil;
    if(secNum == 1){
        contact = [self.dataArr objectAtIndex:rowNum];
    }else if (secNum == 2){
        contact = [self.dataArr2 objectAtIndex:rowNum];
    }else{
        contact = self.latest;
    }
    
    static NSString *cellIdentifier = @"RefreshListCellIdentifier";
    RefreshListCell *cell = (RefreshListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        //            cell = [[ZAContactListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andTableView:tableView];
        //            cell.delegate = self;
        
        
        RefreshListCell * swipeCell = [[[NSBundle mainBundle] loadNibNamed:@"RefreshListCell"
                                                                     owner:nil
                                                                   options:nil] lastObject];
        
        //        [[RefreshListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [swipeCell setValue:cellIdentifier forKey:@"reuseIdentifier"];
        
        cell = swipeCell;
        
        cell.cellDelegate = self;
    }
    cell.coverBtn.hidden = NO;
    cell.indexPath = indexPath;
    
    //以detail为主进行展示
    
    //用来标识是否最新一波数据
    UIColor * numcolor = [self.grayArray containsObject:contact]?[UIColor blackColor]:[UIColor lightGrayColor];
    
    EquipModel * detail = contact.equipModel;
    NSString * centerDetailTxt = contact.desc_sumup;
    
    UIColor * color = [UIColor lightGrayColor];
    UIColor * priceColor = [UIColor redColor];
    NSString * sellTxt = [NSString stringWithFormat:@"%@-%@",contact.area_name,contact.server_name];
    NSString * equipName = [NSString stringWithFormat:@"%@  -  %@",contact.equip_name,contact.subtitle];
    NSString * leftPriceTxt = contact.price_desc;
    
    if(!contact)
    {
        sellTxt = nil;
        equipName = nil;
        centerDetailTxt = nil;
    }
    
    cell.latestMoneyLbl.textColor = color;
    
    //默认设置
    
    //列表剩余时间
    NSString * dateStr = contact.sell_expire_time_desc;
    //    @"dd天HH小时mm分钟"
    NSDateFormatter * format = [NSDate format:@"dd天HH小时mm分钟"];
    NSDate * date = [format dateFromString:dateStr];
    NSString * rightTimeTxt =  [date toString:@"HH:mm(余)"];
    NSString * rightStatusTxt = contact.status_desc;
    
    //详情剩余时间
    UIColor * earnColor = [UIColor lightGrayColor];
    CBGListModel * listModel = [contact listSaveModel];
    if(contact.appendHistory){
        listModel = contact.appendHistory;
    }
    //仅无详情时有效，此时数据为库表数据补全
    
    if(listModel.plan_total_price != 0)
    {
        centerDetailTxt = [NSString stringWithFormat:@"%ld (%ld) %d",listModel.plan_total_price,listModel.plan_zhaohuanshou_price + listModel.plan_zhuangbei_price,(int)listModel.price_base_equip];
    }
    
    //用来标识账号是否最新一次请求数据
    if(detail)
    {
        NSNumber * serId = detail.serverid;
        sellTxt = [self.serNameDic objectForKey:serId];
        equipName = [NSString stringWithFormat:@"%@ - %ld级",listModel.equip_school_name,[detail.equip_level integerValue]];
        
        date = [NSDate fromString:detail.selling_time];
        rightTimeTxt =  [date toString:@"HH:mm"];
        
        leftPriceTxt = detail.last_price_desc;
        
        rightStatusTxt = detail.detailStatusDes;
        
        NSTimeInterval interval = [self timeIntervalWithCreateTime:detail.create_time andSellTime:detail.selling_time];
        if(interval < 60 * 60 * 24 )
        {
            earnColor = [UIColor orangeColor];
        }
        if(interval < 60){
            earnColor = [UIColor redColor];
        }
        
    }
    
    UIColor * equipBuyColor = [UIColor lightGrayColor];
    UIColor * leftRateColor = [UIColor lightGrayColor];
    UIColor * rightStatusColor = [UIColor lightGrayColor];

    if(listModel.plan_total_price>[contact.price floatValue]/100 && [contact.price integerValue] > 0)
    {
        rightStatusColor = [UIColor redColor];
    }
    
    NSInteger histroyPrice = listModel.historyPrice;
    NSInteger priceChange = histroyPrice/100 - [contact.price integerValue]/100;
    
    if([listModel preBuyEquipStatusWithCurrentExtraEquip])
    {
        sellTxt = [NSString stringWithFormat:@"%.0ld %@",listModel.plan_rate,sellTxt];
        equipName = [NSString stringWithFormat:@"%.0ld %@",listModel.price_earn_plan,equipName];
        leftRateColor = Custom_Green_Button_BGColor;
        
    }else if(histroyPrice > 0 && priceChange != 0 && [contact.price integerValue] > 0)
    {
        if(priceChange >0)
        {
            leftRateColor = [UIColor orangeColor];
        }
        sellTxt = [NSString stringWithFormat:@"%ld%@",histroyPrice/100,sellTxt];
    }
    
    if(detail){
        if([detail.allow_bargain integerValue] > 0)
        {
            leftPriceTxt = [NSString stringWithFormat:@"%@*",leftPriceTxt];
        }
    }else{
        if(contact.accept_bargain)
        {
            leftPriceTxt = [NSString stringWithFormat:@"%@*",leftPriceTxt];
        }
    }
    
    if(listModel.planMore_zhaohuan || listModel.planMore_Equip)
    {
        numcolor = [UIColor redColor];
    }
    
    if(listModel.appointed)
    {
        priceColor = Custom_Blue_Button_BGColor;
    }
    
    cell.totalNumLbl.textColor = numcolor;//文本信息展示，区分是否最新一波数据
    cell.totalNumLbl.text = centerDetailTxt;
    cell.rateLbl.text = leftPriceTxt;
    cell.rateLbl.textColor = priceColor;
    cell.sellTimeLbl.text = rightStatusTxt;
    cell.sellTimeLbl.textColor = rightStatusColor;
    cell.timeLbl.text = rightTimeTxt;
    
    UIFont * font = cell.totalNumLbl.font;
    cell.latestMoneyLbl.text = sellTxt;
    cell.timeLbl.textColor = earnColor;
    cell.sellRateLbl.font = font;
    cell.latestMoneyLbl.font = font;
    cell.sellDateLbl.hidden = YES;
    cell.sellRateLbl.text = equipName;
    cell.sellRateLbl.textColor = equipBuyColor;
    cell.latestMoneyLbl.textColor = leftRateColor;
    
    cell.selected = NO;
    if(secNum == 0 )
    {
        color = [UIColor lightGrayColor];
        NSString * txt = nil;
        //        NSDate * date = [NSDate dateWithTimeIntervalSince1970:[contact.selling_time floatValue]];
        //        cell.sellTimeLbl.text = [date toString:@"MM-dd HH:mm"];
        
        NSInteger statusNum = [detail.status integerValue];
        txt = (statusNum!=4&&statusNum!=6 && detail)?@"尚有":@"无";
        color = self.latestContain?[UIColor redColor]:[UIColor lightGrayColor];
        
        cell.sellTimeLbl.text = txt;
        cell.sellTimeLbl.textColor = color;
        
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}
#pragma mark -
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    Equip_listModel * contact = nil;
    if(secNum == 1){
        contact = [self.dataArr objectAtIndex:rowNum];
    }else if (secNum == 2){
        contact = [self.dataArr2 objectAtIndex:rowNum];
    }else{
        contact = self.latest;
    }
    
    if(contact)
    {
        //        NSString * planUrl = self.planWeb.showUrl;
        //        if([planUrl isEqualToString:contact.detailWebUrl])
        //        {
        //            CBGPlanDetailPreShowWebVC * detail = [[CBGPlanDetailPreShowWebVC alloc] init];
        //            detail.planWebView = self.planWeb;
        //            detail.cbgList = [contact listSaveModel];
        //            detail.detailModel = contact.equipModel;
        //            [[self rootNavigationController] pushViewController:detail animated:YES];
        //        }else
        {
            CBGListModel * cbgModel = [contact listSaveModel];
            if(cbgModel.plan_total_price == 0 && contact.appendHistory){
                cbgModel = contact.appendHistory;
            }
            
            ZACBGDetailWebVC * detail = [[ZACBGDetailWebVC alloc] init];
            detail.cbgList = cbgModel;
            detail.detailModel = contact.equipModel;
            [[self rootNavigationController] pushViewController:detail animated:YES];
        }
        
    }
    
    
    
}
-(NSTimeInterval)timeIntervalWithCreateTime:(NSString *)create andSellTime:(NSString *)selltime
{
    NSDate * createDate = [NSDate fromString:create];
    NSDate * sellDate = [NSDate fromString:selltime];
    
    NSTimeInterval interval = [sellDate timeIntervalSinceDate:createDate];
    //    NSLog(@"interval %f",interval);
    return interval;
    
}

@end
