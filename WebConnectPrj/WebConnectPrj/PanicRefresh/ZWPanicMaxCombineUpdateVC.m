//
//  ZWPanicMaxCombineUpdateVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/7/5.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicMaxCombineUpdateVC.h"
#import "EquipDetailArrayRequestModel.h"
#import "Equip_listModel.h"
#import "PanicRefreshManager.h"
#import "ZWPanicUpdateListBaseRequestModel.h"
#import "Equip_listModel.h"
#import "JSONKit.h"
#import "ZWOperationDetailListReqModel.h"
#import "MSAlertController.h"
#import "ZALocationLocalModel.h"
#import "ZWPanicRefreshSettingVC.h"
#import "VPNProxyModel.h"
//详情数据更新结束，但是列表数据仍未更新，增加延迟2分钟内仅刷新一次
@interface ZWPanicMaxCombineUpdateVC ()<PanicListRequestTagUpdateListDelegate>
{
    NSMutableDictionary * detailModelDic;
    NSMutableArray * combineArr;
    NSCache * refreshCache;
    NSMutableArray * orderCacheArr;//替代refreshCache，屏蔽重复
    NSInteger partDetailNum;
}
@property (nonatomic, strong) NSArray * baseArr;
@property (nonatomic,strong) NSArray * panicTagArr;
@property (nonatomic,strong) NSArray * baseVCArr;
@property (nonatomic,strong) UIScrollView * coverScroll;
@property (nonatomic,assign) BOOL refreshState;
@property (nonatomic,strong) UIView * tipsErrorView;
@property (nonatomic,assign) NSInteger countNum;
@property (nonatomic,assign) NSInteger randNum;
@property (nonatomic,strong) UIView * errorTips;
@property (nonatomic,assign) NSInteger errorNum;
@property (nonatomic,strong) NSLock * dataLock;
@property (nonatomic,strong) NSDate * proxyRefreshDate;
@property (nonatomic,assign) NSInteger proxyNum;
@property (nonatomic,strong) NSArray * detailsArr;
@property (nonatomic,assign) BOOL detailProxy;
@end

@implementation ZWPanicMaxCombineUpdateVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        orderCacheArr = [NSMutableArray array];
//        refreshCache = [[NSCache alloc] init];
//        refreshCache.totalCostLimit = 1000;
//        refreshCache.countLimit = 1000;
        partDetailNum = 30;
        self.dataLock = [[NSLock alloc] init];
        detailModelDic = [NSMutableDictionary dictionary];
        combineArr = [NSMutableArray array];
        
        self.refreshState = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(panicCombineUpdateAddMoreDetailRefreshNoti:)
                                                     name:NOTIFICATION_ADD_REFRESH_WEBDETAIL_STATE
                                                   object:nil];
        
        self.proxyRefreshDate = [NSDate dateWithTimeIntervalSinceNow:MINUTE * 2];
        
    }
    return self;
}
-(void)panicCombineUpdateAddMoreDetailRefreshNoti:(NSNotification *)noti
{
    Equip_listModel * listObj = (Equip_listModel *)[noti object];
    NSString * keyObj = [listObj listCombineIdfa];
    
//    [self.dataLock lock];
    if(![orderCacheArr containsObject:keyObj])
    {
        if([orderCacheArr count] > 80)
        {
            [orderCacheArr removeObjectAtIndex:0];
        }
        [orderCacheArr addObject:keyObj];
    }
    
    if(![detailModelDic objectForKey:keyObj])
    {
        [detailModelDic setObject:listObj forKey:keyObj];
    }
    
    [self refreshTableViewWithLatestCacheArray:[detailModelDic allValues]];
    [self refreshCombineNumberAndProxyCacheNumberForTitle];
    [self.listTable reloadData];
//    [self.dataLock unlock];
}
-(void)refreshProxyCacheArrayAndCacheSubArray
{
    self.proxyRefreshDate = [NSDate dateWithTimeIntervalSinceNow:MINUTE * 2];
    self.proxyNum ++;
    
    if(self.proxyNum % 10 ==0)
    {
        ZWProxyRefreshManager * proxyManager =[ZWProxyRefreshManager sharedInstance];
        NSMutableArray * editProxy = [NSMutableArray arrayWithArray:proxyManager.proxyArrCache];
        
        NSInteger lineNum = [editProxy count] > 200?10:30;
        
        BOOL refresh = NO;
        for (NSInteger index = 0; index < [editProxy count]; index++)
        {
            VPNProxyModel * eve = [editProxy objectAtIndex:index];
            if(eve.errorNum >= lineNum)
            {
                refresh = YES;
                [editProxy removeObject:eve];
            }
        }
        
        if([editProxy count] < 100)
        {
            refresh = NO;
        }
        
        if(refresh)
        {
            proxyManager.proxyArrCache = editProxy;
            
            NSArray * dicArr = [VPNProxyModel proxyDicArrayFromDetailProxyArray:editProxy];
            
            ZALocalStateTotalModel * localTotal = [ZALocalStateTotalModel currentLocalStateModel];
            localTotal.proxyDicArr = dicArr;
            [localTotal localSave];
        }
    }
    
    
    ZWProxyRefreshManager * manager =[ZWProxyRefreshManager sharedInstance];
    [manager clearProxySubCache];
}
-(void)startPanicDetailArrayRequestRightNow
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    EquipDetailArrayRequestModel * listRequest = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(listRequest.executing) return;

    //以当前的detailArr  创建对应的model
    NSMutableArray * base = [NSMutableArray array];
    NSMutableArray * urls = [NSMutableArray array];
    
    //移除
//    [self.dataLock lock];
    //下次启动前进行清空检查
    NSMutableArray * removeArr = [NSMutableArray array];
    for (NSString * key in detailModelDic)
    {
        Equip_listModel * eveBase = [detailModelDic objectForKey:key];
        EquipModel * detail = eveBase.equipModel;
        CBGListModel * list = eveBase.listSaveModel;
        
        if(detail && (detail.equipState != CBGEquipRoleState_unSelling || [eveBase isAutoStopSelling] || list.plan_total_price < 1000))
        {
            [removeArr addObject:key];
            
        }else if(!detail || detail.equipState == CBGEquipRoleState_unSelling)
        {
            [urls addObject:[eveBase detailDataUrl]];
            [base addObject:eveBase];
        }
    }
    
    if([removeArr count] > 0)
    {
        for (NSString  * removeKey in removeArr)
        {
            [detailModelDic removeObjectForKey:removeKey];
        }
    }
    
    if([base count] > partDetailNum)
    {
        base = [NSMutableArray arrayWithArray:[base subarrayWithRange:NSMakeRange(0, partDetailNum)]];
        urls = [NSMutableArray arrayWithArray:[urls subarrayWithRange:NSMakeRange(0, partDetailNum)]];
    }
    
//    [self.dataLock unlock];
    
    NSLog(@"%s %ld",__FUNCTION__,[base count]);
    if([base count] == 0)
    {
        return;
    }
    
    EquipDetailArrayRequestModel * detailReq = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(detailReq.executing) return;

    
    self.baseArr = base;
    [self startEquipDetailAllRequestWithUrls:urls];
}

-(void)startEquipDetailAllRequestWithUrls:(NSArray *)array
{
    NSLog(@"%s",__FUNCTION__);
    
    ZWOperationDetailListReqModel * model = (ZWOperationDetailListReqModel *)_detailListReqModel;
    if(!model){
        model = [[ZWOperationDetailListReqModel alloc] init];
        [model addSignalResponder:self];
        _detailListReqModel = model;
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];
    model.proxyArr = total.isProxy?manager.proxySubCache:nil;
    
    if(!self.detailProxy)
    {
        model.proxyArr = nil;
    }
    
    [model refreshWebRequestWithArray:array];
    [model sendRequest];
    
}
-(void)refreshTipStateWithError:(BOOL)error
{
    
    self.errorTips.hidden = !error;
    if(error)
    {
        self.errorNum ++;
        if(self.errorNum %5 == 0)
        {
        }
    }
}

#pragma mark ZWOperationDetailListReqModel
handleSignal( ZWOperationDetailListReqModel, requestError )
{
    NSLog(@"%s",__FUNCTION__);
    //修改文本，提示网络异常
    [self refreshTipStateWithError:YES];
}
handleSignal( ZWOperationDetailListReqModel, requestLoading )
{
}

handleSignal( ZWOperationDetailListReqModel, requestLoaded )
{
    NSLog(@"%s",__FUNCTION__);
    
    
    //进行存储操作、展示
    //列表数据，部分成功部分还失败，对于成功的数据，刷新展示，对于失败的数据，继续请求
    ZWOperationDetailListReqModel * model = (ZWOperationDetailListReqModel *) _detailListReqModel;
    NSArray * total  = model.listArray;
    NSArray * list = self.baseArr;

    NSMutableArray * detailModels = [NSMutableArray array];
    NSInteger errorNum = 0;
    for (NSInteger index = 0; index < [total count]; index ++)
    {
        NSInteger backIndex = [total count] - index - 1;
        backIndex = index;
        id obj = [total objectAtIndex:backIndex];
        if([obj isKindOfClass:[NSArray class]] && [obj count] > 0)
        {
            [detailModels addObject:[obj firstObject]];
        }else{
            errorNum ++;
            [detailModels addObject:[NSNull null]];
        }
    }
    
    if([detailModels count] > 0)
    {
        BOOL showError = errorNum == [total count];
        [self refreshTipStateWithError:showError];
    }

    
//    [self.dataLock lock];
    BOOL forceRefresh = NO;
    NSMutableArray * removeArr = [NSMutableArray array];
    NSMutableArray * refreshArr = [NSMutableArray array];
    for (NSInteger index = 0;index < [list count] ;index ++ )
    {
        Equip_listModel * eveList = [list objectAtIndex:index];
        if([detailModels count] > index)
        {
            EquipModel * equip = [detailModels objectAtIndex:index];
            if([equip isKindOfClass:[EquipModel class]])
            {
                if(!eveList.equipModel)
                {
                    forceRefresh = YES;
                }
                eveList.equipModel = equip;
                CBGListModel * list = eveList.listSaveModel;
                eveList.earnRate = list.plan_rate;
                eveList.earnPrice = [NSString stringWithFormat:@"%.0ld",list.price_earn_plan];
                
                if(equip.equipState != CBGEquipRoleState_unSelling || [eveList isAutoStopSelling] || list.plan_total_price < 1000)
                {
                    [removeArr addObject:eveList.listCombineIdfa];
                    [refreshArr addObject:eveList];
                }
            }
        }
    }
    
    if([removeArr count] > 0)
    {
        for (NSString * removeKey in removeArr)
        {
            [detailModelDic removeObjectForKey:removeKey];
        }
    }
    
    if([refreshArr count] > 0)
    {
        for (NSInteger index = 0;index < [refreshArr count] ;index ++ )
        {
            Equip_listModel * eveList = [refreshArr objectAtIndex:index];
            [self finishDetailRefreshPostNotificationWithBaseDetailModel:eveList];
        }
        
        [self checkListInputForNoticeWithArray:refreshArr];
        [self refreshCombineNumberAndProxyCacheNumberForTitle];
        [self refreshTableViewWithLatestCacheArray:[detailModelDic allValues]];
        [self refreshTableViewWithInputLatestListArray:refreshArr cacheArray:nil];
        
    }else if(forceRefresh)
    {
        [self refreshCombineNumberAndProxyCacheNumberForTitle];
        [self refreshTableViewWithLatestCacheArray:[detailModelDic allValues]];
        [self.listTable reloadData];
    }
//    [self.dataLock unlock];
}
-(void)finishDetailRefreshPostNotificationWithBaseDetailModel:(Equip_listModel *)listModel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REMOVE_REFRESH_WEBDETAIL_STATE
                                                        object:listModel];
}


-(UIView *)tipsErrorView
{
    if(!_tipsErrorView)
    {
        CGFloat btnWidth = 100;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor greenColor];
        
        UILabel * albl = [[UILabel alloc] initWithFrame:aView.bounds];
        albl.text = @"重置统计";
        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnExchangeTotalWithTapedBtn:)];
        [aView addGestureRecognizer:tapGes];
        self.tipsErrorView = aView;
    }
    return _tipsErrorView;
}
-(UIView *)errorTips
{
    if(!_errorTips)
    {
        CGFloat btnWidth = 100;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor redColor];
        
        UILabel * albl = [[UILabel alloc] initWithFrame:aView.bounds];
        albl.text = @"错误(刷新)";
        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
//        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedRefreshGesture:)];
//        [aView addGestureRecognizer:tapGes];
        self.errorTips = aView;
    }
    return _errorTips;
}


-(void)tapedOnExchangeTotalWithTapedBtn:(id)sender
{
    self.countNum = 0;
    ZWProxyRefreshManager * proxyManager = [ZWProxyRefreshManager sharedInstance];
    NSString * title = [NSString stringWithFormat:@"改价更新 %ld-%ld",[proxyManager.proxyArrCache count],[combineArr count]];

    [self refreshTitleViewTitleWithLatestTitleName:title];

    [self stopPanicListRequestModelArray];
}


-(NSArray *)panicTagArr
{
    if(!_panicTagArr){
        NSMutableArray * tag = [NSMutableArray array];
        NSInteger totalNum  = 15;
//        totalNum = 2;
//        totalNum = 1;
        NSArray * sepArr = @[@1,@2,@6,@7,@4,@10,@11];
        for (NSInteger index = 1 ; index <= totalNum ; index ++)
        {
            NSNumber * num = [NSNumber numberWithInteger:index];
            if([sepArr containsObject:num])
            {
                NSString * eve1 = [NSString  stringWithFormat:@"%ld_1",(long)index];
                NSString * eve2 = [NSString  stringWithFormat:@"%ld_2",(long)index];
                NSString * eve3 = [NSString  stringWithFormat:@"%ld_3",(long)index];
                [tag addObject:eve1];
                [tag addObject:eve2];
                [tag addObject:eve3];
            }else{
                NSString * eve = [NSString  stringWithFormat:@"%ld_0",(long)index];
                [tag addObject:eve];
            }
        }
        self.panicTagArr = tag;
    }
    return _panicTagArr;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    [self startLocationDataRequest];
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s disappear",__FUNCTION__);
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    
    PanicRefreshManager * manager = [PanicRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [self stopPanicListRequestModelArray];
    [self localSaveDetailRefreshEquipListArray];
    [[ZALocation sharedInstance] stopUpdateLocation];
    
}
-(void)startLocationDataRequest
{
    ZALocation * locationInstance = [ZALocation sharedInstance];
    [locationInstance startLocationRequestUserAuthorization];
    __weak typeof(self) weakSelf = self;
    
    
    [locationInstance startLocationUpdateWithEndBlock:^(CLLocation *location){
        [weakSelf backLocationDataWithString:location];
    }];
}
-(void)backLocationDataWithString:(id)obj
{
    PanicRefreshManager * manager = [PanicRefreshManager sharedInstance];
    if(manager.isRefreshing) return;
    [self startOpenTimesRefreshTimer];
}
-(void)startOpenTimesRefreshTimer
{
    PanicRefreshManager * manager = [PanicRefreshManager sharedInstance];
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
        if(!self.refreshState) return ;
     
        if([self.proxyRefreshDate timeIntervalSinceNow] < 0)
        {
            [self refreshProxyCacheArrayAndCacheSubArray];
        }
        
//        [weakSelf performSelectorOnMainThread:@selector(startPanicDetailArrayRequestRightNow)
//                                   withObject:nil
//                                waitUntilDone:NO];
        
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        NSArray * ingoreArr = [total.ingoreCombineSchool componentsSeparatedByString:@"|"];
        
        weakSelf.randNum ++;
        
        if(weakSelf.randNum < 20) return;
        
        NSArray * vcArr = weakSelf.baseVCArr;
        for (NSInteger index = 0;index < [vcArr count] ; index ++)
        {
            if(index%3 != weakSelf.randNum%3)
            {
                continue;
            }
            ZWPanicUpdateListBaseRequestModel * eveRequest = [vcArr objectAtIndex:index];
            NSString * schoolTag = [NSString stringWithFormat:@"%ld",eveRequest.schoolNum];
            if([ingoreArr containsObject:schoolTag])
            {
                continue;
            }
            
            [eveRequest performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                                         withObject:nil
                                      waitUntilDone:NO];
            
            
        }
    };
    [manager saveCurrentAndStartAutoRefresh];
}

-(void)localSaveDetailRefreshEquipListArray
{
//    [self.dataLock lock];
    
    if([detailModelDic count] < 30)
    {
        NSMutableArray * dbArr = [NSMutableArray array];
        NSMutableArray *  detailArr = [NSMutableArray array];
        for (NSString * eveKey in detailModelDic)
        {
            Equip_listModel * eveModel = [detailModelDic objectForKey:eveKey];
            [detailArr addObject:eveModel.game_ordersn];
            
            if(eveModel.equipModel)
            {
                CBGListModel * list = eveModel.listSaveModel;
                list.dbStyle = CBGLocalDataBaseListUpdateStyle_TimeAndPlan;
                [dbArr addObject:list];
            }
        }
        
        if([dbArr count] > 0){
            ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
            [manager localSaveEquipHistoryArrayListWithDetailCBGModelArray:dbArr];
        }
        
        
        NSString * jsonStr = [[self class] convertToJsonData:detailArr];
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        total.orderSnCache = jsonStr;
        [total localSave];

    }
    
//    [self.dataLock unlock];
}
+ (NSString *)convertToJsonData:(NSArray *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
        
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}
-(void)stopPanicListRequestModelArray
{
    NSArray * vcArr = self.baseVCArr;
    for (ZWPanicUpdateListBaseRequestModel * eveRequest in vcArr)
    {
        [eveRequest stopRefreshRequestAndClearRequestModel];
    }
    
}
-(void)refreshLocalPanicRefreshState:(BOOL)state
{
    self.refreshState = state;
    self.titleV.text = state?@"改价更新":@"刷新停止";
}

-(void)combineSeperatedLocalDBModelForTotalList
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * vcArr = self.baseVCArr;
    for (ZWPanicListBaseRequestModel * eveRequest in vcArr)
    {
        NSArray * eveArr = [eveRequest dbLocalSaveTotalList];
        [dbManager localSaveEquipHistoryArrayListWithDetailCBGModelArray:eveArr];
    }
    [DZUtils noticeCustomerWithShowText:@"合并结束"];
}
-(void)seperateTotalListArrayForLocalSaveSeperatedDBModel
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSArray * vcArr = self.baseVCArr;
    for (ZWPanicListBaseRequestModel * eveRequest in vcArr)
    {
        NSString * school = [NSString stringWithFormat:@"%ld",eveRequest.schoolNum];
        NSArray * eveArr =  [dbManager localSaveEquipHistoryModelListForSchoolId:school];
        [eveRequest localSaveDBUpdateEquipListWithArray:eveArr];
    }
    [DZUtils noticeCustomerWithShowText:@"分拆结束"];
}
-(void)showDetailSchoolSettingCheck
{
    ZWPanicRefreshSettingVC * setting = [[ZWPanicRefreshSettingVC alloc] init];
    [[self rootNavigationController] pushViewController:setting animated:YES];
}


-(void)submit
{
    NSString * log = [NSString stringWithFormat:@"对刷新数据操作？"];
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"提示" message:log preferredStyle:MSAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"停止刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                             {
                                 [weakSelf refreshLocalPanicRefreshState:NO];
                             }];
    [alertController addAction:action];
    
    
    action = [MSAlertAction actionWithTitle:@"开始刷新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLocalPanicRefreshState:YES];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"添加库表缓存" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshLatestDatabaseListDataForLatestUnSell];
                  
              }];
    [alertController addAction:action];

    
    action = [MSAlertAction actionWithTitle:@"合并历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf combineSeperatedLocalDBModelForTotalList];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"拆分历史" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf seperateTotalListArrayForLocalSaveSeperatedDBModel];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"门派设置" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf showDetailSchoolSettingCheck];
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"开启代理" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.detailProxy = YES;
              }];
    [alertController addAction:action];
    
    action = [MSAlertAction actionWithTitle:@"关闭代理" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  weakSelf.detailProxy = NO;
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
-(void)refreshLatestDatabaseListDataForLatestUnSell
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    NSArray * sortArr = [manager localSaveEquipHistoryModelListEquipUnSell];
    NSMutableArray * orderArr = [NSMutableArray array];
    for (CBGListModel * eve in sortArr )
    {
        NSString * orderSN = eve.game_ordersn;
        if(![orderArr containsObject:orderSN]){
            [orderArr addObject:orderSN];
        }
    }
    
    NSDictionary * appDic = [self historyRequestDetailListFromOrderArray:orderArr];
//    [self.dataLock lock];
    [detailModelDic addEntriesFromDictionary:appDic];
//    [self.dataLock unlock];
}

- (void)viewDidLoad {
    self.rightTitle = @"更多";
    self.showRightBtn = YES;
    self.viewTtle = @"监听更新";
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.isProxy){
        self.viewTtle = @"代理监听";
    }
    [super viewDidLoad];
    
    NSInteger vcNum = [self.panicTagArr count];
    NSMutableArray * vcArr = [NSMutableArray array];
    //    scrollView.contentSize = CGSizeMake(rect.size.width * vcNum, rect.size.height);
    NSArray * dataArr = [total.orderSnCache objectFromJSONString];
    NSDictionary * appDic = [self historyRequestDetailListFromOrderArray:dataArr];
    if([appDic count] < 30){
        [detailModelDic addEntriesFromDictionary:appDic];   
    }
    
    for (NSInteger index = 0; index < vcNum; index ++)
    {
        NSString * eveTag = [self.panicTagArr objectAtIndex:index];
        ZWPanicUpdateListBaseRequestModel * eveModel = [[ZWPanicUpdateListBaseRequestModel alloc] init];
        eveModel.tagString = eveTag;
        [eveModel prepareWebRequestParagramForListRequest];
        eveModel.requestDelegate = self;
        [vcArr addObject:eveModel];
    }
    
    self.baseVCArr = vcArr;
    
    [self.view addSubview:self.tipsErrorView];
    self.tipsErrorView.hidden = NO;
    
    [self.view addSubview:self.errorTips];
    self.errorTips.hidden = YES;

}
-(NSDictionary *)historyRequestDetailListFromOrderArray:(NSArray *)dataArr
{
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    NSMutableDictionary * appDic = [NSMutableDictionary dictionary];
    for (NSInteger index = 0 ;index < [dataArr count] ;index ++)
    {
        NSString * eveKey = [dataArr objectAtIndex:index];
        NSArray * arr = [dbManager localSaveEquipHistoryModelListForOrderSN:eveKey];
        if([arr count] > 0){
            CBGListModel * cbgList = [arr firstObject];
            Equip_listModel * list = [[Equip_listModel alloc] init];
            list.serverid = [NSNumber numberWithInteger:cbgList.server_id];
            list.game_ordersn = cbgList.game_ordersn;
            [appDic setObject:list forKey:[list listCombineIdfa]];
        }
    }
    return appDic;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)panicListRequestFinishWithUpdateModel:(ZWPanicUpdateListBaseRequestModel *)model listArray:(NSArray *)array  cacheArray:(NSArray *)cacheArr
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    for (NSInteger index = 0;index < [array count] ;index ++ )
    {
        NSInteger backIndex = [array count] - 1 - index;
        backIndex = index;
        Equip_listModel * eveObj = [array objectAtIndex:backIndex];
        if(![eveObj.equip_name isEqualToString:@"大唐官府"]){
            
        }
        NSLog(@"panicListRequestFinishWithUpdateModel %@ %@",model.tagString, eveObj.listCombineIdfa);
        [combineArr addObject:eveObj];
    }
    
    
    //进行数据缓存，达到5条时，进行刷新
    if(![self checkListInputForNoticeWithArray:array] && [combineArr count] < 5)
    {//不进行刷新

        [self refreshCombineNumberAndProxyCacheNumberForTitle];
        return;
    }else{
        self.countNum = 0;
        //列表刷新，数据清空
//        [self.dataLock lock];
        NSArray * showArr = [NSArray arrayWithArray:combineArr];
        [combineArr removeAllObjects];
        
        [self refreshCombineNumberAndProxyCacheNumberForTitle];
        
//        [self tapedOnExchangeTotalWithTapedBtn:nil];
        [self refreshTableViewWithLatestCacheArray:[detailModelDic allValues]];
        [self refreshTableViewWithInputLatestListArray:showArr cacheArray:nil];
//        [self.dataLock unlock];
    }
}
-(void)refreshCombineNumberAndProxyCacheNumberForTitle
{
    ZWProxyRefreshManager * proxyManager = [ZWProxyRefreshManager sharedInstance];
    NSString * title = [NSString stringWithFormat:@"改价更新 %ld-%ld",[proxyManager.proxyArrCache count],[combineArr count]];
    [self refreshTitleViewTitleWithLatestTitleName:title];

}

//-(void)panicListRequestFinishWithModel:(ZWPanicListBaseRequestModel *)model withListError:(NSError *)error
//{
//
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
