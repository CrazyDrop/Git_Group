//
//  ZWPanicCombineLatestVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/9/5.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicCombineLatestVC.h"
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
#import "SessionReqModel.h"
#import "ZWPanicUpdateLatestModel.h"
#import "ZWProxyRefreshModel.h"
//详情数据更新结束，但是列表数据仍未更新，增加延迟2分钟内仅刷新一次
@interface ZWPanicCombineLatestVC ()<PanicListRequestTagUpdateListDelegate,
ZWProxyCheckRefreshModelDelegate>
{
    NSMutableDictionary * detailModelDic;
    NSMutableArray * combineArr;
    NSCache * refreshCache;
    NSMutableArray * orderCacheArr;//替代refreshCache，屏蔽重复
    NSInteger partDetailNum;
    
    ZWProxyRefreshModel * proxyCheckModel;
    NSMutableArray * refreshPxyCache;
}
@property (nonatomic, strong) NSArray * baseArr;
@property (nonatomic,strong) NSArray * panicTagArr;
@property (nonatomic,strong) NSArray * baseVCArr;
@property (nonatomic,strong) UIScrollView * coverScroll;
@property (nonatomic,assign) BOOL refreshState;
@property (nonatomic,strong) UIView * tipsErrorView;
@property (nonatomic,assign) NSInteger countNum;
@property (nonatomic,assign) NSInteger countError;

@property (nonatomic,assign) NSInteger errorNum;
@property (nonatomic,assign) NSInteger randNum;
@property (nonatomic,strong) UIView * errorTips;
@property (nonatomic,strong) NSLock * dataLock;
@property (nonatomic,strong) NSDate * proxyRefreshDate;
@property (nonatomic,assign) NSInteger proxyNum;
@property (nonatomic,strong) NSArray * detailsArr;
@property (nonatomic,assign) BOOL detailProxy;
@property (nonatomic,assign) BOOL waitDetail;
//@property (nonatomic,strong) NSDictionary * combineDic;  // 有30个tag，model，30组请求，每次单摘一组展示，最后监听到的数据
@property (nonatomic,strong) NSString * webNum;
@property (nonatomic,strong) UILabel * numLbl;

@property (nonatomic,strong) NSMutableArray * successPxyArr;
@property (nonatomic,strong) NSMutableArray * failPxyArr;

@property (nonatomic,assign) BOOL autoProxy;
@end

@implementation ZWPanicCombineLatestVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        orderCacheArr = [NSMutableArray array];
        refreshPxyCache = [NSMutableArray array];
        self.successPxyArr = [NSMutableArray array];
        self.failPxyArr = [NSMutableArray array];
        
        //        refreshCache = [[NSCache alloc] init];
        //        refreshCache.totalCostLimit = 1000;
        //        refreshCache.countLimit = 1000;
        partDetailNum = 30;
        self.dataLock = [[NSLock alloc] init];
        detailModelDic = [NSMutableDictionary dictionary];
        combineArr = [NSMutableArray array];
        self.detailProxy = YES;
        self.refreshState = YES;
        self.waitDetail = NO;
        self.autoProxy = YES;
        
        proxyCheckModel = [[ZWProxyRefreshModel alloc] init];
        proxyCheckModel.resultDelegate = self;
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(panicCombineUpdateAddMoreDetailRefreshNoti:)
//                                                     name:NOTIFICATION_ADD_REFRESH_WEBDETAIL_STATE
//                                                   object:nil];
        
        self.proxyRefreshDate = [NSDate dateWithTimeIntervalSinceNow:MINUTE * 1];
        
    }
    return self;
}

-(NSArray *)panicTagArr
{
    if(!_panicTagArr){
        NSMutableArray * tag = [NSMutableArray array];
        NSInteger totalNum  = 15;
        //        totalNum = 2;
        //                totalNum = 1;
        NSArray * sepArr = @[@1,@2,@7,@6];
        NSArray * secondArr = @[@9,@10,@11,@4,@15,@8];
        
        for (NSInteger index = 1 ; index <= totalNum ; index ++)
        {
            
//                        if(index == 7)
//                        if(index == 14)
            {
                NSNumber * num = [NSNumber numberWithInteger:index];
                if([sepArr containsObject:num])
                {//16 +12 + 5
                    NSString * eve1 = [NSString  stringWithFormat:@"%ld_1",(long)index];
                    NSString * eve2 = [NSString  stringWithFormat:@"%ld_2",(long)index];
                    NSString * eve3 = [NSString  stringWithFormat:@"%ld_3",(long)index];
                    NSString * eve4 = [NSString  stringWithFormat:@"%ld_4",(long)index];
                    [tag addObject:eve1];
                    [tag addObject:eve2];
                    [tag addObject:eve3];
                    [tag addObject:eve4];
                }else if([secondArr containsObject:num])
                {
                    NSString * eve1 = [NSString  stringWithFormat:@"%ld_11",(long)index];
                    NSString * eve2 = [NSString  stringWithFormat:@"%ld_12",(long)index];
                    [tag addObject:eve1];
                    [tag addObject:eve2];
                    
                }else{
                    NSString * eve = [NSString  stringWithFormat:@"%ld_0",(long)index];
                    [tag addObject:eve];
                }
                
            }
        }
        self.panicTagArr = tag;
    }
    return _panicTagArr;
}

-(void)panicCombineUpdateAddMoreDetailRefreshNoti:(NSNotification *)noti
{
    Equip_listModel * listObj = (Equip_listModel *)[noti object];
    NSString * keyObj = [listObj listCombineIdfa];
    
    //    [self.dataLock lock];
    if([orderCacheArr containsObject:keyObj])
    {
        return;
    }
    
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
-(void)localRefreshCombineCacheArrayWithListObjectArray:(NSArray *)listArr
{
    for (NSInteger index = 0;index < [listArr count] ;index ++ )
    {
        Equip_listModel * listObj =  (Equip_listModel *)[listArr objectAtIndex:index];
        NSString * keyObj = [listObj listCombineIdfa];
        NSString * keyPre = [NSString stringWithFormat:@"%@|%@",listObj.game_ordersn,listObj.serverid];

        //    [self.dataLock lock];
        if([orderCacheArr containsObject:keyObj])
        {
            return;
        }
        
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
            [detailModelDic removeObjectForKey:keyPre];
            [detailModelDic setObject:listObj forKey:keyObj];
        }
        
        [self refreshTableViewWithLatestCacheArray:[detailModelDic allValues]];
    }
}

-(void)refreshProxyCacheArrayAndCacheSubArray
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(!total.isProxy) return;
    
    self.proxyRefreshDate = [NSDate dateWithTimeIntervalSinceNow:MINUTE * 1];
    self.proxyNum ++;
    
    //处理代理刷新结束，进行代理填充使用
    ZWProxyRefreshManager * proxyManager =[ZWProxyRefreshManager sharedInstance];
    if(proxyCheckModel.isFinished && [self.successPxyArr count] > 0)
    {
        NSMutableArray * success = [NSMutableArray array];
        [success addObjectsFromArray:self.successPxyArr];
        {
            NSMutableArray * editProxy = [NSMutableArray arrayWithArray:proxyManager.proxyArrCache];
            [editProxy addObjectsFromArray:success];
            
            [self.successPxyArr removeAllObjects];
            proxyManager.proxyArrCache = editProxy;
            [proxyManager refreshLatestSessionArrayWithReplaceArray:success];
            [proxyManager localRefreshListFileWithLatestProxyList];
            
            [self refreshLocalPanicRefreshState:YES];
        }
    }
    
    if(self.proxyNum % 5 ==0)
    {
        //进行代理更换，不仅仅是移除
        NSMutableArray * editProxy = [NSMutableArray arrayWithArray:proxyManager.proxyArrCache];
        NSMutableArray * refreshCheck = [NSMutableArray array];
        
        BOOL refresh = NO;
        
        NSInteger lineNum = [editProxy count] > 200?20:40;
        for (NSInteger index = 0; index < [editProxy count]; index++)
        {
            VPNProxyModel * eve = [editProxy objectAtIndex:index];
            if(eve.errorNum >= lineNum)
            {
                refresh = YES;
                [editProxy removeObject:eve];
                [refreshCheck addObject:eve];
            }
        }
        
        for (NSInteger index = 0; index < [editProxy count]; index++)
        {
            VPNProxyModel * eve = [editProxy objectAtIndex:index];
            if(eve.errored)
            {
                refresh = YES;
                [editProxy removeObject:eve];
                [refreshCheck addObject:eve];
            }
        }
        
        //存储近期失败的,前期统计
        [refreshPxyCache addObjectsFromArray:refreshCheck];
        
        
        //无论检查是否启动，正常进行变更保存
        proxyManager.proxyArrCache = editProxy;
        [proxyManager localRefreshListFileWithLatestProxyList];
        
        //两种选择，1实时的检查，实时添加 2统一达标线后进行检查，一次添加
        //使用第二种，尽管会中断刷新，但是可以简化代码
        if(!proxyCheckModel.isFinished)
        {
            return;
        }
        
        //仅控制启动
        if([editProxy count] < 100  && self.autoProxy)
        {//启动检查、清空相关数据，标准线之下时，一直启动检查刷新
            //启动代理检查，停止刷新
            NSMutableArray * totalFail = [NSMutableArray array];
            [totalFail addObjectsFromArray:refreshPxyCache];
            [totalFail addObjectsFromArray:self.failPxyArr];
            
            [self.failPxyArr removeAllObjects];
            [refreshPxyCache removeAllObjects];
            
            if([totalFail count] > 0)
            {//条件太少
                [self refreshLocalPanicRefreshState:NO];
                proxyCheckModel.checkArr = totalFail;
                [proxyCheckModel startProxyRefreshCheck];
            }
        }

    }else{
        
        //每2分钟，刷新一次vpn列表
        [proxyManager clearProxySubCache];
    }
    
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
    NSArray * sortArr = [detailModelDic allValues];
    if([sortArr count] > 400){
        self.waitDetail = YES;
    }else{
        self.waitDetail = NO;
    }
    
    sortArr = [sortArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
//        NSNumber * school1 = [(Equip_listModel *)obj1 ];
//        NSNumber * school2 = [(Equip_listModel *)obj2 price];
        NSNumber * price1 = [(Equip_listModel *)obj1 price];
        NSNumber * price2 = [(Equip_listModel *)obj2 price];
        
        if(!price1)
        {
            price1 = [NSNumber numberWithInt:0];
        }
        if(!price2)
        {
            price2 = [NSNumber numberWithInt:0];
        }

        return [price1 compare:price2];
    }];
    
    for (NSInteger  index = 0;index < [sortArr count];index ++)
    {
        Equip_listModel * eveBase = [sortArr objectAtIndex:index];
        NSString * key = [eveBase listCombineIdfa];
        
//        Equip_listModel * eveBase = [detailModelDic objectForKey:key];
        EquipModel * detail = eveBase.equipModel;
        CBGListModel * list = eveBase.listSaveModel;
        
        if(detail && (detail.equipState != CBGEquipRoleState_unSelling || [eveBase isAutoStopSelling] || list.plan_total_price < 0))
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
    NSLog(@"%s %ld",__FUNCTION__,[array count]);
    
    ZWOperationDetailListReqModel * model = (ZWOperationDetailListReqModel *)_detailListReqModel;
    if(!model){
        model = [[ZWOperationDetailListReqModel alloc] init];
        [model addSignalResponder:self];
        _detailListReqModel = model;
    }
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    if(total.isProxy && self.detailProxy)
    {
        ZWProxyRefreshManager * manager = [ZWProxyRefreshManager sharedInstance];
        model.sessionArr = manager.sessionSubCache;
    }
    model.timerState = !model.timerState;
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    //修改文本，提示网络异常
    [self refreshTipStateWithError:YES];
}
handleSignal( ZWOperationDetailListReqModel, requestLoading )
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

handleSignal( ZWOperationDetailListReqModel, requestLoaded )
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //进行存储操作、展示
    //列表数据，部分成功部分还失败，对于成功的数据，刷新展示，对于失败的数据，继续请求
    ZWOperationDetailListReqModel * model = (ZWOperationDetailListReqModel *) _detailListReqModel;
    NSArray * total  = [NSArray arrayWithArray:model.listArray];
    NSArray * list = [NSArray arrayWithArray:self.baseArr];
    NSArray * sessionArr = model.baseReqModels;
    
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
    
    NSLog(@"%s error%ld/%ld",__FUNCTION__,errorNum,[total count]);
    
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
                if(![eveList.game_ordersn isEqualToString:equip.game_ordersn])
                {
                    if([eveList.game_ordersn length] > 0 && [equip.game_ordersn length] > 0)
                    {
                        SessionReqModel * aReq = [sessionArr objectAtIndex:index];
                        [self refreshDetailErroredProxyWithRequestSession:aReq];
                    }
                    NSLog(@"detailRefreshError list %@ detail %@ %@",eveList.detailWebUrl,equip.game_ordersn,equip.serverid);
                    continue;
                }
                if(!eveList.equipModel)
                {
                    forceRefresh = YES;
                }
                
                eveList.equipModel = equip;
                CBGListModel * list = eveList.listSaveModel;
                eveList.earnRate = list.plan_rate;
                eveList.earnPrice = [NSString stringWithFormat:@"%.0ld",list.price_earn_plan];
                
                if(equip.equipState != CBGEquipRoleState_unSelling || [eveList isAutoStopSelling] || list.plan_total_price < 0)
                {
                    [removeArr addObject:eveList.listCombineIdfa];
                    [refreshArr addObject:eveList];
                }
                
                
                NSDate * sellDate = [NSDate fromString:equip.selling_time];
                NSTimeInterval count = fabs([sellDate timeIntervalSinceNow]);
                if(count > 60 && [list.sell_sold_time length] == 0 && [list.sell_back_time length] == 0 && [eveList.selling_time isEqualToString:equip.selling_time])
                {
                    NSLog(@"detailFinish %@ %@ %@ time(%@)%@",equip.equipExtra.iSchool,equip.game_ordersn,equip.serverid,eveList.selling_time,equip.selling_time);
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
        
        [self finishDetailRefreshPostNotificationWithBaseDetailModel:refreshArr];
        
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
-(void)refreshDetailErroredProxyWithRequestSession:(SessionReqModel *)opt
{
    ZWProxyRefreshManager * proxyManager = [ZWProxyRefreshManager sharedInstance];
    NSMutableArray * editProxy = [NSMutableArray arrayWithArray:proxyManager.proxyArrCache];
    
    {
        VPNProxyModel * optModel = opt.proxyModel;
        if([editProxy containsObject:optModel])
        {
            [editProxy removeObject:optModel];
            optModel.errored = YES;
            //            proxyManager.proxyArrCache = editProxy;
            //            [proxyManager localRefreshListFileWithLatestProxyList];
        }
    }
}
-(void)finishDetailRefreshPostNotificationWithBaseDetailModel:(NSArray *)listArr
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REMOVE_REFRESH_WEBDETAIL_STATE
                                                        object:listArr];
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
        albl.textAlignment = NSTextAlignmentCenter;
        self.numLbl = albl;
        albl.adjustsFontSizeToFitWidth = YES;
        
        //        [albl sizeToFit];
        [aView addSubview:albl];
        albl.center = CGPointMake(CGRectGetMidX(aView.bounds), CGRectGetMidY(aView.bounds));
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOnExchangeTotalWithTapedBtn:)];
        [aView addGestureRecognizer:tapGes];
        self.tipsErrorView = aView;
    }
    return _tipsErrorView;
}
-(void)refreshTipsErrorWithErrorNumberString
{
    NSString * num = self.webNum;
    if(!num || [num length] == 0)
    {
        return;
    }
    self.numLbl.text = num;
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
    
    [self refreshProxyCacheArrayAndCacheSubArray];
    [self refreshCombineNumberAndProxyCacheNumberForTitle];
    [self stopPanicListRequestModelArray];
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
        
        if([self.proxyRefreshDate timeIntervalSinceNow] < 0)
        {
            [self refreshProxyCacheArrayAndCacheSubArray];
        }
        
        if(!self.refreshState) return;
        
        [weakSelf performSelectorOnMainThread:@selector(startPanicDetailArrayRequestRightNow)
                                   withObject:nil
                                waitUntilDone:NO];
        
        
        if(weakSelf.waitDetail)
        {
            return;
        }
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        NSArray * ingoreArr = [total.ingoreCombineSchool componentsSeparatedByString:@"|"];
        
        weakSelf.randNum ++;
        
        if(weakSelf.randNum < 10) return;
        
        NSArray * vcArr = weakSelf.baseVCArr;
        for (NSInteger index = 0;index < [vcArr count] ; index ++)
        {
            if(index%3 != weakSelf.randNum%3)
            {
                continue;
            }
            ZWPanicUpdateListBaseRequestModel * eveRequest = [vcArr objectAtIndex:index];
            eveRequest.requestDelegate = self;
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
        eveRequest.requestDelegate = nil;
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
    
        action = [MSAlertAction actionWithTitle:@"关闭代理更新" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
                  {
                      weakSelf.autoProxy = NO;
                  }];
        [alertController addAction:action];
    
        action = [MSAlertAction actionWithTitle:@"关闭详情代理" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
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
    if(total.isProxy)
    {
        self.viewTtle = @"代理监听";
    }
    [super viewDidLoad];
    
    self.titleV.adjustsFontSizeToFitWidth = YES;

    
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
        ZWPanicUpdateLatestModel * eveModel = [[ZWPanicUpdateLatestModel alloc] init];
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
-(void)panicListRequestFinishWithUpdateModel:(ZWPanicUpdateListBaseRequestModel *)model listArray:(NSArray *)array  cacheArray:(NSArray *)cacheArr totalReqNum:(NSInteger)total andErrorNum:(NSInteger)errorNum
{
    //当前，不存在array数据
    self.countNum += total;
    self.countError += errorNum;
    
    if([cacheArr count] > 0)
    {//增加缓存，处理详情刷新
        [self localRefreshCombineCacheArrayWithListObjectArray:cacheArr];
    }
    
    if([array count] > 0)
    {//增加本地刷新
//        self.countNum += total;
//        self.countError += errorNum;
//        self.webNum = [NSString stringWithFormat:@"%ld/%ld (%@)",self.countError,self.countNum,model.tagString];
        
        for (NSInteger index = 0;index < [array count] ;index ++ )
        {
            NSInteger backIndex = [array count] - 1 - index;
            backIndex = index;
            Equip_listModel * eveObj = [array objectAtIndex:backIndex];
            NSLog(@"panicListRequestFinishWithUpdateModel %@ %@",model.tagString, eveObj.listCombineIdfa);
            [combineArr addObject:eveObj];
        }
    }
    
    //刷新失败率
    if(self.countNum > 100)
    {
        self.webNum = [NSString stringWithFormat:@"%ld/%ld (%@)",self.countError,self.countNum,model.tagString];
        self.countNum = 0;
        self.countError = 0;
        
        [self refreshTipsErrorWithErrorNumberString];
    }

    
    //进行数据缓存，达到5条时，进行刷新
    if(![self checkListInputForNoticeWithArray:array] && [combineArr count] < 5)
    {//不进行刷新，此时如果有缓存，依然要刷新
        
        [self refreshCombineNumberAndProxyCacheNumberForTitle];
        
        if([cacheArr count] > 0)
        {
            [self.listTable reloadData];
        }
        return;
    }else{
        
        //列表刷新，数据清空
        //        [self.dataLock lock];
        NSArray * showArr = [NSArray arrayWithArray:combineArr];
        [combineArr removeAllObjects];
        
        [self refreshCombineNumberAndProxyCacheNumberForTitle];
        
        if([showArr count] > 0)
        {
            [self refreshTableViewWithInputLatestListArray:showArr cacheArray:nil];
        }else{
            [self.listTable reloadData];
        }
    }

    
}
-(void)refreshCombineNumberAndProxyCacheNumberForTitle
{
    
    ZWProxyRefreshManager * proxyManager = [ZWProxyRefreshManager sharedInstance];
    NSString * title = [NSString stringWithFormat:@"改价更新 %ld - %ld",[proxyManager.proxyArrCache count],[combineArr count]];
//    if(self.waitDetail)
    {
        title = [NSString stringWithFormat:@"改价更新 %ld + %ld",[proxyManager.proxyArrCache count],[detailModelDic count]];
    }

    [self refreshTitleViewTitleWithLatestTitleName:title];
}

#pragma mark - ProxyCheckRefreshDelegate
-(void)proxyCheckRefreshModel:(ZWProxyRefreshModel *)model finishedCheckWithSuccess:(NSArray *)success andFail:(NSArray *)fail
{
    //发起请求后，清空数据
    [self.successPxyArr addObjectsFromArray:success];
    [self.failPxyArr addObjectsFromArray:fail];
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
