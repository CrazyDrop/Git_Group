//
//  ZWPanicMaxCombinedVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/6/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWPanicMaxCombinedVC.h"
#import "ZWPaincCombineBaseVC.h"
#import "PanicRefreshManager.h"
#import "ZWPanicListBaseRequestModel.h"
#import "Equip_listModel.h"
#import "JSONKit.h"
#import "MSAlertController.h"
#import "ZALocationLocalModel.h"
#import "ZWPanicRefreshSettingVC.h"

@interface ZWPanicMaxCombinedVC ()<PanicListRequestTagListDelegate>
{
    NSMutableDictionary * showDataDic;
    NSMutableDictionary * showCacheDic;
    
    NSMutableArray * combineArr;
    NSMutableArray * detailRefreshArr;
}
@property (nonatomic,strong) NSArray * panicTagArr;
@property (nonatomic,strong) NSArray * baseVCArr;
@property (nonatomic,strong) UIScrollView * coverScroll;
@property (nonatomic,assign) BOOL refreshState;
@property (nonatomic,strong) UIView * tipsErrorView;

@property (nonatomic,assign) NSInteger countNum;//统计成功的数量
@property (nonatomic,assign) NSInteger errorNum;//统计失败的数量，整个大失败

@end

@implementation ZWPanicMaxCombinedVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        showDataDic = [NSMutableDictionary dictionary];
        showCacheDic = [NSMutableDictionary dictionary];
        combineArr = [NSMutableArray array];
        self.refreshState = YES;
        detailRefreshArr = [NSMutableArray array];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(listenToDetailUpdateRequestWithNoti:) name:NOTIFICATION_ADD_REFRESH_WEBDETAIL_STATE
//                                                   object:nil];
        
    }
    return self;
}

//-(void)listenToDetailUpdateRequestWithNoti:(NSNotification *)noti
//{
//    NSString * objStr = [noti object];
//    if(![detailRefreshArr containsObject:objStr])
//    {
//        [detailRefreshArr addObject:objStr];
//    }
//}
//




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
    self.errorNum = 0;
    self.countNum = 0;
}


-(NSArray *)panicTagArr
{
    if(!_panicTagArr){
        NSMutableArray * tag = [NSMutableArray array];
        NSInteger totalNum  = 15;
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
        for (ZWPanicListBaseRequestModel * eveRequest in vcArr)
        {
            NSString * schoolTag = [NSString stringWithFormat:@"%ld",eveRequest.schoolNum];
            if([ingoreArr containsObject:schoolTag])
            {
                continue;
            }
            
            [eveRequest performSelectorOnMainThread:@selector(startRefreshLatestDetailModelRequest)
                                         withObject:nil
                                      waitUntilDone:NO];

            [eveRequest performSelectorOnMainThread:@selector(startRefreshDataModelRequest)
                                       withObject:nil
                                    waitUntilDone:NO];

        }
    };
    [manager saveCurrentAndStartAutoRefresh];
}
-(void)localSaveDetailRefreshEquipListArray
{
//    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary];
//    for (NSString * eveKey in showCacheDic)
//    {
//        NSArray * eveArr = [showCacheDic objectForKey:eveKey];
//        NSMutableArray * eveCache = [NSMutableArray array];
//        for (NSInteger index = 0;index < [eveArr count] ;index ++ )
//        {
//            Equip_listModel * eveModel = [eveArr objectAtIndex:index];
//            [eveCache addObject:eveModel.game_ordersn];
//        }
//        
//        if([eveCache count] > 0)
//        {
//            NSString * combine = [eveCache componentsJoinedByString:@"|"];
//            [dataDic setObject:combine forKey:eveKey];
//        }
//    }
//    
//    NSString * jsonStr = [[self class] convertToJsonData:dataDic];
//
//    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
//    total.orderSnCache = jsonStr;
//    [total localSave];

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
    for (ZWPanicListBaseRequestModel * eveRequest in vcArr)
    {
        [eveRequest stopRefreshRequestAndClearRequestModel];
    }

}

- (void)viewDidLoad {
    self.rightTitle = @"更多";
    self.showRightBtn = YES;
    self.viewTtle = @"改价并发";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIView * bgView = self.view;
    CGRect rect = [[UIScreen mainScreen] bounds];
    
//    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:rect];
//    [bgView addSubview:scrollView];
//    scrollView.pagingEnabled = YES;
//    scrollView.bounces = NO;
//    scrollView.scrollsToTop = NO;
//    self.coverScroll = scrollView;
    
    NSInteger vcNum = [self.panicTagArr count];
    NSMutableArray * vcArr = [NSMutableArray array];
//    scrollView.contentSize = CGSizeMake(rect.size.width * vcNum, rect.size.height);
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSDictionary * dataDic = [total.orderSnCache objectFromJSONString];
    dataDic = nil;
    
    for (NSInteger index = 0; index < vcNum; index ++)
    {
        NSString * eveTag = [self.panicTagArr objectAtIndex:index];
        ZWPanicListBaseRequestModel * eveModel = [[ZWPanicListBaseRequestModel alloc] init];
        eveModel.tagString = eveTag;
        NSString * combine = [dataDic objectForKey:eveTag];
        if([combine isKindOfClass:[NSString class]] && [combine length] > 0){
            NSArray * eveArr = [combine componentsSeparatedByString:@"|"];
            eveModel.cacheArr = eveArr;
        }
        [eveModel prepareWebRequestParagramForListRequest];
        eveModel.requestDelegate = self;
        [vcArr addObject:eveModel];
    }
    
    self.baseVCArr = vcArr;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(refreshPaincVCScrollWithRefreshNoti:)
//                                                 name:NOTIFICATION_ZWPANIC_REFRESH_STATE
//                                               object:nil];
    [self.view addSubview:self.tipsErrorView];
    self.tipsErrorView.hidden = NO;
}
+(void)updateCacheArrayListWithRemove:(NSString *)orderSn
{
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSArray * dataArr = [total.orderSnCache objectFromJSONString];
    
    NSMutableArray * editArr = [NSMutableArray array];
    [editArr addObjectsFromArray:dataArr];
    [editArr removeObject:orderSn];
    
    
    NSString * jsonStr = [self convertToJsonData:editArr];
    total.orderSnCache = jsonStr;
    [total localSave];
}



-(void)refreshLocalPanicRefreshState:(BOOL)state
{
    self.refreshState = state;
    self.titleV.text = state?@"改价并发":@"刷新停止";
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


-(void)refreshPaincVCScrollWithRefreshNoti:(NSNotification *)not
{
    NSString * tag = not.object;
    if([tag length] > 0)
    {
        NSInteger index = [self.panicTagArr indexOfObject:tag];
        CGPoint pt = CGPointMake(SCREEN_WIDTH * index, 0);
        [self.coverScroll setContentOffset:pt animated:YES];
    }
}

-(void)panicListRequestFinishWithModel:(ZWPanicListBaseRequestModel *)model listArray:(NSArray *)array  cacheArray:(NSArray *)cacheArr
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSString * tagid = model.tagString;
    [showCacheDic setObject:cacheArr forKey:tagid];
    for (NSInteger index = 0;index < [array count] ;index ++ )
    {
        NSInteger backIndex = [array count] - 1 - index;
        id eveObj = [array objectAtIndex:backIndex];
        [combineArr insertObject:eveObj atIndex:0];
    }
    
    //进行数据缓存，达到5条时，进行刷新
    if(![self checkListInputForNoticeWithArray:array] && [combineArr count] < 5)
    {//不进行刷新
        
        NSInteger count =  model.errorTotal;
        self.countNum += count;
        
        NSString * title = [NSString stringWithFormat:@"改价并发 %ld-%ld",[combineArr count],self.countNum];
        [self refreshTitleViewTitleWithLatestTitleName:title];
        
        return;
    }else{
        
        //列表刷新，数据清空
        NSMutableArray * totalCache = [NSMutableArray array];
        for(NSInteger index = 0 ;index < [self.panicTagArr count]; index ++)
        {
            NSString * tag = [self.panicTagArr objectAtIndex:index];
            NSArray * eveArr = [showCacheDic objectForKey:tag];
            [totalCache addObjectsFromArray:eveArr];
        }
        NSArray * showArr = [NSArray arrayWithArray:combineArr];
        [combineArr removeAllObjects];
        
        [self tapedOnExchangeTotalWithTapedBtn:nil];
        NSString * title = [NSString stringWithFormat:@"改价并发 %ld-%ld",[combineArr count],self.countNum];
        [self refreshTitleViewTitleWithLatestTitleName:title];

        [self refreshTableViewWithInputLatestListArray:showArr cacheArray:totalCache];
    }
}
-(void)panicListRequestFinishWithModel:(ZWPanicListBaseRequestModel *)model withListError:(NSError *)error
{
    if(error)
    {
        NSInteger count =  model.errorTotal;
        self.countNum += count;

        NSString * title = [NSString stringWithFormat:@"部分错误 %ld",self.countNum];
        [self refreshTitleViewTitleWithLatestTitleName:title];

        self.errorNum ++;
    }
    
    if(self.errorNum > 5)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        [self tapedOnExchangeTotalWithTapedBtn:nil];
    }
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
