//
//  ZWBaseRefreshShowListVC.m
//  WebConnectPrj
//
//  Created by Apple on 2017/8/8.
//  Copyright © 2017年 zhangchaoqun. All rights reserved.
//

#import "ZWBaseRefreshShowListVC.h"
#import "RefreshListCell.h"
#import "ZWDataDetailModel.h"
#import "RefreshDataModel.h"
#import "ZWHistoryListController.h"
#import "ZALocationLocalModel.h"
#import <AudioToolbox/AudioToolbox.h>
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
#import "EquipListRequestModel.h"
#import "EquipDetailArrayRequestModel.h"
#import "CBGNearHistoryVC.h"
#import "CBGDetailWebView.h"
#import "CBGPlanDetailPreShowWebVC.h"
#import "CBGZhaohuanListRequestModel.h"
#import "PWDTimeManager.h"
@interface ZWBaseRefreshShowListVC ()<UITableViewDataSource,UITableViewDelegate,
RefreshCellCopyDelgate>
{
    BOOL showTotal;
}
@property (nonatomic,strong) NSArray * grayArray;
@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,copy) NSArray * dataArr;
@property (nonatomic,copy) NSArray * dataArr2;
@property (nonatomic,assign) BOOL latestContain;
@property (nonatomic,strong) id latest;

@end

@implementation ZWBaseRefreshShowListVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        requestLock = [[NSLock alloc] init];
        [self appendNotificationForRestartTimerRefreshWithActive];

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



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startLocationDataRequest];

}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s disappear",__FUNCTION__);
    [super viewWillDisappear:animated];
    
    PWDTimeManager * manager = [PWDTimeManager sharedInstance];
    [manager endAutoRefreshAndClearTime];
    
    [[ZALocation sharedInstance] stopUpdateLocation];
}

-(void)startLocationDataRequest
{
    //    ZALocationLocalModelManager * manager = [ZALocationLocalModelManager sharedInstance];
    //    self.latest = [manager latestLocationModel];
    
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
    
    PWDTimeManager * manager = [PWDTimeManager sharedInstance];
    if(manager.isRefreshing) return;
    [self startOpenTimesRefreshTimer];
}

-(void)startOpenTimesRefreshTimer
{
    
    PWDTimeManager * manager = [PWDTimeManager sharedInstance];
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

-(void)startRefreshDataModelRequest
{
    
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


-(void)checkListInputForNoticeWithArray:(NSArray *)array
{
    ZALocalStateTotalModel * model = [ZALocalStateTotalModel currentLocalStateModel];
    if(!model.isAlarm){
        return;
    }
    
    NSInteger compareId = model.minServerId;
    Equip_listModel * maxModel = nil;
    CGFloat maxRate = 0;
    for (NSInteger index = 0; index < [array count]; index ++)
    {
        Equip_listModel * list = [array objectAtIndex:index];
        
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
    
    //进行提醒
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
//            self.planWeb = [[CBGDetailWebView alloc] init];
//            [self.planWeb prepareWebViewWithUrl:urlString];
//            
//            self.latest = maxModel;
//            self.latestContain = YES;
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

- (void)viewDidLoad
{
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
    
    ZWDetailCheckManager * check = [ZWDetailCheckManager sharedInstance];
    
    if(check.latestHistory)
    {
        self.showArray = check.latestHistory;
        self.dataArr2 = check.latestHistory;
        [self.listTable reloadData];
    }

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
    
    //用来标识是否最新一波数据
    UIColor * numcolor = [self.grayArray containsObject:contact]?[UIColor blackColor]:[UIColor lightGrayColor];
    
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
    EquipModel * detail = contact.equipModel;
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
        if(!rightStatusTxt)
        {
            rightStatusTxt = detail.status_desc;
        }
        if(!leftPriceTxt || [leftPriceTxt length] == 0){
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
        
    }else
    {
        rightStatusTxt = contact.status_desc;
        if((!leftPriceTxt || [leftPriceTxt intValue] == 0 )&& listModel.equip_price > 0)
        {
            leftPriceTxt = [NSString stringWithFormat:@"%ld",listModel.equip_price/100];
        }
        
        date = [NSDate fromString:contact.selling_time];
        rightTimeTxt =  [date toString:@"HH:mm"];
        
        NSTimeInterval interval = [self timeIntervalWithCreateTime:listModel.sell_create_time andSellTime:contact.selling_time];
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
    
    if([contact preBuyEquipStatusWithCurrentExtraEquip])
    {
        sellTxt = [NSString stringWithFormat:@"%.0ld %@",listModel.price_rate_latest_plan,sellTxt];
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
-(void)refreshTitleWithTitleTxt:(NSString *)title{
    self.titleV.text = title;
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
