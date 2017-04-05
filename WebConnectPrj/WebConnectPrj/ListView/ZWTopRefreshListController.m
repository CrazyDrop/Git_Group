//
//  ZWTopRefreshListController.m
//  ZAIOSMainPrj
//
//  Created by Apple on 16/12/8.
//  Copyright © 2016年 ZhongAn Insurance. All rights reserved.
//

#import "ZWTopRefreshListController.h"
#import "RefreshListCell.h"
#import "ZWDataDetailModel.h"
#import "CancelWarningRefreshManager.h"
#import "RefreshDataModel.h"
#import "ZWHistoryListController.h"
#import "ZALocationLocalModel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ZALocation.h"
#import "ZWDetailCheckManager.h"
#import "ZWTopRefreshModel.h"
#import "SFHFKeychainUtils.h"
#import "ZWRefreshListController.h"
#import "ZWSysSellModel.h"
#import "ZWSysSellModel.h"

@interface ZWTopRefreshListController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray * preSysArray;
}
@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,copy) NSArray * systemArray;
@property (nonatomic,copy) NSArray * showTopArray;
@property (nonatomic,copy) NSArray * firstPageArray;
@property (nonatomic,assign) BOOL latestContain;
@property (nonatomic,strong) ZWDataDetailModel * latest;
@property (nonatomic,strong) UIView * tipsView;
@end

@implementation ZWTopRefreshListController

- (void)viewDidLoad {

    preSysArray  = [NSMutableArray array];
    
    //    @"yyyy-MM-dd HH:mm:ss"
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    NSString * str = [NSString stringWithFormat:@"%ds",[total.refreshTime intValue]];
    
    self.viewTtle = @"小刷新";
    
    self.rightTitle = @"统计";
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
//    [SFHFKeychainUtils exchangeLocalCreatedDeviceNum];
    
    ZALocalStateTotalModel * total = [ZALocalStateTotalModel currentLocalStateModel];
    total.randomAgent = [[DZUtils currentDeviceIdentifer] MD5String];
    [total localSave];
}

-(void)submit
{
    //关闭
    [self clearAutoRefreshAndCancelRequest];
    
    ZWRefreshListController * list = [[ZWRefreshListController alloc] init];
    [[self rootNavigationController] pushViewController:list animated:YES];
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
    
    CancelWarningRefreshManager * manager = [CancelWarningRefreshManager sharedInstance];
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
    
    [self clearAutoRefreshAndCancelRequest];
}
-(void)clearAutoRefreshAndCancelRequest
{
//    ZWTopRefreshModel * refresh = (ZWTopRefreshModel *)_dpModel;
//    [refresh cancel];
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    CancelWarningRefreshManager * manager = [CancelWarningRefreshManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [[ZALocation sharedInstance] stopUpdateLocation];
}

-(void)startOpenTimesRefreshTimer
{
    CancelWarningRefreshManager * manager = [CancelWarningRefreshManager sharedInstance];
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
-(void)refreshCurrentTitleVLableWithTotal:(CGFloat)totalMoney andSoldNum:(CGFloat)sold
{
    CGFloat leftMoney = totalMoney - sold;

    totalMoney = totalMoney/10000;
    leftMoney = leftMoney/10000;
    
    
    NSString * total = [NSString stringWithFormat:@"%.1fW(%.1fW)",totalMoney,leftMoney];

    if(totalMoney > 1000 && leftMoney > 1000)
    {
         total = [NSString stringWithFormat:@"%.1fkW(%.1fkW)",totalMoney/1000,leftMoney/1000];
    }else if(totalMoney > 1000){
        total = [NSString stringWithFormat:@"%.1fkw(%.1fW)",totalMoney/1000,leftMoney];

    }else if(leftMoney > 1000){
        total = [NSString stringWithFormat:@"%.1fW(%.1fkW)",totalMoney,leftMoney/1000];

    }
    
    self.titleV.text = total;
}


-(void)startRefreshDataModelRequest
{
    if(![DZUtils deviceWebConnectEnableCheck])
    {
        return;
    }
    
    
    if([self.systemArray count]>0)
    {
        [self checkCurrentLatestContainState];
    }
    
    
    
    //数据上传，通知解除
    ZWTopRefreshModel * model = (ZWTopRefreshModel *) _dpModel;
    if(!model){
        model = [[ZWTopRefreshModel alloc] init];
        [model addSignalResponder:self];
        _dpModel = model;
    }
    [model sendRequest];
}
#pragma mark ZWTopRefreshModel

handleSignal( ZWTopRefreshModel, requestError )
{
    [self hideLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
handleSignal( ZWTopRefreshModel, requestLoading )
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if(state != UIApplicationStateActive){
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}


handleSignal( ZWTopRefreshModel, requestLoaded )
{
    //    refreshLatestTotalArray
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    ZWTopRefreshModel * model = (ZWTopRefreshModel *) _dpModel;
//    self.showTopArray = model.topArr;
    
    NSArray * array  = model.productsArr;
    
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
    }
    
    
    CGPoint pt = self.listTable.contentOffset;
    self.firstPageArray = array;
    
    NSArray * sysSell = nil;
//    model.systemArr;
    NSArray * arr = [sysSell sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ZWSysSellModel * contact1= (ZWSysSellModel *)obj1;
        ZWSysSellModel * contact2= (ZWSysSellModel *)obj2;
        return [contact1.product_id compare:contact2.product_id];
        
    }];
    self.systemArray = arr;
    [self checkSystemTotalBackArrayForChangeAndNoticeWithArr:arr];
    NSLog(@"%s top %d  system %d",__FUNCTION__,[self.showTopArray count],[sysSell count]);
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
    

}
-(void)checkSystemTotalBackArrayForChangeAndNoticeWithArr:(NSArray *)arr
{
    if(!arr || [arr count]==0) return;

    NSMutableString * total = [NSMutableString string];
    __block CGFloat totalSellNum = 0;
    __block CGFloat totalSoldNum = 0;
    for (NSInteger index = 0; index < [arr count]; index++)
    {
        ZWSysSellModel * contact= (ZWSysSellModel *)[arr objectAtIndex:index];
        [total appendFormat:@"%@_%@,",contact.name,contact.total_amount];

        totalSellNum += [contact.total_amount floatValue]/100;
        totalSoldNum += [contact.sold_amount floatValue]/100;
    }
    
    [self refreshCurrentTitleVLableWithTotal:totalSellNum andSoldNum:totalSoldNum];

    if(total && ![preSysArray containsObject:total])
    {
        [preSysArray addObject:total];
        if([preSysArray count] >2)
        {
            [self startUserNotice];
        }
    }
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
        self.showTopArray = array;
    }else{
        self.systemArray = array;
    }
    
    if(pt.y != 0)
    {
        //区域刷新
//        NSInteger number = second?2:1;
//        NSIndexSet * set = [NSIndexSet indexSetWithIndex:number];
//        [self.listTable reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.listTable reloadData];

    }else
    {
        [self.listTable reloadData];
    }
    
}


-(void)checkCurrentLatestContainState
{
    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    ZWDataDetailModel * contact = [manager latestLocationModel];
    self.latest = contact;
    
    if(!contact) return;
    
    __block BOOL contain = NO;
    NSMutableArray * array = [NSMutableArray arrayWithArray:self.systemArray];
    
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
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return [self.showTopArray count];
    }else if(section == 3){
        return [self.systemArray count];
    }else if(section == 2){
        return [self.firstPageArray count];
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
    if(secNum == 3)
    {
    }else if (secNum == 1){
        contact = [self.showTopArray objectAtIndex:rowNum];
    }else if(secNum == 2){
        contact = [self.firstPageArray objectAtIndex:rowNum];
    }else{
        contact = self.latest;
    }
    
    if(secNum == 3)
    {
        NSInteger secNum = indexPath.row;
        ZWSysSellModel * contact = [self.systemArray objectAtIndex:secNum];
        
        static NSString *cellIdentifier = @"RefreshListCellIdentifier_Sell";
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
        
        cell.rateLbl.textColor = [UIColor lightGrayColor];
        cell.rateLbl.text = contact.duration_str;
        cell.totalNumLbl.text = contact.name;
        
        
        
        cell.latestMoneyLbl.text = [NSString stringWithFormat:@"%@人",contact.month_order_count];
        
        
        cell.sellTimeLbl.text = contact.start_date;
        
        
        //更新时间
        NSDateFormatter * upFormat = [NSDate format:@"yyyyMMddHHmmss"];
        NSDate * updateDate = [upFormat dateFromString:contact.updated_at];
        cell.timeLbl.text = [updateDate toString:@"MM-dd HH:mm"];
        //    cell.timeLbl.text = contact.sell_date;
        
        cell.sellDateLbl.hidden = YES;
        cell.sellRateLbl.text =  [NSString stringWithFormat:@"%.1fW %ldW 余%.1fW",[contact.sold_amount floatValue]/10000/100,[contact.total_amount integerValue]/10000/100,([contact.total_amount integerValue]-[contact.sold_amount floatValue])/10000/100];
        
        UIColor * color = [UIColor grayColor];
        if(!contact.is_sell_out)
        {
            color = [UIColor redColor];
        }
        cell.sellRateLbl.textColor = color;
        return cell;
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
            if([startMoney integerValue] > 1000){
                startMoney = [NSString stringWithFormat:@"%.01f千",[startMoney integerValue]/1000.0];
            }else{
                startMoney = [NSString stringWithFormat:@"%.01f千",1000/1000.0];
            }
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
    
    cell.latestMoneyLbl.textColor = color;
    cell.latestMoneyLbl.text = rate;
    
    cell.sellRateLbl.text = sellTxt;
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


@end
