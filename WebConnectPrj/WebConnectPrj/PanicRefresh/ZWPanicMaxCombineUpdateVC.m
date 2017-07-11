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
#import "MSAlertController.h"
#import "ZALocationLocalModel.h"
#import "ZWPanicRefreshSettingVC.h"
//详情数据更新结束，但是列表数据仍未更新，增加延迟2分钟内仅刷新一次
@interface ZWPanicMaxCombineUpdateVC ()<PanicListRequestTagUpdateListDelegate>
{
    NSMutableDictionary * detailModelDic;
    NSMutableDictionary * showDataDic;
    NSMutableDictionary * showCacheDic;

    NSMutableArray * combineArr;
    NSCache * refreshCache;
}
@property (nonatomic, strong) NSArray * baseArr;

@property (nonatomic,strong) NSArray * panicTagArr;
@property (nonatomic,strong) NSArray * baseVCArr;
@property (nonatomic,strong) UIScrollView * coverScroll;
@property (nonatomic,assign) BOOL refreshState;
@property (nonatomic,strong) UIView * tipsErrorView;
@end

@implementation ZWPanicMaxCombineUpdateVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        refreshCache = [[NSCache alloc] init];
        refreshCache.totalCostLimit = 1000;
        refreshCache.countLimit = 1000;
        
        detailModelDic = [NSMutableDictionary dictionary];
        showCacheDic = [NSMutableDictionary dictionary];
        combineArr = [NSMutableArray array];
        self.refreshState = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(panicCombineUpdateAddMoreDetailRefreshNoti:)
                                                     name:NOTIFICATION_ADD_REFRESH_WEBDETAIL_STATE
                                                   object:nil];
        
        
    }
    return self;
}
-(void)panicCombineUpdateAddMoreDetailRefreshNoti:(NSNotification *)noti
{
    Equip_listModel * listObj = (Equip_listModel *)[noti object];
    NSString * keyObj = [listObj listCombineIdfa];
    if([refreshCache objectForKey:keyObj]){
        return;
    }
    [refreshCache setObject:@1 forKey:keyObj];
    
    @synchronized (detailModelDic)
    {
        if(![detailModelDic objectForKey:keyObj])
        {
            [detailModelDic setObject:listObj forKey:keyObj];
        }
        
        [self refreshTableViewWithLatestCacheArray:[detailModelDic allValues]];
        [self.listTable reloadData];
    }
    
}
-(void)startPanicDetailArrayRequestRightNow
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    NSMutableDictionary * totalDic = [NSMutableDictionary dictionary];
    
    @synchronized (detailModelDic)
    {
        [totalDic addEntriesFromDictionary:detailModelDic];
    }
    
    if([totalDic count] == 0){
        return;
    }
    
    NSLog(@"%s %ld",__FUNCTION__,[totalDic count]);
   
    EquipDetailArrayRequestModel * listRequest = (EquipDetailArrayRequestModel *)_detailListReqModel;
    if(listRequest.executing) return;
    
    
    

    //以当前的detailArr  创建对应的model
    NSMutableArray * base = [NSMutableArray array];
    NSMutableArray * urls = [NSMutableArray array];
    
//    NSArray * keyArr = [detailModelDic allKeys];
//    for (NSInteger index = 0;index < [keyArr count] ;index ++ )
//    {
//        NSString * eveBase = [keyArr objectAtIndex:index];
//        NSArray * arr = [eveBase componentsSeparatedByString:@"|"];
//        if([arr count] == 2)
//        {
//            Equip_listModel * eveList = [[Equip_listModel alloc] init];
//            eveList.game_ordersn = [arr firstObject];
//            eveList.serverid = [NSNumber numberWithInteger:[[arr lastObject] integerValue]];
//            
//            [urls addObject:[eveList detailDataUrl]];
//            [base addObject:eveList];
//        }
//    }
    
    
    NSMutableArray * removeArr = [NSMutableArray array];
    for (NSString * key in totalDic)
    {
        Equip_listModel * eveBase = [totalDic objectForKey:key];
        EquipModel * detail = eveBase.equipModel;
        
        if(detail && detail.equipState != CBGEquipRoleState_unSelling)
        {
            [removeArr addObject:key];
        }else if(!detail || detail.equipState == CBGEquipRoleState_unSelling)
        {
            [urls addObject:[eveBase detailDataUrl]];
            [base addObject:eveBase];
        }
    }
    
    @synchronized (detailModelDic)
    {
        for (NSString * key in removeArr )
        {
            [detailModelDic removeObjectForKey:key];
        }
    }
    
    self.baseArr = base;
    [self startEquipDetailAllRequestWithUrls:urls];
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
    
    [model refreshWebRequestWithArray:array];
    [model sendRequest];
    
}

#pragma mark EquipDetailArrayRequestModel
handleSignal( EquipDetailArrayRequestModel, requestError )
{
    NSLog(@"%s",__FUNCTION__);

}
handleSignal( EquipDetailArrayRequestModel, requestLoading )
{
}

handleSignal( EquipDetailArrayRequestModel, requestLoaded )
{
    NSLog(@"%s",__FUNCTION__);
    
    //进行存储操作、展示
    //列表数据，部分成功部分还失败，对于成功的数据，刷新展示，对于失败的数据，继续请求
    EquipDetailArrayRequestModel * model = (EquipDetailArrayRequestModel *) _detailListReqModel;
    NSArray * total  = model.listArray;
    
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
    
    
    BOOL forceRefresh = NO;
    NSArray * list = self.baseArr;
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
                if(equip.equipState != CBGEquipRoleState_unSelling)
                {
                    [refreshArr addObject:eveList];
                }
            }
        }
    }
    
    
    NSMutableDictionary * totalDic = [NSMutableDictionary dictionary];
    @synchronized (detailModelDic)
    {
        [totalDic addEntriesFromDictionary:detailModelDic];
    }

    
    if([refreshArr count] > 0)
    {
        for (NSInteger index = 0;index < [refreshArr count] ;index ++ )
        {
            Equip_listModel * eveList = [refreshArr objectAtIndex:index];
            NSString * removeStr = [eveList listCombineIdfa];
            [totalDic removeObjectForKey:removeStr];
            [self finishDetailRefreshPostNotificationWithBaseDetailModel:eveList];
        }
        
        [self checkListInputForNoticeWithArray:refreshArr];
        [self refreshTableViewWithLatestCacheArray:[totalDic allValues]];
        [self refreshTableViewWithInputLatestListArray:refreshArr cacheArray:nil];
        
    }else if(forceRefresh)
    {
        [self refreshTableViewWithLatestCacheArray:[totalDic allValues]];
        [self.listTable reloadData];
    }
    
    
    
}
-(void)finishDetailRefreshPostNotificationWithBaseDetailModel:(Equip_listModel *)listModel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REMOVE_REFRESH_WEBDETAIL_STATE
                                                        object:listModel];
}


-(UIView *)tipsErrorView{
    if(!_tipsErrorView)
    {
        CGFloat btnWidth = 100;
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - btnWidth)/2.0, CGRectGetMaxY(self.titleBar.frame), btnWidth, 40)];
        aView.backgroundColor = [UIColor redColor];
        
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
-(void)tapedOnExchangeTotalWithTapedBtn:(id)sender
{
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
        
        ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
        NSArray * ingoreArr = [total.ingoreCombineSchool componentsSeparatedByString:@"|"];
        
        NSArray * vcArr = weakSelf.baseVCArr;
        for (ZWPanicUpdateListBaseRequestModel * eveRequest in vcArr)
        {
            NSString * schoolTag = [NSString stringWithFormat:@"%ld",eveRequest.schoolNum];
            if([ingoreArr containsObject:schoolTag])
            {
                continue;
            }
            
            [eveRequest performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                                         withObject:nil
                                      waitUntilDone:NO];
            
            
        }
        
        [weakSelf performSelectorOnMainThread:@selector(startPanicDetailArrayRequestRightNow)
                                   withObject:nil
                                waitUntilDone:NO];
    };
    [manager saveCurrentAndStartAutoRefresh];
}

-(void)localSaveDetailRefreshEquipListArray
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
    
    
    NSString * rightTxt = @"取消";
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:rightTxt style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    }];
    [alertController addAction:action2];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
    
}

- (void)viewDidLoad {
    self.rightTitle = @"更多";
    self.showRightBtn = YES;
    self.viewTtle = @"并发更新";

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    UIView * bgView = self.view;
    //    CGRect rect = [[UIScreen mainScreen] bounds];
    
    //    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:rect];
    //    [bgView addSubview:scrollView];
    //    scrollView.pagingEnabled = YES;
    //    scrollView.bounces = NO;
    //    scrollView.scrollsToTop = NO;
    //    self.coverScroll = scrollView;
    
    NSInteger vcNum = [self.panicTagArr count];
    NSMutableArray * vcArr = [NSMutableArray array];
    //    scrollView.contentSize = CGSizeMake(rect.size.width * vcNum, rect.size.height);
    
    ZALocationLocalModelManager * dbManager = [ZALocationLocalModelManager sharedInstance];
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSArray * dataArr = [total.orderSnCache objectFromJSONString];
    
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
    [detailModelDic addEntriesFromDictionary:appDic];
    
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
        Equip_listModel * eveObj = [array objectAtIndex:backIndex];
        NSLog(@"panicListRequestFinishWithUpdateModel %@ %@",model.tagString, eveObj.listCombineIdfa);
//        [combineArr insertObject:eveObj atIndex:0];
        [combineArr addObject:eveObj];
    }
    
    //进行数据缓存，达到5条时，进行刷新
    if(![self checkListInputForNoticeWithArray:array] && [combineArr count] < 5)
    {//不进行刷新
        
//        NSInteger count =  model.errorTotal;
//        self.countNum += count;
        
        NSString * title = [NSString stringWithFormat:@"改价更新 %ld",[combineArr count]];
        [self refreshTitleViewTitleWithLatestTitleName:title];
        
        return;
    }else{
        
        //列表刷新，数据清空
        
        NSArray * showArr = [NSArray arrayWithArray:combineArr];
        [combineArr removeAllObjects];
        
        [self tapedOnExchangeTotalWithTapedBtn:nil];
        NSString * title = [NSString stringWithFormat:@"改价更新 %ld",[combineArr count]];
        [self refreshTitleViewTitleWithLatestTitleName:title];
        
        [self refreshTableViewWithInputLatestListArray:showArr cacheArray:nil];
    }
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
