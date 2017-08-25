//
//  ZWLimitCircleRefreshVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWLimitCircleRefreshVC.h"
#import "MSAlertController.h"
#import "EquipDetailArrayRequestModel.h"
#import "EquipListRequestModel.h"
#import "ZWDetailCheckManager.h"
#import "Equip_listModel.h"
#import "ZWOperationEquipListCircleReqModel.h"
#import "ZWOperationDetailListReqModel.h"
@interface ZWLimitCircleRefreshVC ()
{
    NSInteger EquipListRequestWaitingTimeSep;
}
@property (nonatomic, assign) NSInteger requestIndex;
@property (nonatomic, assign) NSInteger preIndex;
@property (nonatomic, assign) NSInteger maxPageNum;

@property (nonatomic, strong) NSDate * begainDate;
@property (nonatomic, strong) NSDate * finishDate;
@property (nonatomic, assign) NSInteger timeSep;
@property (nonatomic, strong) NSDate * retryDate;
@property (nonatomic, assign) NSInteger ingoreProxy;
@end

@implementation ZWLimitCircleRefreshVC
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self =[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        EquipListRequestWaitingTimeSep = 2;
        self.maxPageNum = 10;
        self.requestIndex = 1;
        self.preIndex = 0;
        self.ingoreProxy = NO;
    }
    return self;
}
-(void)setRequestIndex:(NSInteger)requestIndex
{
    self.preIndex = self.requestIndex;
    _requestIndex = requestIndex;
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
    [check refreshDiskCacheWithDetailRequestFinishedArray:check.modelsArray];
    
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
    //    _detailListReqModel = nil;
    
    [refresh cancel];
    [refresh removeSignalResponder:self];
    //    _dpModel = nil;
    
    //    self.inWebRequesting = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    
}
- (void)viewDidLoad {
    self.rightTitle = @"筛选";
    self.showRightBtn = YES;
    self.viewTtle = @"单页刷新";
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.isProxy){
        self.viewTtle = @"单页刷新(代)";
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(void)clearWebRequestAndStartNextReqeustForError
{
    NSLog(@"%s",__FUNCTION__);
    EquipDetailArrayRequestModel * detailRefresh = (EquipDetailArrayRequestModel *)_detailListReqModel;
    EquipListRequestModel * refresh = (EquipListRequestModel *)_dpModel;
    
    if(detailRefresh.executing || refresh.executing)
    {
        [requestLock unlock];
    }
    
    [detailRefresh cancel];
    [detailRefresh removeSignalResponder:self];
    //    _detailListReqModel = nil;
    
    [refresh cancel];
    [refresh removeSignalResponder:self];
    
    _dpModel = nil;
    _detailListReqModel = nil;
}

-(void)startRefreshDataModelRequest
{
    
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
    
    ZWOperationEquipListCircleReqModel * model = (ZWOperationEquipListCircleReqModel *)_dpModel;
    //    CBGZhaohuanListRequestModel * model = (CBGZhaohuanListRequestModel *)_dpModel;
    if(!model){
        //model重建，仅界面消失时出现，执行时不处于请求中
        model = [[ZWOperationEquipListCircleReqModel alloc] init];
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
    
    model.repeatNum = self.maxPageNum;
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.isProxy)
    {
        ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];
        [manager clearProxySubCache];
        model.sessionArr = manager.sessionSubCache;
    }

    model.timerState = !model.timerState;
    [model sendRequest];

}

#pragma mark ZWOperationEquipListCircleReqModel
handleSignal( ZWOperationEquipListCircleReqModel, requestError )
{
    [self clearWebRequestAndStartNextReqeustForError];
    self.tipsView.hidden = NO;
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
}
handleSignal( ZWOperationEquipListCircleReqModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    [self showLoading];
}


handleSignal( ZWOperationEquipListCircleReqModel, requestLoaded )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%s",__FUNCTION__);
    
    ZWOperationEquipListCircleReqModel * model = (ZWOperationEquipListCircleReqModel *) _dpModel;
    NSArray * total  = model.listArray;
    NSArray * proxyErr = model.errorProxy;
    
    //正常序列
    NSInteger errorNum = 0;
    NSMutableArray * array = [NSMutableArray array];
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            [array addObjectsFromArray:obj];
        }else{
            errorNum ++;
        }
    }
//    NSLog(@"errorProxy %ld errorNum %ld total %ld",[proxyErr count],errorNum,[total count]);
    [self refreshTitleWithTitleTxt:[NSString stringWithFormat:@"代理刷新 %ld(%ld)",[total count],[total count] -[proxyErr count]]];
    
    //列表数据排重
    NSMutableDictionary * modelsDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0 ;index < [array count]; index ++ )
    {
        NSInteger backIndex = [array count] - index - 1;
        Equip_listModel * eveModel = [array objectAtIndex:backIndex];
        [modelsDic setObject:eveModel forKey:eveModel.detailCheckIdentifier];
    }
    NSArray * backArray = [modelsDic allValues];
    
//    [self refreshNextRequestPageAndTimeWithLatestBackArray:backArray];
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
-(void)refreshNextRequestPageAndTimeWithLatestBackArray:(NSArray *)array
{
    if(!array || [array count] == 0) return;
    
    NSArray * sort = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Equip_listModel * eve1 = (Equip_listModel *)obj1;
        Equip_listModel * eve2 = (Equip_listModel *)obj2;
        return [eve2.selling_time compare:eve1.selling_time];
    }];
    
    Equip_listModel * startObj = [sort firstObject];
    Equip_listModel * endObj = [sort lastObject];
    NSDate * startDate = [NSDate fromString:endObj.selling_time];
    NSDate * endDate = [NSDate fromString:startObj.selling_time];
    
    //两处要确定，1、是否需要请求下一页2、是否需要记录当前最后时间
    NSDate * preEndDate = self.finishDate;
//    NSDate * preBegainDate = self.begainDate;

    if(!preEndDate)
    {
        self.begainDate = startDate;
        self.finishDate =  endDate;
        //        self.begainDate = [NSDate dateWithTimeInterval:-1  sinceDate:startDate];
        //        self.finishDate = [NSDate dateWithTimeInterval:-1  sinceDate:endDate];
        
    }
    
    NSTimeInterval sepSpace = [endDate timeIntervalSinceDate:preEndDate];
    if(sepSpace > 0)
    {//时间有效，需要刷新
        if(self.requestIndex == 1)
        {
            self.begainDate = startDate;
            self.finishDate = endDate;
        }else{
//            self.requestIndex = 1;
        }
    }
    
    if(preEndDate)
    {
        //刷新请求的页数
        NSTimeInterval refreshSpace = [preEndDate timeIntervalSinceDate:startDate];
        if(refreshSpace >= 0)
        {
            self.requestIndex = 1;
            self.timeSep = self.preIndex == 1?EquipListRequestWaitingTimeSep:0;
        }else
        {
            self.requestIndex ++;
            self.timeSep = 0;
        }
    }
    

    
}
-(void)retryLatestDetailArrayRequest
{
    NSArray * models = self.detailsArr;
    NSMutableArray * urls = [NSMutableArray array];
    for (NSInteger index = 0; index < [models count]; index++) {
        Equip_listModel * eveModel = [models objectAtIndex:index];
        [urls addObject:eveModel.detailDataUrl];
    }
    
    [self startEquipDetailAllRequestWithUrls:urls];
}

-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
    NSLog(@"%s",__FUNCTION__);
    
    ZWOperationDetailListReqModel * model = (ZWOperationDetailListReqModel *)_detailListReqModel;
    if(model.executing) return;

    if(!model){
        model = [[ZWOperationDetailListReqModel alloc] init];
        [model addSignalResponder:self];
        _detailListReqModel = model;
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.isProxy)
    {
        ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];
        model.sessionArr = manager.sessionSubCache;
    }
    
    [model refreshWebRequestWithArray:array];
    [model sendRequest];
    
}

#pragma mark ZWOperationDetailListReqModel
handleSignal( ZWOperationDetailListReqModel, requestError )
{
//    [self retryLatestDetailArrayRequest];
    [self clearWebRequestAndStartNextReqeustForError];
    self.tipsView.hidden = NO;
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
handleSignal( ZWOperationDetailListReqModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

handleSignal( ZWOperationDetailListReqModel, requestLoaded )
{
    NSLog(@"%s",__FUNCTION__);
    //进行存储操作、展示
    ZWOperationDetailListReqModel * model = (ZWOperationDetailListReqModel *) _detailListReqModel;
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
            if(![obj.game_ordersn isEqualToString:detailEve.game_ordersn])
            {
                NSLog(@"list %@ detail %@ %@",obj.detailWebUrl,detailEve.game_ordersn,detailEve.serverid);
                continue;
            }

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
-(void)submit
{
    //提供选择
    NSString * log = [NSString stringWithFormat:@"对刷新数据筛选？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = nil;
    
    //    action = [MSAlertAction actionWithTitle:@"刷新上架" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
    //              {
    //                  [weakSelf refreshLocalShowListForLatestSelling];
    //              }];
    //    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"代理3个" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  //                  [weakSelf refreshLocalShowListForLactestUpdating];
                  weakSelf.maxPageNum = 3;
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"代理10个" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  //                  [weakSelf refreshLocalShowLatestCountPagesRequest];
                  weakSelf.maxPageNum = 10;
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"代理20个" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  //                  [weakSelf refreshLocalShowLatestCountPagesRequest];
                  weakSelf.maxPageNum = 20;
              }];
    [alertController addAction:action];
    
//    action = [MSAlertAction actionWithTitle:@"屏蔽代理" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
//              {
//                  //                  [weakSelf refreshLocalShowLatestCountPagesRequest];
//                  weakSelf.ingoreProxy = YES;
//              }];
//    [alertController addAction:action];
//
//    action = [MSAlertAction actionWithTitle:@"开启代理" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
//              {
//                  //                  [weakSelf refreshLocalShowLatestCountPagesRequest];
//                  weakSelf.ingoreProxy = NO;
//              }];
//    [alertController addAction:action];


    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
