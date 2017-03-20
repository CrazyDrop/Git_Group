//
//  ZWRefreshListController.m
//  ZAIOSMainPrj
//
//  Created by 超群 张 on 16/3/7.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWRefreshListController.h"
#import "RefreshListCell.h"
#import "ZWDataDetailModel.h"
#import "OpenTimesRefreshManager.h"
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

#define MonthTimeIntervalConstant 60*60*24*(30)
@interface ZWRefreshListController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL showTotal;
}
@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,copy) NSArray * dataArr;
@property (nonatomic,copy) NSArray * dataArr2;
@property (nonatomic,assign) BOOL latestContain;
@property (nonatomic,strong) ZWDataDetailModel * latest;
@property (nonatomic,strong) UIView * tipsView;

@end

@implementation ZWRefreshListController

- (void)viewDidLoad {
    NSDate * date = [NSDate date];
//    NSDate * date = [NSDate fromString:@"2016-02-05 17:54"];
    date = [date dateByAddingTimeInterval:MonthTimeIntervalConstant];
    NSString * select = [date toString:@"MM-dd"];
    showTotal = YES;
//    @"yyyy-MM-dd HH:mm:ss"
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * str = [NSString stringWithFormat:@"%ds",[total.refreshTime intValue]];
    
    self.viewTtle = [NSString stringWithFormat:@"当前(%@) %@",str,select];
    
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
    self.listTable = table;
    [self.view addSubview:table];

    [self.view addSubview:self.tipsView];
    self.tipsView.hidden = YES;
    
    
    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    check.localCheck = nil;
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
    [SFHFKeychainUtils exchangeLocalCreatedDeviceNum];

    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.randomAgent = [[DZUtils currentDeviceIdentifer] MD5String];
    [total localSave];
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
    
    
    action = [MSAlertAction actionWithTitle:@"筛选大额售单" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshForLargeRefreshList];
              }];
    [alertController addAction:action];
    action = [MSAlertAction actionWithTitle:@"展示全部售单" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action)
              {
                  [weakSelf refreshForTotalRefreshList];
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
-(void)refreshForLargeRefreshList
{
    showTotal = NO;
    [self.listTable reloadData];
}
-(void)refreshForTotalRefreshList
{
    showTotal = YES;
    [self.listTable reloadData];
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
    NSLog(@"%s",__FUNCTION__);
    
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
    if(manager.isRefreshing) return;
    [self startOpenTimesRefreshTimer];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    [self startLocationDataRequest];
//    [self startOpenTimesRefreshTimer];


}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    RefreshListDataManager * refresh = (RefreshListDataManager *)_dpModel;
    [refresh cancel];
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [[ZALocation sharedInstance] stopUpdateLocation];
}

-(void)startOpenTimesRefreshTimer
{
    OpenTimesRefreshManager * manager = [OpenTimesRefreshManager sharedInstance];
    __weak typeof(self) weakSelf = self;
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSInteger time = 2;
    if(total.refreshTime && [total.refreshTime intValue]>0){
        time = [total.refreshTime intValue];
    }
    manager.refreshInterval = time;
    manager.functionInterval = time;
    manager.funcBlock = ^()
    {
        [weakSelf startRefreshDataModelRequest];
    };
    [manager saveCurrentAndStartAutoRefresh];
}
-(void)refreshCurrentTitleVLableWithTotal:(CGFloat)totalMoney andCountNum:(NSInteger)number
{
    NSString * total = [NSString stringWithFormat:@"总在售 %.1fW(%d)",totalMoney/10000,number];
    self.titleV.text = total;
}


-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    
    if([self.dataArr count]>0)
    {
        [self checkCurrentLatestContainState];
    }

    
    //数据上传，通知解除
    RefreshListDataManager * model = (RefreshListDataManager *) _dpModel;
    if(!model){
        model = [[RefreshListDataManager alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    [model sendRequest];
}
#pragma mark RefreshListDataManager

handleSignal( RefreshListDataManager, requestError )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
handleSignal( RefreshListDataManager, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}


handleSignal( RefreshListDataManager, requestLoaded )
{
//    refreshLatestTotalArray
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    RefreshListDataManager * model = (RefreshListDataManager *) _dpModel;
    NSArray * array  = model.productsArr;
    
    if(!showTotal)
    {
        NSMutableArray * large = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZWDataDetailModel  * model = (ZWDataDetailModel *)obj;
            if([model.total_money integerValue] > 50000){
                [large addObject:obj];
            }
        }];
        array = large;
    }
    
    
    __block CGFloat totalSellNum = 0;
    if(array && [array count]>0)
    {
        //保存新出现的model
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ///数组查找填充
            ZWDataDetailModel  * model = (ZWDataDetailModel *)obj;
            totalSellNum += ([model.left_money floatValue]);
            DetailModelSaveType type = model.currentModelState;
            if(type == DetailModelSaveType_Buy || type == DetailModelSaveType_Notice )
            {
                ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
                BOOL firstAdd = [manager localSaveCurrentLocation:obj];
                if(firstAdd && [model.total_money intValue]>2000)
                {
                    [self startUserNotice];
                }
            }
        }];
        
        [self refreshCurrentTitleVLableWithTotal:totalSellNum andCountNum:[array count]];
    }
    
    
    
    CGPoint pt = self.listTable.contentOffset;
    self.dataArr2 = array;
    self.dataArr = model.topArr;
    
    self.tipsView.hidden = [array count] != 0;
    
    if(pt.y != 0)
    {
        //区域刷新
//        NSInteger number = NO?2:1;
//        NSIndexSet * set = [NSIndexSet indexSetWithIndex:number];
//        [self.listTable reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.listTable reloadData];
    }else
    {
        [self.listTable reloadData];
    }
    
    ZWDetailCheckManager * manager = [ZWDetailCheckManager sharedInstance];
    [manager refreshLatestTotalArray:array];
}


#pragma mark RefreshDataModel
handleSignal( RefreshDataModel, requestError )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    RefreshDataModel * model = (RefreshDataModel *) _dpModel;
//    self.dataArr = model.productsArr;
//    [self.listTable reloadData];
    
}
handleSignal( RefreshDataModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
//    [self showLoading];
}


handleSignal( RefreshDataModel, requestLoaded )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    RefreshDataModel * model = (RefreshDataModel *) _dpModel;
    NSArray * array  = model.productsArr;
    
    BOOL second = YES;
    

    //保存新出现的model
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ///数组查找填充
        ZWDataDetailModel  * model = (ZWDataDetailModel *)obj;
        DetailModelSaveType type = model.currentModelState;
        if(type == DetailModelSaveType_Buy || type == DetailModelSaveType_Notice )
        {
            ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
            BOOL firstAdd = [manager localSaveCurrentLocation:obj];
            if(firstAdd && [model.total_money intValue]>2000)
            {
                [self startUserNotice];
            }
        }
    }];
    
    CGPoint pt = self.listTable.contentOffset;
    if(second){
        self.dataArr2 = array;
    }else{
        self.dataArr = array;
    }
    
    if(pt.y != 0)
    {
        //区域刷新
        NSInteger number = second?2:1;
        NSIndexSet * set = [NSIndexSet indexSetWithIndex:number];
        [self.listTable reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
    }else
    {
        [self.listTable reloadData];
    }

    ZWDetailCheckManager * manager = [ZWDetailCheckManager sharedInstance];
    [manager refreshLatestCheckArray:array withSecond:second?1:0];
}


-(void)checkCurrentLatestContainState
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    ZWDataDetailModel * contact = [manager latestLocationModel];
    self.latest = contact;
    
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
    
    self.latestContain = contain;
    NSIndexSet * set = [NSIndexSet indexSetWithIndex:0];
    [self.listTable reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)startUserNotice
{
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(!model.isAlarm) return;
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state == UIApplicationStateBackground){
        [DZUtils localSoundTimeNotificationWithAfterSecond];
        return;
    }
    [self vibrate];
}

- (void)vibrate
{
    AudioServicesPlaySystemSound(1320);
//    1327
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNum = indexPath.row;
    NSInteger secNum = indexPath.section;
    ZWDataDetailModel * contact = nil;
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
    }
    UIColor * daysColor = secNum == 1?[UIColor lightGrayColor]:[UIColor blackColor];
    
    cell.rateLbl.text = contact.annual_rate_str;
    cell.timeLbl.text = contact.duration_str;
    cell.timeLbl.textColor = daysColor;
    
    UIColor * numcolor = [UIColor lightGrayColor];
    if([contact.left_money floatValue]!=[contact.total_money floatValue])
    {
        numcolor = [UIColor orangeColor];
    }
    cell.totalNumLbl.textColor = numcolor;
    cell.totalNumLbl.text = [NSString stringWithFormat:@"%@/%@",contact.left_money,contact.total_money];
    
    NSString * rate = contact.earnRate;
    UIColor * color = [UIColor lightGrayColor];

    NSString * sellTxt = nil;
    
    if([rate intValue]>10)
    {
        color = [UIColor redColor];

    }
    if([rate intValue]<10)
    {
        rate = nil;
    }else
    {
        NSInteger contain = 30;
        if(contact.containDays){
            contain = [contact.containDays intValue];
        }
        sellTxt = [NSString stringWithFormat:@"%.2f%%/%ld天",[contact.sellRate intValue]/100.0,[contact.duration_str intValue] -contain];
    }
    
//    if([contact.annual_rate_str floatValue]>9)
    {
        if(!contact.startMoney){
            [contact refreshStartState];
        }
        NSString * startMoney = contact.startMoney;
        if([startMoney integerValue]>=20000)
        {
            startMoney = [NSString stringWithFormat:@"%ld万",[startMoney integerValue]/10000];
        }else if([startMoney integerValue]<10000){
            startMoney = [NSString stringWithFormat:@"%.01f千",[startMoney integerValue]/1000.0];
        }else{
            startMoney = [NSString stringWithFormat:@"%.01f万",[startMoney integerValue]/10000.0];
        }
        if(!sellTxt){
            sellTxt = [NSString string];
        }
        sellTxt = [sellTxt stringByAppendingFormat:@" %@ %@ %@",contact.startRate,contact.duration_total,startMoney];
    }
    
    
    if(!contact) {
        sellTxt = nil;
        cell.totalNumLbl.text = nil;
    }
    
    UIColor * earnColor = [UIColor blackColor];
    if([contact.annual_rate_str floatValue] < [contact.startRate floatValue]){
        earnColor = [UIColor purpleColor];
    }
    cell.latestMoneyLbl.textColor = color;
    cell.latestMoneyLbl.text = rate;
    
    cell.sellRateLbl.text = sellTxt;
    cell.sellRateLbl.textColor = earnColor;
    cell.sellTimeLbl.text = nil;
    
    cell.sellRateLbl.font = cell.totalNumLbl.font;
    cell.sellDateLbl.hidden = YES;
    
    
    if(secNum == 0 )
    {
        color = [UIColor lightGrayColor];
        NSString * txt = nil;
        NSDate * date = [NSDate fromString:contact.start_sell_date];
        cell.sellTimeLbl.text = [date toString:@"MM-dd HH:mm"];
        DetailModelSaveType type = [contact currentModelState];
        if(type == DetailModelSaveType_Buy){
                    color = [UIColor redColor];
//            txt = @"购买";
        }else if(type == DetailModelSaveType_Notice){
                    color = [UIColor greenColor];
//            txt = @"关注";
        }
        
        txt = self.latestContain?@"尚有":@"无";
        color = self.latestContain?[UIColor redColor]:[UIColor lightGrayColor];

        cell.sellTimeLbl.text = txt;
        cell.sellTimeLbl.textColor = color;
    }


    
    return cell;
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
