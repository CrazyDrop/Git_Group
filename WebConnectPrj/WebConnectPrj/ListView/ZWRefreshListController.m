//
//  ZWRefreshListController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/7.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWRefreshListController.h"
#import "ZWDetailCheckManager.h"
#import "MSAlertController.h"
#import "ZWHistoryListController.h"
#import "ZALocation.h"
#import "PWDTimeManager.h"
#import "ZALocationLocalModel.h"
#import "EquipListRequestModel.h"
#import "Equip_listModel.h"
#define MonthTimeIntervalConstant 60*60*24*(30)
@interface ZWRefreshListController ()
{
    NSLock * requestLock;
}
//界面不消失，一直不重复大范围请求操作

@property (nonatomic,assign) NSInteger totalPageNum;
@property (nonatomic,strong) NSArray * proxyArr;
@end

@implementation ZWRefreshListController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.totalPageNum = 3;
        
        
        NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookiesArray)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }

//        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//        self.proxyArr = total.proxyModelArray;
    }
    
    return self;
}



- (void)viewDidLoad {
    
    NSDate * date = [NSDate date];
//    NSDate * date = [NSDate fromString:@"2016-02-05 17:54"];
    date = [date dateByAddingTimeInterval:MonthTimeIntervalConstant];
    NSString * select = [date toString:@"MM-dd"];
//    @"yyyy-MM-dd HH:mm:ss"
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * str = [NSString stringWithFormat:@"%ds",[total.refreshTime intValue]];
    
    if(!self.onlyList){
        self.viewTtle = [NSString stringWithFormat:@"当前(%@) %@",str,select];
    }else{
        self.viewTtle = @"屏蔽部分";
    }
    
    
    self.rightTitle = @"筛选";
    self.showRightBtn = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    check.ingoreDB = self.ingoreDB;

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
    
    action = [MSAlertAction actionWithTitle:@"刷新3页" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
//                  [weakSelf refreshLocalShowListForLactestUpdating];
                  weakSelf.totalPageNum = 3;
                  [weakSelf refreshLatestListRequestModelWithSmallList:NO];
              }];
    [alertController addAction:action];

    action = [MSAlertAction actionWithTitle:@"刷新10页" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
//                  [weakSelf refreshLocalShowLatestCountPagesRequest];
                  weakSelf.totalPageNum = 10;
                  [weakSelf refreshLatestListRequestModelWithSmallList:NO];
              }];
    [alertController addAction:action];

    
//    action = [MSAlertAction actionWithTitle:@"预加载数据" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
//              {
//                  [weakSelf refreshLocalShowListForLargeRequest];
//              }];
//    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"屏蔽库表操作" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshCheckManagerDBIngore:YES];
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


-(void)viewWillAppear:(BOOL)animated
{
    _detailListReqModel = nil;
    _dpModel = nil;
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s disappear",__FUNCTION__);
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    EquipDetailArrayRequestModel * detailRefresh = (EquipDetailArrayRequestModel *)_detailListReqModel;
    EquipListRequestModel * refresh = (EquipListRequestModel *)_dpModel;

    if(detailRefresh.executing || refresh.executing)
    {
        [requestLock unlock];
    }


    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    check.latestHistory = self.showArray;
    [check refreshDiskCacheWithDetailRequestFinishedArray:check.modelsArray];
    
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
//    _detailListReqModel = nil;
    
    [refresh cancel];
    [refresh removeSignalResponder:self];
//    _dpModel = nil;
    
//    self.inWebRequesting = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;

    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishRequestWithExchange) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startRefreshDataModelRequest) object:nil];
}

-(void)refreshCurrentTitleVLableWithTotal:(CGFloat)totalMoney andCountNum:(NSInteger)number
{
    NSString * total = [NSString stringWithFormat:@"总在售 %.1fW(%d)",totalMoney/10000,number];
    self.titleV.text = total;
}

-(void)refreshLatestListRequestModelWithSmallList:(BOOL)small
{//使用小范围请求
//    if(TARGET_IPHONE_SIMULATOR)
//    {
//        small = NO;
//    }
//    if(self.onlyList){
//        small = YES;
//    }
    
    
    //变更请求model，实现小范围请求
    EquipListRequestModel * model = (EquipListRequestModel *)_dpModel;
//    model.pageNum = small?RefreshListMinPageNum:RefreshListMaxPageNum;
    model.pageNum = self.totalPageNum;
    
//    if(self.forceRefresh)
//    {
//        model.pageNum = 10;
//    }
}

-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
//    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    
    EquipDetailArrayRequestModel * detailArr = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(detailArr.executing) return;
    
    EquipListRequestModel * listRequest = (EquipListRequestModel *)_dpModel;
    if(listRequest.executing) return;

    
//    if(self.inWebRequesting)
//    {
//        return;
//    }
//    self.inWebRequesting = YES;
    [requestLock lock];
    
    NSLog(@"%s",__FUNCTION__);
    
    EquipListRequestModel * model = (EquipListRequestModel *)_dpModel;
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[EquipListRequestModel alloc] init];
        [model addSignalResponder:self];
//        model.saveCookie = YES;
        _dpModel = model;
        
        model.pageNum = self.totalPageNum;
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

    model.timerState = !model.timerState;
    [model sendRequest];
}

#pragma mark EquipListRequestModel
handleSignal( EquipListRequestModel, requestError )
{
    self.tipsView.hidden = NO;
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    

}
handleSignal( EquipListRequestModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [self showLoading];
}


handleSignal( EquipListRequestModel, requestLoaded )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%s",__FUNCTION__);

    EquipListRequestModel * model = (EquipListRequestModel *) _dpModel;
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

    //列表数据排重
    NSMutableDictionary * modelsDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0 ;index < [array count]; index ++ )
    {
        NSInteger backIndex = [array count] - index - 1;
        Equip_listModel * eveModel = [array objectAtIndex:backIndex];
        [modelsDic setObject:eveModel forKey:eveModel.detailCheckIdentifier];
    }
    NSArray * backArray = [modelsDic allValues];
    
    self.tipsView.hidden = [backArray count] != 0;
    
    EquipDetailArrayRequestModel * detailArr = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(detailArr.executing) return;
    
    //服务器数据排列顺序，最新出现的在最前面
    //服务器返回的列表数据，需要进行详情请求
    //详情请求需要检查，1、本地是否已有存储 2、是否存储于请求队列中
    //不检查本地存储、不检查队列是否存在，仅检查缓存数据
    ZWDetailCheckManager * checkManager = [ZWDetailCheckManager sharedInstance];
    NSArray * models = [checkManager checkLatestBackListDataModelsWithBackModelArray:backArray];
    NSArray * refreshArr = checkManager.refreshArr;
    if([refreshArr count] > 0)
    {
        NSLog(@"checkManager %lu ",(unsigned long)[refreshArr count]);
        [self refreshTableViewWithInputLatestListArray:refreshArr replace:NO];
    }
    
    if([models count] > 0)
    {
//        [checkManager refreshLocalDBHistoryWithLatestBackModelArr:backArray];
        //数量大于0，发起请求
        NSLog(@"EquipListRequestModel %lu %lu",(unsigned long)[array count],(unsigned long)[models count]);
        
        NSMutableArray * urls = [NSMutableArray array];
        for (NSInteger index = 0; index < [models count]; index++) {
            Equip_listModel * eveModel = [models objectAtIndex:index];
            [urls addObject:eveModel.detailDataUrl];
        }
        
        self.detailsArr = [NSArray arrayWithArray:models];
        [self startEquipDetailAllRequestWithUrls:urls];
    }else{
        
        //进行查询库表操作处理
        
        //为空，标识没有新url
        [requestLock unlock];
    }

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
    NSLog(@"%s",__FUNCTION__);

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
        Equip_listModel * obj = [models objectAtIndex:index];
        if(![detailEve isKindOfClass:[NSNull class]])
        {
            if(!detailEve.game_ordersn){
                continue;
            }
            obj.equipModel = detailEve;
            CBGListModel * list = obj.listSaveModel;
            obj.earnRate = list.plan_rate;
            obj.earnPrice = [NSString stringWithFormat:@"%ld",list.price_earn_plan];
        }
    }
    
    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    [check refreshDiskCacheWithDetailRequestFinishedArray:models];
    NSArray * showModels = check.filterArray;
    
    
    //刷新展示列表
    [self refreshTableViewWithInputLatestListArray:showModels replace:NO];
//    self.inWebRequesting = NO;
    
    [requestLock unlock];
    //预留库表处理时间
//    [self performSelector:@selector(finishRequestWithExchange) withObject:nil afterDelay:2];
//    [self performSelector:@selector(startRefreshDataModelRequest) withObject:nil afterDelay:2];
}
-(void)finishRequestWithExchange
{
    NSLog(@"%s",__FUNCTION__);

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"%s",__FUNCTION__);
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
