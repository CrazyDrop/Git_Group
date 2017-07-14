//
//  CBGWebListRefreshVC.m
//  WebConnectPrj
//
//  Created by Apple on 17/3/25.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "CBGWebListRefreshVC.h"
#import "CBGWebListCheckManager.h"
#import "MSAlertController.h"
#import "ZALocationLocalModel.h"
#import "OpenTimesRefreshManager.h"
#import "CBGWebListRequestModel.h"
#import "EquipDetailArrayRequestModel.h"
#import "ZACBGDetailWebVC.h"
#import "RefreshListCell.h"
#import "WebEquip_listModel.h"
#import "CBGListModel.h"
#import "CBGWebListErrorCheckVC.h"
#import "CBGDetailWebView.h"
#import "ZWDetailCheckManager.h"
@interface CBGWebListRefreshVC ()<UITableViewDelegate,UITableViewDataSource,
RefreshCellCopyDelgate>{
    BaseRequestModel * _detailListReqModel;
    NSInteger circleTotal;
}
@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,copy) NSArray * dataArr;
@property (nonatomic,copy) NSArray * dataArr2;
@property (nonatomic,assign) BOOL latestContain;
@property (nonatomic,strong) id latest;
@property (nonatomic,strong) UIView * tipsView;
@property (nonatomic,strong) NSArray * detailsArr;
@property (nonatomic,strong) NSArray * showArray;
@property (nonatomic,strong) NSArray * grayArray;
@property (nonatomic,assign) BOOL cookieState;
@property (nonatomic,assign) BOOL cookieAutoRefresh;
@property (nonatomic,assign) NSInteger pageNum;

@property (nonatomic,assign) BOOL webCheckError;
@property (nonatomic,strong) CBGDetailWebView * planWeb;

@property (nonatomic,assign) BOOL endRefresh;
@property (nonatomic,strong) NSDate * finishDate;   //刷新截止时间
@property (nonatomic,strong) NSDate * nextDate;     //刷新开始时间
@property (nonatomic,assign) BOOL endEanble;

@end

@implementation CBGWebListRefreshVC
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){

        [self appendNotificationForRestartTimerRefreshWithActive];
        circleTotal = 3;
        self.cookieAutoRefresh = NO;
        self.cookieState = YES;
        
        self.endEanble = NO;
        self.finishDate = [NSDate dateWithTimeIntervalSinceNow:10 * MINUTE];
    }

    return self;
}
-(void)appendNotificationForRestartTimerRefreshWithActive
{
    //    UIApplicationDidBecomeActiveNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkLatestVCAndStartTimer)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshWebRequestWithWebRequestNeedRefreshError:)
                                                 name:NOTIFICATION_NEED_REFRESH_WEB_ERROR_STATE
                                               object:nil];
    
    
}
-(void)refreshWebRequestWithWebRequestNeedRefreshError:(NSNotification *)noti
{
    self.webCheckError = [noti.object boolValue];//屏蔽自身网络请求
}

-(void)checkLatestVCAndStartTimer
{
    NSArray * arr = [[self rootNavigationController] viewControllers];
    if([arr count] > 0){
        UIViewController * vc = [arr lastObject];
        
        if([vc isKindOfClass:[self class]])
        {
//            [self startLocationDataRequest];
        }
    }
}

- (void)viewDidLoad {

    //    NSDate * date = [NSDate fromString:@"2016-02-05 17:54"];
//    date = [date dateByAddingTimeInterval:MonthTimeIntervalConstant];
//    NSString * select = [date toString:@"MM-dd"];
//    showTotal = YES;
    //    @"yyyy-MM-dd HH:mm:ss"
//    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//    NSString * str = [NSString stringWithFormat:@"%ds",[total.refreshTime intValue]];
    
    self.viewTtle = @"WEB数据刷新";
    
    self.rightTitle = @"方案";
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
    
    [self.view addSubview:self.tipsView];
    self.tipsView.hidden = YES;
    
    CBGWebListCheckManager * check = [CBGWebListCheckManager sharedInstance];
    if(check.latestHistory)
    {
        self.showArray = check.latestHistory;
        self.dataArr2 = check.latestHistory;
        [self.listTable reloadData];
    }
}

-(UIView *)tipsView{
    if(!_tipsView)
    {
        CGFloat btnWidth = 100;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor redColor];
        
        UILabel * albl = [[UILabel alloc] initWithFrame:aView.bounds];
        albl.text = @"错误(刷新)";
        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedRefreshGesture:)];
        [aView addGestureRecognizer:tapGes];
        self.tipsView = aView;
    }
    return _tipsView;
}

-(void)tapedRefreshGesture:(id)sender
{
    CBGWebListErrorCheckVC * errorWeb = [[CBGWebListErrorCheckVC alloc] init];
    [[self rootNavigationController] pushViewController:errorWeb animated:YES];
}
-(void)clearLatestRequestModel
{
    EquipDetailArrayRequestModel * detailRefresh = (EquipDetailArrayRequestModel *)_detailListReqModel;
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
    _detailListReqModel = nil;
    
    EquipListRequestModel * refresh = (EquipListRequestModel *)_dpModel;
    [refresh cancel];
    [refresh removeSignalResponder:self];
    _dpModel = nil;
}
-(void)submit
{
    //提供选择
    NSString * log = [NSString stringWithFormat:@"改变刷新方案?"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    //清空model，界面展示时，已经调用disappear方法，清空了model，
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"使用cookie(常规)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 weakSelf.cookieState = YES;
                                 weakSelf.cookieAutoRefresh = NO;
                             }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"清空cookie" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
                  for (NSHTTPCookie *cookie in cookiesArray)
                  {
                      if([cookie.name isEqualToString:@"overall_sid"]){
                          [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                      }
                  }
                  
              }];
    [alertController addAction:action];
    
//    action = [MSAlertAction actionWithTitle:@"使用cookie(变动)" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
//              {
//                  weakSelf.cookieAutoRefresh = YES;
//                  weakSelf.cookieState = YES;
//              }];
//    [alertController addAction:action];
//    
//    action = [MSAlertAction actionWithTitle:@"屏蔽cookie" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
//              {
//                  weakSelf.cookieState = NO;
//                  
//              }];
//    [alertController addAction:action];
    


    action = [MSAlertAction actionWithTitle:@"增加并发" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  if(weakSelf.pageNum < 5)
                  {
                    weakSelf.pageNum ++;
                  }
              }];
    [alertController addAction:action];
    
    
    action = [MSAlertAction actionWithTitle:@"开启中断" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.endEanble = YES;
                  weakSelf.endRefresh = NO;
                  weakSelf.finishDate = [NSDate dateWithTimeIntervalSinceNow:10 * MINUTE];
                  weakSelf.nextDate = nil;
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"停止中断" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.endEanble = NO;
                  //                  weakSelf.endRefresh = NO;
                  //                  weakSelf.finishDate = [NSDate dateWithTimeIntervalSinceNow:10 * MINUTE];
                  //                  weakSelf.nextDate = nil;
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
    
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
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
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    CBGWebListCheckManager * check = [CBGWebListCheckManager sharedInstance];
    check.latestHistory = self.showArray;
    [check refreshDiskCacheWithDetailRequestFinishedArray:check.modelsArray];
    
    [self clearLatestRequestModel];
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [[ZALocation sharedInstance] stopUpdateLocation];
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
        [weakSelf performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                                   withObject:nil
                                waitUntilDone:NO];
#else
        [weakSelf performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                                   withObject:nil
                                waitUntilDone:NO];
#endif
    };
    [manager saveCurrentAndStartAutoRefresh];
}
-(void)refreshCurrentTitleVLableWithFinishModel:(id)aRequest
{
    CBGWebListRequestModel * model = (CBGWebListRequestModel *)aRequest;
    if(model.latestIndex > 1) return;
    NSInteger minute = model.maxTimeNum;
    NSInteger sepNum = 60 - minute;
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow: - sepNum * 60];
    NSString * latestTime =  [date toString:@"HH:mm"];
    NSString * total = nil;
    total = [NSString stringWithFormat:@"最近 %@",latestTime];
    total = [NSString stringWithFormat:@"最短 %ld",sepNum];

    self.titleV.text = total;
}


-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }

    if(self.webCheckError){
        return;
    }
    
    
    EquipDetailArrayRequestModel * detailArr = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(detailArr.executing) return;
    
    //当前已经停止刷新，且未到达下次开始时间
    NSTimeInterval count = [self.nextDate timeIntervalSinceNow];
//    NSTimeInterval finishLimit = [self.finishDate timeIntervalSinceNow];
    if(self.endEanble)
    {
        if(self.endRefresh)
        {
            if(count > 0 && self.nextDate ){
                //屏蔽刷新
                return;
            }else{
                //开始1分钟刷新，重新指定下次时间
                self.endRefresh = NO;
                self.nextDate = nil;
                self.finishDate = [NSDate dateWithTimeIntervalSinceNow:1 * MINUTE];
            }
        }
    }
    
    
    NSLog(@"%s %@ %@",__FUNCTION__,[self.finishDate toString:@"HH:mm:ss"],[self.nextDate toString:@"HH:mm:ss"]);
    
    
    CBGWebListRequestModel * model = (CBGWebListRequestModel *)_dpModel;
    
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[CBGWebListRequestModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
        
        model.pageNum = self.pageNum;
        model.saveKookie = self.cookieState;
        model.autoRefresh = self.cookieAutoRefresh;
    }
    
    
    [model sendRequest];
}
#pragma mark CBGWebListRequestModel
handleSignal( CBGWebListRequestModel, requestError )
{
    self.tipsView.hidden = NO;
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
}
handleSignal( CBGWebListRequestModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    [self showLoading];
}


handleSignal( CBGWebListRequestModel, requestLoaded )
{
    [self hideLoading];
    //    refreshLatestTotalArray
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    CBGWebListRequestModel * model = (CBGWebListRequestModel *) _dpModel;
    NSArray * total  = model.listArray;
    
    //正常序列
    NSMutableArray * array = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]])
        {
            [array addObjectsFromArray:obj];
        }
    }
    
    self.tipsView.hidden = [array count] != 0;
    
//    NSLog(@"CBGWebListRequestModel %lu %lu",(unsigned long)[array count],(unsigned long)[total count]);
    
    [self refreshCurrentTitleVLableWithFinishModel:_dpModel];
    
    EquipDetailArrayRequestModel * detailArr = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(detailArr.executing) return;
    
    
    //停止刷新为NO时  endRefresh
    NSTimeInterval count = [self.finishDate timeIntervalSinceNow];
    NSTimeInterval nextCount = [self.nextDate timeIntervalSinceNow];
    if(count < 0 && self.nextDate)
    {//没有停止之前，已经刷新到数据
        if(nextCount > 0){
            self.endRefresh = YES;
        }else{
            NSLog(@"延迟1分钟");
            self.finishDate = [NSDate dateWithTimeIntervalSinceNow:1 * MINUTE];
        }
    }
    //服务器数据排列顺序，最新出现的在最前面
    //服务器返回的列表数据，需要进行详情请求
    //详情请求需要检查，1、本地是否已有存储 2、是否存储于请求队列中
    //不检查本地存储、不检查队列是否存在，仅检查缓存数据
    CBGWebListCheckManager * checkManager = [CBGWebListCheckManager sharedInstance];
    NSArray * models = [checkManager checkLatestBackListDataModelsWithBackModelArray:array];
    NSArray * refreshArr = checkManager.refreshArr;
    
    if([refreshArr count] > 0){
        NSLog(@"checkManager %lu ",(unsigned long)[refreshArr count]);
        [self refreshTableViewWithInputLatestListArray:refreshArr replace:NO];
    }
    
    if(!models || [models count] == 0)
    {
        //为空，标识没有新url
        return;
    }
    
    self.nextDate = [NSDate dateWithTimeIntervalSinceNow: (-0.5 + circleTotal) * MINUTE];
    NSLog(@"CBGWebListRequestModel %lu %lu",(unsigned long)[array count],(unsigned long)[models count]);

    
    NSMutableArray * urls = [NSMutableArray array];
    self.detailsArr = [NSArray arrayWithArray:models];
    for (NSInteger index = 0; index < [models count]; index ++)
    {
        WebEquip_listModel * eve = [models objectAtIndex:index];
        NSString * url = eve.detailDataUrl;
        [urls addObject:url];
    }
    
    [self startEquipDetailAllRequestWithUrls:urls];
    
    //    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    //    [dbManager localSaveEquipModelArray:models];//所有列表数据的缓存
    
}
-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
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
    //进行存储操作、展示
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *) _detailListReqModel;
    NSArray * total  = model.listArray;
    
    NSMutableArray * detailModels = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            [detailModels addObject:[obj firstObject]];
        }else{
            [detailModels addObject:[NSNull null]];
        }
    }
    
    NSLog(@"EquipDetailArrayRequestModel %lu",(unsigned long)[detailModels count]);
    
    NSArray * models = self.detailsArr;
    for (NSInteger index = 0; index < [models count]; index ++)
    {
        EquipModel * detailEve = nil;
        if([detailModels count] > index)
        {
            detailEve = [detailModels objectAtIndex:index];
        }

        WebEquip_listModel * obj = [models objectAtIndex:index];
        if(![detailEve isKindOfClass:[NSNull class]])
        {
            if(!detailEve.game_ordersn){
                continue;
            }
            obj.equipModel = detailEve;
            CBGListModel * list = obj.listSaveModel;
            obj.planPrice = list.plan_total_price;
            obj.earnRate = list.plan_rate;
            obj.earnPrice = list.price_earn_plan;
        }
    }
    
    CBGWebListCheckManager * check = [CBGWebListCheckManager sharedInstance];
    [check refreshDiskCacheWithDetailRequestFinishedArray:models];
    NSArray * showModels = check.filterArray;
    
    //刷新展示列表
    [self refreshTableViewWithInputLatestListArray:showModels replace:NO];
    
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
-(void)checkListInputForNoticeWithArray:(NSArray *)array
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(!total.isAlarm)
    {
//        return NO;
    }

    NSInteger compareId = total.minServerId;
    
    WebEquip_listModel * maxModel = nil;
    CGFloat maxRate = 0;
    for (NSInteger index = 0; index < [array count]; index ++)
    {
        WebEquip_listModel * list = [array objectAtIndex:index];
        
        BOOL equipBuy = [list preBuyEquipStatusWithCurrentExtraEquip];
        if(equipBuy && [list.serverid integerValue] < compareId)
        {
            CBGEquipRoleState state = list.listSaveModel.latestEquipListStatus;
            BOOL unSold = ( state == CBGEquipRoleState_InSelling|| state == CBGEquipRoleState_InOrdering || state == CBGEquipRoleState_unSelling);
            CGFloat rate = list.earnRate;
            if(unSold && rate >= maxRate){
                maxRate = rate;
                maxModel = list;
            }
        }
    }
    
    if(maxModel)
    {
        
        NSLog(@"%s %@",__FUNCTION__,maxModel.game_ordersn);
        NSString * webUrl = maxModel.detailWebUrl;
        NSString * urlString = webUrl;
        
        NSString * param = [NSString stringWithFormat:@"rate=%ld&price=%ld",(NSInteger)maxModel.earnRate,[maxModel.price integerValue]/100];
        
        NSString * appUrlString = [NSString stringWithFormat:@"refreshPayApp://params?weburl=%@&%@",[urlString base64EncodedString],param];
        
        [DZUtils startNoticeWithLocalUrl:appUrlString];
        
        NSURL *appPayUrl = [NSURL URLWithString:appUrlString];
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        if(!total.isNotSystemApp){
            appPayUrl = [NSURL URLWithString:maxModel.listSaveModel.mobileAppDetailShowUrl];
        }
        
        //当需要跳转时系统APP时，对于利率不是很高的，进行快速展示，但不进行主动跳转
        if(!total.isNotSystemApp && maxModel.earnRate < total.limitRate && total.limitRate > 0){
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

-(void)checkCurrentLatestContainState
{
    return;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
    WebEquip_listModel * contact = nil;
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
    
    
    //用来标识是否最新一波数据
    UIColor * numcolor = [self.grayArray containsObject:contact]?[UIColor blackColor]:[UIColor lightGrayColor];
    
    NSString * centerDetailTxt = nil;
    
    UIColor * color = [UIColor lightGrayColor];
    NSString * sellTxt = [NSString stringWithFormat:@"%@-%@",contact.area_name,contact.server_name];
    NSString * equipName = [NSString stringWithFormat:@"%@-%ld级",[CBGListModel schoolNameFromSchoolNumber:[contact.school intValue]],[contact.level integerValue]];
    NSString * leftPriceTxt = nil;
    
    if(!contact)
    {
        sellTxt = nil;
        equipName = nil;
        centerDetailTxt = nil;
    }
    
    
    CBGListModel * listModel = [contact listSaveModel];
    if(contact.appendHistory){
        listModel = contact.appendHistory;
    }
    //默认设置
    
    //列表剩余时间 13天23小时58分钟
    NSString * dateStr = contact.time_left;
    //    @"dd天HH小时mm分钟"
    NSDateFormatter * format = [NSDate format:@"dd天HH小时mm分钟"];
    NSDate * date = [format dateFromString:dateStr];
    NSString * rightTimeTxt =  [date toString:@"HH:mm(余)"];
    NSString * rightStatusTxt = nil;
    
    //详情剩余时间
    EquipModel * detail = contact.equipModel;
    
    UIColor * earnColor = [UIColor lightGrayColor];
    //用来标识账号是否最新一次销售
    if(detail)
    {
        if(!rightStatusTxt)
        {
            rightStatusTxt = detail.status_desc;
        }
        if(!leftPriceTxt){
            leftPriceTxt = detail.last_price_desc;
        }
        
        date = [NSDate fromString:detail.selling_time];
        rightTimeTxt =  [date toString:@"HH:mm"];
        
        NSTimeInterval interval = [self timeIntervalWithCreateTime:detail.create_time andSellTime:detail.selling_time];
        if(interval < 60 * 60 * 24 )
        {
            earnColor = [UIColor orangeColor];
        }
        if(interval < 60){
            earnColor = [UIColor redColor];
        }
    }else{
        
        rightStatusTxt = @"更新";
        if((!leftPriceTxt || [leftPriceTxt intValue] == 0 )&& listModel.equip_price > 0)
        {
            leftPriceTxt = [NSString stringWithFormat:@"%ld元",listModel.equip_price/100];
        }
    }
    
    UIColor * equipBuyColor = [UIColor lightGrayColor];
    UIColor * leftRateColor = [UIColor lightGrayColor];
    UIColor * rightStatusColor = [UIColor lightGrayColor];
    UIColor * priceColor = [UIColor redColor];
    CBGListModel * cbgList = [contact listSaveModel];
    if(contact.appendHistory)
    {
        cbgList = contact.appendHistory;
    }
    
    centerDetailTxt = [NSString stringWithFormat:@"%ld 号:%.0f(%d)",cbgList.plan_total_price,[cbgList price_base_equip],[contact.eval_price intValue]/100];
    if(cbgList.plan_total_price>[contact.price floatValue] && [contact.price integerValue] > 0)
    {
        rightStatusColor = [UIColor redColor];
    }
    
    if(cbgList.planMore_zhaohuan || cbgList.planMore_Equip)
    {
        numcolor = [UIColor redColor];
    }
    
    if([contact preBuyEquipStatusWithCurrentExtraEquip])
    {
        if(contact.earnPrice > 0)
        {
            sellTxt = [NSString stringWithFormat:@"%.0ld %@",cbgList.plan_rate,sellTxt];
            equipName = [NSString stringWithFormat:@"%.0ld %@",(long)cbgList.price_earn_plan,equipName];
            leftRateColor = [UIColor orangeColor];
        }
    }

    if(detail)
    {
        //进行数据追加
        //        修炼、宝宝、法宝、祥瑞
        if([detail.allow_bargain integerValue] > 0)
        {
            leftPriceTxt = [NSString stringWithFormat:@"%@*",leftPriceTxt];
        }

    }else{
        if(cbgList.equip_accept > 0)
        {
            leftPriceTxt = [NSString stringWithFormat:@"%@*",leftPriceTxt];
        }
    }
    
    
    cell.latestMoneyLbl.textColor = color;
    
    cell.totalNumLbl.textColor = numcolor;//文本信息展示，区分是否最新一波数据,是否包含更多
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
        
        txt = (statusNum != 4 && statusNum != 6 && detail)?@"尚有":@"无";
        color = self.latestContain?[UIColor redColor]:[UIColor lightGrayColor];
        
        cell.sellTimeLbl.text = txt;
        cell.sellTimeLbl.textColor = color;
        cell.totalNumLbl.text = nil;
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}
#pragma mark -
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    WebEquip_listModel * contact = nil;
    if(secNum == 1){
        contact = [self.dataArr objectAtIndex:rowNum];
    }else if (secNum == 2){
        contact = [self.dataArr2 objectAtIndex:rowNum];
    }else{
        contact = self.latest;
    }
    
    if(contact)
    {
        ZACBGDetailWebVC * list = [[ZACBGDetailWebVC alloc] init];
        list.cbgList = [contact listSaveModel];
        list.detailModel = contact.equipModel;
        [[self rootNavigationController] pushViewController:list animated:YES];
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
